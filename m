Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9696B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 10:13:00 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m103so6308701iod.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:13:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p71si667714oie.159.2017.09.15.07.12.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 07:12:58 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170915103957.64r5xln7s6wlu3ro@dhcp22.suse.cz>
	<201709152038.BHF26323.LFOMFHOFOJSVQt@I-love.SAKURA.ne.jp>
	<20170915120020.diakzyzsx73ygnfx@dhcp22.suse.cz>
	<201709152109.AID48261.FtHOFMFQOJVLOS@I-love.SAKURA.ne.jp>
	<20170915121401.eaoncsmahh2stqn2@dhcp22.suse.cz>
In-Reply-To: <20170915121401.eaoncsmahh2stqn2@dhcp22.suse.cz>
Message-Id: <201709152312.EGB69283.VFQOOtFMOFHJSL@I-love.SAKURA.ne.jp>
Date: Fri, 15 Sep 2017 23:12:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: yuwang668899@gmail.com, vbabka@suse.cz, mpatocka@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com

Michal Hocko wrote:
> On Fri 15-09-17 21:09:29, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 15-09-17 20:38:49, Tetsuo Handa wrote:
> > > [...]
> > > > You said "identify _why_ we see the lockup trigerring in the first
> > > > place" without providing means to identify it. Unless you provide
> > > > means to identify it (in a form which can be immediately and easily
> > > > backported to 4.9 kernels; that is, backporting not-yet-accepted
> > > > printk() offloading patchset is not a choice), this patch cannot be
> > > > refused.
> > > 
> > > I fail to see why. It simply workarounds an existing problem elsewhere
> > > in the kernel without deeper understanding on where the problem is. You
> > > can add your own instrumentation to debug and describe the problem. This
> > > is no different to any other kernel bugs...
> > 
> > Please do show us your patch for that. Normal users cannot afford developing
> > such instrumentation to debug and describe the problem.
> 
> Stop this nonsense already! Any kernel bug/lockup needs a debugging
> which might be non-trivial and it is necessary to understand the real
> culprit. We do not add random hacks to silence a problem. We aim at
> fixing it!

Assuming that Wang Yu's trace has

  RIP: 0010:[<...>]  [<...>] dump_stack+0x.../0x...

line in the omitted part (like Cong Wang's trace did), I suspect that a thread
which is holding dump_lock is unable to leave console_unlock() from printk() for
so long because many other threads are trying to call printk() from warn_alloc()
while consuming all CPU time.

Thus, not allowing other threads to consume CPU time / call printk() is a step for
isolating it. If this problem still exists even if we made other threads sleep,
the real cause will be somewhere else. But unfortunately Cong Wang has not yet
succeeded with reproducing the problem. If Wang Yu is able to reproduce the problem,
we can try setting 1 to /proc/sys/kernel/softlockup_all_cpu_backtrace so that
we can know what other CPUs are doing.

>  
> > > If our printk implementation is so weak it cannot cope with writers then
> > > that should be fixed without spreading hacks in different subsystems. If
> > > the lockup is a real problem under normal workloads (rather than
> > > artificial ones) then we should try to throttle more aggresively.
> > 
> > No throttle please. Throttling makes warn_alloc() more and more useless.
> 
> so does try_lock approach...

There is mutex_lock() approach, but you don't agree on using it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
