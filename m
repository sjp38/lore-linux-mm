Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 602B6900015
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 12:17:16 -0400 (EDT)
Received: by obcjt1 with SMTP id jt1so126424932obc.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 09:17:16 -0700 (PDT)
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com. [209.85.214.170])
        by mx.google.com with ESMTPS id sa5si6416176oeb.7.2015.03.30.09.17.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 09:17:09 -0700 (PDT)
Received: by obvd1 with SMTP id d1so62266592obv.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 09:17:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150330135948.GY23123@twins.programming.kicks-ass.net>
References: <20150327091613.GE27490@worktop.programming.kicks-ass.net>
	<20150327093023.GA32047@worktop.ger.corp.intel.com>
	<CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
	<20150328095322.GH27490@worktop.programming.kicks-ass.net>
	<55169723.3070006@linaro.org>
	<20150328134457.GK27490@worktop.programming.kicks-ass.net>
	<20150329102440.GC32047@worktop.ger.corp.intel.com>
	<CAKohpon2GSpk+6pNuHEsDC55hHtowwfGJivPM0Gh0wt1A2cd-w@mail.gmail.com>
	<20150330124746.GI21418@twins.programming.kicks-ass.net>
	<CAKohpo=2_v8n+tnrEbb4bYAxU8cgA+OWpTNe8XX3yjpzL4ySGw@mail.gmail.com>
	<20150330135948.GY23123@twins.programming.kicks-ass.net>
Date: Mon, 30 Mar 2015 21:47:01 +0530
Message-ID: <CAKohponEAivnev-fcWdjD0OcwQaXHN58tESCfqbZ_-W+_N+DvA@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On 30 March 2015 at 19:29, Peter Zijlstra <peterz@infradead.org> wrote:
> Yeah, so that _should_ not trigger (obviously), and while I agree with
> the sentiment of sanity checks, I'm not sure its worth keeping that
> variable around just for that.

I read it as I can remove it then ? :)

> Anyway, while I'm looking at struct tvec_base I notice the cpu member
> should be second after the lock, that'll save 8 bytes on the structure
> on 64bit machines.

Hmm, I tried it on my macbook-pro.

$ uname -a
Linux vireshk 3.13.0-46-generic #79-Ubuntu SMP Tue Mar 10 20:06:50 UTC
2015 x86_64 x86_64 x86_64 GNU/Linux

$ gcc --version
gcc (Ubuntu 4.8.2-19ubuntu1) 4.8.2

config: arch/x86/configs/x86_64_defconfig

And all I get it is 8256 bytes, with or without the change.

diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 2d3f5c504939..afc5d74678df 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -77,12 +77,12 @@ struct tvec_root {

 struct tvec_base {
        spinlock_t lock;
+       int cpu;
        struct timer_list *running_timer;
        unsigned long timer_jiffies;
        unsigned long next_timer;
        unsigned long active_timers;
        unsigned long all_timers;
-       int cpu;
        struct tvec_root tv1;
        struct tvec tv2;
        struct tvec tv3;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
