Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C986C6B0038
	for <linux-mm@kvack.org>; Sat, 23 Sep 2017 21:57:06 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f3so3521167oia.4
        for <linux-mm@kvack.org>; Sat, 23 Sep 2017 18:57:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k134si1820558oib.103.2017.09.23.18.57.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Sep 2017 18:57:05 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201709152038.BHF26323.LFOMFHOFOJSVQt@I-love.SAKURA.ne.jp>
	<20170915120020.diakzyzsx73ygnfx@dhcp22.suse.cz>
	<201709152109.AID48261.FtHOFMFQOJVLOS@I-love.SAKURA.ne.jp>
	<20170915121401.eaoncsmahh2stqn2@dhcp22.suse.cz>
	<201709152312.EGB69283.VFQOOtFMOFHJSL@I-love.SAKURA.ne.jp>
In-Reply-To: <201709152312.EGB69283.VFQOOtFMOFHJSL@I-love.SAKURA.ne.jp>
Message-Id: <201709241056.EHE17127.VJLFSFMFOQOOtH@I-love.SAKURA.ne.jp>
Date: Sun, 24 Sep 2017 10:56:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yuwang668899@gmail.com
Cc: mhocko@suse.com, vbabka@suse.cz, mpatocka@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com

Tetsuo Handa wrote:
> Assuming that Wang Yu's trace has
> 
>   RIP: 0010:[<...>]  [<...>] dump_stack+0x.../0x...
> 
> line in the omitted part (like Cong Wang's trace did), I suspect that a thread
> which is holding dump_lock is unable to leave console_unlock() from printk() for
> so long because many other threads are trying to call printk() from warn_alloc()
> while consuming all CPU time.
> 
> Thus, not allowing other threads to consume CPU time / call printk() is a step for
> isolating it. If this problem still exists even if we made other threads sleep,
> the real cause will be somewhere else. But unfortunately Cong Wang has not yet
> succeeded with reproducing the problem. If Wang Yu is able to reproduce the problem,
> we can try setting 1 to /proc/sys/kernel/softlockup_all_cpu_backtrace so that
> we can know what other CPUs are doing.

It seems that Johannes needs more time for getting a test result from production
environment. Meanwhile, for use as a reference, Wang, do you have a chance to retry
your stress test with /proc/sys/kernel/softlockup_all_cpu_backtrace set to 1 ?
I don't have access to environments with many CPUs...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
