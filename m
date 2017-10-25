Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2C26B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 11:35:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u70so204312pfa.2
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 08:35:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 12si1732003pld.340.2017.10.25.08.35.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 08:35:37 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171024114104.twg73jvyjevovkjm@dhcp22.suse.cz>
	<201710251948.EJH00500.MOOStFLFQOHFJV@I-love.SAKURA.ne.jp>
	<20171025110955.jsc4lqjbg6ww5va6@dhcp22.suse.cz>
	<201710252115.JII86453.tFFSLHQOOOVMJF@I-love.SAKURA.ne.jp>
	<20171025124147.bvd4huwtykf6icmb@dhcp22.suse.cz>
In-Reply-To: <20171025124147.bvd4huwtykf6icmb@dhcp22.suse.cz>
Message-Id: <201710252358.IIA46427.HFFSOOOQLtFMJV@I-love.SAKURA.ne.jp>
Date: Wed, 25 Oct 2017 23:58:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: hannes@cmpxchg.org, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Wed 25-10-17 21:15:24, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 25-10-17 19:48:09, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > [...]
> > > > > The OOM killer is the last hand break. At the time you hit the OOM
> > > > > condition your system is usually hard to use anyway. And that is why I
> > > > > do care to make this path deadlock free. I have mentioned multiple times
> > > > > that I find real life triggers much more important than artificial DoS
> > > > > like workloads which make your system unsuable long before you hit OOM
> > > > > killer.
> > > > 
> > > > Unable to invoke the OOM killer (i.e. OOM lockup) is worse than hand break injury.
> > > > 
> > > > If you do care to make this path deadlock free, you had better stop depending on
> > > > mutex_trylock(&oom_lock). Not only printk() from oom_kill_process() can trigger
> > > > deadlock due to console_sem versus oom_lock dependency but also
> > > 
> > > And this means that we have to fix printk. Completely silent oom path is
> > > out of question IMHO
> > 
> > We cannot fix printk() without giving enough CPU resource to printk().
> 
> This is a separate discussion but having a basically unbound time spent
> in printk is simply a no-go.
>  
> > I don't think "Completely silent oom path" can happen, for warn_alloc() is called
> > again when it is retried. But anyway, let's remove warn_alloc().
> 
> I mean something else. We simply cannot do the oom killing without
> telling userspace about that. And printk is the only API we can use for
> that.

I thought something like

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3872,6 +3872,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
        unsigned int stall_timeout = 10 * HZ;
        unsigned int cpuset_mems_cookie;
        int reserve_flags;
+       static DEFINE_MUTEX(warn_lock);

        /*
         * In the slowpath, we sanity check order to avoid ever trying to
@@ -4002,11 +4003,15 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
                goto nopage;

        /* Make sure we know about allocations which stall for too long */
-       if (time_after(jiffies, alloc_start + stall_timeout)) {
-               warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
-                       "page allocation stalls for %ums, order:%u",
-                       jiffies_to_msecs(jiffies-alloc_start), order);
-               stall_timeout += 10 * HZ;
+       if (time_after(jiffies, alloc_start + stall_timeout) &&
+           mutex_trylock(&warn_lock)) {
+               if (!mutex_is_locked(&oom_lock)) {
+                       warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
+                                  "page allocation stalls for %ums, order:%u",
+                                  jiffies_to_msecs(jiffies-alloc_start), order);
+                       stall_timeout += 10 * HZ;
+               }
+               mutex_unlock(&warn_lock);
        }

        /* Avoid recursion of direct reclaim */

for isolating the OOM killer messages and the stall warning messages (in order to
break continuation condition in console_unlock()), and

@@ -3294,7 +3294,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */
-       if (!mutex_trylock(&oom_lock)) {
+       if (mutex_lock_killable(&oom_lock)) {
                *did_some_progress = 1;
                schedule_timeout_uninterruptible(1);
                return NULL;

for giving printk() enough CPU resource.

What you thought is avoid using printk() from out_of_memory() in case enough
CPU resource is not given, isn't it? Then, that is out of question.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
