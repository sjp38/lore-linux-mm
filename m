Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88D896B0253
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 06:20:42 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id x189so4289141ywe.2
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 03:20:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k64si7062649qkl.191.2016.04.29.03.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 03:20:41 -0700 (PDT)
Subject: Re: [Cluster-devel] [PATCH 0/2] scop GFP_NOFS api
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <8737q5ugcx.fsf@notabene.neil.brown.name>
From: Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <57233571.50509@redhat.com>
Date: Fri, 29 Apr 2016 11:20:33 +0100
MIME-Version: 1.0
In-Reply-To: <8737q5ugcx.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <mr@neil.brown.name>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ntfs-dev@lists.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, reiserfs-devel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, logfs@logfs.org, cluster-devel@redhat.com, Chris Mason <clm@fb.com>, linux-mtd@lists.infradead.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, xfs@oss.sgi.com, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-afs@lists.infradead.orgcluster-devel <cluster-devel@redhat.com>

Hi,

On 29/04/16 06:35, NeilBrown wrote:
> On Tue, Apr 26 2016, Michal Hocko wrote:
>
>> Hi,
>> we have discussed this topic at LSF/MM this year. There was a general
>> interest in the scope GFP_NOFS allocation context among some FS
>> developers. For those who are not aware of the discussion or the issue
>> I am trying to sort out (or at least start in that direction) please
>> have a look at patch 1 which adds memalloc_nofs_{save,restore} api
>> which basically copies what we have for the scope GFP_NOIO allocation
>> context. I haven't converted any of the FS myself because that is way
>> beyond my area of expertise but I would be happy to help with further
>> changes on the MM front as well as in some more generic code paths.
>>
>> Dave had an idea on how to further improve the reclaim context to be
>> less all-or-nothing wrt. GFP_NOFS. In short he was suggesting an opaque
>> and FS specific cookie set in the FS allocation context and consumed
>> by the FS reclaim context to allow doing some provably save actions
>> that would be skipped due to GFP_NOFS normally.  I like this idea and
>> I believe we can go that direction regardless of the approach taken here.
>> Many filesystems simply need to cleanup their NOFS usage first before
>> diving into a more complex changes.>
> This strikes me as over-engineering to work around an unnecessarily
> burdensome interface.... but without details it is hard to be certain.
>
> Exactly what things happen in "FS reclaim context" which may, or may
> not, be safe depending on the specific FS allocation context?  Do they
> need to happen at all?
>
> My research suggests that for most filesystems the only thing that
> happens in reclaim context that is at all troublesome is the final
> 'evict()' on an inode.  This needs to flush out dirty pages and sync the
> inode to storage.  Some time ago we moved most dirty-page writeout out
> of the reclaim context and into kswapd.  I think this was an excellent
> advance in simplicity.
> If we could similarly move evict() into kswapd (and I believe we can)
> then most file systems would do nothing in reclaim context that
> interferes with allocation context.
evict() is an issue, but moving it into kswapd would be a potential 
problem for GFS2. We already have a memory allocation issue when 
recovery is taking place and memory is short. The code path is as follows:

  1. Inode is scheduled for eviction (which requires deallocation)
  2. The glock is required in order to perform the deallocation, which 
implies getting a DLM lock
  3. Another node in the cluster fails, so needs recovery
  4. When the DLM lock is requested, it gets blocked until recovery is 
complete (for the failed node)
  5. Recovery is performed using a userland fencing utility
  6. Fencing requires memory and then blocks on the eviction
  7. Deadlock (Fencing waiting on memory alloc, memory alloc waiting on 
DLM lock, DLM lock waiting on fencing)

It doesn't happen often, but we've been looking at the best place to 
break that cycle, and one of the things we've been wondering is whether 
we could avoid deallocation evictions from memory related contexts, or 
at least make it async somehow.

The issue is that it is not possible to know in advance whether an 
eviction will result in mearly writing things back to disk (because the 
inode is being dropped from cache, but still resides on disk) which is 
easy to do, or whether it requires a full deallocation (n_link==0) which 
may require significant resources and time,

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
