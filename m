Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 253A96B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 11:13:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so22594640wme.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 08:13:15 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id gy10si4718671wjc.115.2016.05.03.08.13.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 08:13:13 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e201so4342610wme.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 08:13:13 -0700 (PDT)
Date: Tue, 3 May 2016 17:13:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
Message-ID: <20160503151312.GA4470@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <8737q5ugcx.fsf@notabene.neil.brown.name>
 <20160429120418.GK21977@dhcp22.suse.cz>
 <87twiiu5gs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87twiiu5gs.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <mr@neil.brown.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

Hi,

On Sun 01-05-16 07:55:31, NeilBrown wrote:
[...]
> One particular problem with your process-context idea is that it isn't
> inherited across threads.
> Steve Whitehouse's example in gfs shows how allocation dependencies can
> even cross into user space.

Hmm, I am still not sure I understand that example completely but making
a dependency between direct reclaim and userspace can hardly work.
Especially when the direct reclaim might be sitting on top of hard to
guess pile of locks. So unless I've missed anything what Steve has
described is a clear NOFS context.

> A more localized one that I have seen is that NFSv4 sometimes needs to
> start up a state-management thread (particularly if the server
> restarted).
> It uses kthread_run(), which doesn't actually create the thread but asks
> kthreadd to do it.  If NFS writeout is waiting for state management it
> would need to make sure that kthreadd runs in allocation context to
> avoid deadlock.
> I feel that I've forgotten some important detail here and this might
> have been fixed somehow, but the point still stands that the allocation
> context can cross from thread to thread and can effectively become
> anything and everything.

Not sure I understand your point here but relying on kthread_run
from GFP_NOFS context has always been deadlock prone with or without
scope GFP_NOFS semantic so I am not really sure I see your point
here. Similarly relying on a work item which doesn't have a dedicated
WQ_MEM_RECLAIM WQ is deadlock prone.  You simply shouldn't do that.

> It is OK to wait for memory to be freed.  It is not OK to wait for any
> particular piece of memory to be freed because you don't always know who
> is waiting for you, or who you really are waiting on to free that
> memory.
> 
> Whenever trying to free memory I think you need to do best-effort
> without blocking.

I agree with that. Or at least you have to wait on something that is
_guaranteed_ to make a forward progress. I am not really that sure this
is easy to achieve with the current code base.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
