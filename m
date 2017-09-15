Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C16AC6B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:39:17 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o200so5757867itg.2
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 04:39:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j3si929007iti.82.2017.09.15.04.39.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 04:39:15 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
	<20170915103957.64r5xln7s6wlu3ro@dhcp22.suse.cz>
In-Reply-To: <20170915103957.64r5xln7s6wlu3ro@dhcp22.suse.cz>
Message-Id: <201709152038.BHF26323.LFOMFHOFOJSVQt@I-love.SAKURA.ne.jp>
Date: Fri, 15 Sep 2017 20:38:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, yuwang668899@gmail.com
Cc: vbabka@suse.cz, mpatocka@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com

Michal Hocko wrote:
> On Fri 15-09-17 17:58:49, wang Yu wrote:
> > From: "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>
> > 
> > I found a softlockup when running some stress testcase in 4.9.x,
> > but i think the mainline have the same problem.
> > 
> > call trace:
> > [365724.502896] NMI watchdog: BUG: soft lockup - CPU#31 stuck for 22s!
> > [jbd2/sda3-8:1164]
> > ...
> > ...
> > [365724.503258] Call Trace:
> > [365724.503260]  [<ffffffff811ace5f>] warn_alloc+0x13f/0x170
> > [365724.503264]  [<ffffffff811ad8c2>] __alloc_pages_slowpath+0x9b2/0xc10
> > [365724.503265]  [<ffffffff811add43>] __alloc_pages_nodemask+0x223/0x2a0
> > [365724.503268]  [<ffffffff811fe838>] alloc_pages_current+0x88/0x120
> > [365724.503270]  [<ffffffff811a3644>] __page_cache_alloc+0xb4/0xc0
> > [365724.503272]  [<ffffffff811a49e9>] pagecache_get_page+0x59/0x230
> > [365724.503275]  [<ffffffff8126b2db>] __getblk_gfp+0xfb/0x2f0
> > [365724.503281]  [<ffffffffa00f9cee>]
> > jbd2_journal_get_descriptor_buffer+0x5e/0xe0 [jbd2]
> > [365724.503286]  [<ffffffffa00f2a01>]
> > jbd2_journal_commit_transaction+0x901/0x1880 [jbd2]
> > [365724.503291]  [<ffffffff8102d6a5>] ? __switch_to+0x215/0x730
> > [365724.503294]  [<ffffffff810f962d>] ? lock_timer_base+0x7d/0xa0
> > [365724.503298]  [<ffffffffa00f7cda>] kjournald2+0xca/0x260 [jbd2]
> > [365724.503300]  [<ffffffff810cfb00>] ? prepare_to_wait_event+0xf0/0xf0
> > [365724.503304]  [<ffffffffa00f7c10>] ? commit_timeout+0x10/0x10 [jbd2]
> > [365724.503307]  [<ffffffff810a8d66>] kthread+0xe6/0x100
> > [365724.503309]  [<ffffffff810a8c80>] ? kthread_park+0x60/0x60
> > [365724.503313]  [<ffffffff816f3795>] ret_from_fork+0x25/0x30
> > 
> > we can limit the warn_alloc caller to workaround it.
> > __alloc_pages_slowpath only call once warn_alloc each time.
> 
> similar attempts to add a lock there were tried in the past and refused.

Wang already read that thread before proposing this patch.

> Anyway using a normal lock would be preferred over a bit lock. But the
> most important part is to identify _why_ we see the lockup trigerring in
> the first place. And try to fix it rather than workaround it here.

The bitlock is what Andrew thought at
http://lkml.kernel.org/r/20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org .
I'm OK with using a normal lock.

This patch does not make callers of warn_alloc() sleep. This is different from
past attempt.

You said "identify _why_ we see the lockup trigerring in the first place" without
providing means to identify it. Unless you provide means to identify it (in a form
which can be immediately and easily backported to 4.9 kernels; that is, backporting
not-yet-accepted printk() offloading patchset is not a choice), this patch cannot be
refused.

> 
> > Signed-off-by: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
> > Suggested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> > ---
> >  mm/page_alloc.c | 7 +++++--
> >  1 file changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2abf8d5..8b86686 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3525,6 +3525,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> >  	unsigned long alloc_start = jiffies;
> >  	unsigned int stall_timeout = 10 * HZ;
> >  	unsigned int cpuset_mems_cookie;
> > +	static unsigned long stall_warn_lock;
> >  
> >  	/*
> >  	 * In the slowpath, we sanity check order to avoid ever trying to
> > @@ -3698,11 +3699,13 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> >  		goto nopage;
> >  
> >  	/* Make sure we know about allocations which stall for too long */
> > -	if (time_after(jiffies, alloc_start + stall_timeout)) {
> > +	if (time_after(jiffies, alloc_start + stall_timeout) &&
> > +		!test_and_set_bit_lock(0, &stall_warn_lock)) {
> >  		warn_alloc(gfp_mask,
> >  			"page allocation stalls for %ums, order:%u",
> >  			jiffies_to_msecs(jiffies-alloc_start), order);
> > -		stall_timeout += 10 * HZ;
> > +		stall_timeout = jiffies - alloc_start + 10 * HZ;
> > +		clear_bit_unlock(0, &stall_warn_lock);
> >  	}
> >  
> >  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> > -- 
> > 1.8.3.1
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
