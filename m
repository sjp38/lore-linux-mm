Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 754356B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 16:28:09 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so2092370pdj.38
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 13:28:09 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id ss2si563497pbc.160.2014.09.04.13.27.32
        for <linux-mm@kvack.org>;
        Thu, 04 Sep 2014 13:27:33 -0700 (PDT)
Message-ID: <5408CB2E.3080101@sr71.net>
Date: Thu, 04 Sep 2014 13:27:26 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <5406262F.4050705@intel.com> <54062F32.5070504@sr71.net> <20140904142721.GB14548@dhcp22.suse.cz>
In-Reply-To: <20140904142721.GB14548@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On 09/04/2014 07:27 AM, Michal Hocko wrote:
> Ouch. free_pages_and_swap_cache completely kills the uncharge batching
> because it reduces it to PAGEVEC_SIZE batches.
> 
> I think we really do not need PAGEVEC_SIZE batching anymore. We are
> already batching on tlb_gather layer. That one is limited so I think
> the below should be safe but I have to think about this some more. There
> is a risk of prolonged lru_lock wait times but the number of pages is
> limited to 10k and the heavy work is done outside of the lock. If this
> is really a problem then we can tear LRU part and the actual
> freeing/uncharging into a separate functions in this path.
> 
> Could you test with this half baked patch, please? I didn't get to test
> it myself unfortunately.

3.16 settled out at about 11.5M faults/sec before the regression.  This
patch gets it back up to about 10.5M, which is good.  The top spinlock
contention in the kernel is still from the resource counter code via
mem_cgroup_commit_charge(), though.

I'm running Johannes' patch now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
