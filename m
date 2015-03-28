Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6EF6B006E
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 07:57:34 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so123344538pdb.1
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 04:57:33 -0700 (PDT)
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com. [209.85.192.169])
        by mx.google.com with ESMTPS id ol15si6719198pdb.157.2015.03.28.04.57.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Mar 2015 04:57:33 -0700 (PDT)
Received: by pddn5 with SMTP id n5so7198448pdd.2
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 04:57:32 -0700 (PDT)
Message-ID: <55169723.3070006@linaro.org>
Date: Sat, 28 Mar 2015 17:27:23 +0530
From: viresh kumar <viresh.kumar@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org> <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org> <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com> <20150327091613.GE27490@worktop.programming.kicks-ass.net> <20150327093023.GA32047@worktop.ger.corp.intel.com> <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com> <20150328095322.GH27490@worktop.programming.kicks-ass.net>
In-Reply-To: <20150328095322.GH27490@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On 28 March 2015 at 15:23, Peter Zijlstra <peterz@infradead.org> wrote:

> Well, for one your patch is indeed disgusting.

Yeah, I agree :)

> But yes I'm aware Thomas
> wants to rewrite the timer thing. But Thomas is away for a little while
> and if this really needs to happen then it does.

Sometime back I was trying to use another bit from base pointer for
marking a timer as PINNED:

diff --git a/include/linux/timer.h b/include/linux/timer.h
index 8c5a197e1587..e7184f57449c 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -67,8 +67,9 @@ extern struct tvec_base boot_tvec_bases;
  */
 #define TIMER_DEFERRABLE               0x1LU
 #define TIMER_IRQSAFE                  0x2LU
+#define TIMER_PINNED                   0x4LU
 -#define TIMER_FLAG_MASK                        0x3LU
+#define TIMER_FLAG_MASK                        0x7LU


And Fenguang's build-bot showed the problem (only) on blackfin [1].

        config: make ARCH=blackfin allyesconfig

        All error/warnings:

           kernel/timer.c: In function 'init_timers':
        >> kernel/timer.c:1683:2: error: call to '__compiletime_assert_1683'
        >> declared with attribute error: BUILD_BUG_ON failed:
        >> __alignof__(struct tvec_base) & TIMER_FLAG_MASK


So probably we need to make 'base' aligned to 8 bytes ?



So, what you are suggesting is something like this (untested):

diff --git a/include/linux/timer.h b/include/linux/timer.h
index 8c5a197e1587..68bf09d69352 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -67,8 +67,9 @@ extern struct tvec_base boot_tvec_bases;
  */
 #define TIMER_DEFERRABLE               0x1LU
 #define TIMER_IRQSAFE                  0x2LU
+#define TIMER_RUNNING                  0x4LU

-#define TIMER_FLAG_MASK                        0x3LU
+#define TIMER_FLAG_MASK                        0x7LU

 #define __TIMER_INITIALIZER(_function, _expires, _data, _flags) { \
                .entry = { .prev = TIMER_ENTRY_STATIC },        \
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 2d3f5c504939..8f9efa64bd34 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -105,6 +105,21 @@ static inline unsigned int tbase_get_irqsafe(struct tvec_base *base)
        return ((unsigned int)(unsigned long)base & TIMER_IRQSAFE);
 }

+static inline unsigned int tbase_get_running(struct tvec_base *base)
+{
+       return ((unsigned int)(unsigned long)base & TIMER_RUNNING);
+}
+
+static inline unsigned int tbase_set_running(struct tvec_base *base)
+{
+       return ((unsigned int)(unsigned long)base | TIMER_RUNNING);
+}
+
+static inline unsigned int tbase_clear_running(struct tvec_base *base)
+{
+       return ((unsigned int)(unsigned long)base & ~TIMER_RUNNING);
+}
+
 static inline struct tvec_base *tbase_get_base(struct tvec_base *base)
 {
        return ((struct tvec_base *)((unsigned long)base & ~TIMER_FLAG_MASK));
@@ -781,21 +796,12 @@ __mod_timer(struct timer_list *timer, unsigned long expires,
        new_base = per_cpu(tvec_bases, cpu);

        if (base != new_base) {
-               /*
-                * We are trying to schedule the timer on the local CPU.
-                * However we can't change timer's base while it is running,
-                * otherwise del_timer_sync() can't detect that the timer's
-                * handler yet has not finished. This also guarantees that
-                * the timer is serialized wrt itself.
-                */
-               if (likely(base->running_timer != timer)) {
-                       /* See the comment in lock_timer_base() */
-                       timer_set_base(timer, NULL);
-                       spin_unlock(&base->lock);
-                       base = new_base;
-                       spin_lock(&base->lock);
-                       timer_set_base(timer, base);
-               }
+               /* See the comment in lock_timer_base() */
+               timer_set_base(timer, NULL);
+               spin_unlock(&base->lock);
+               base = new_base;
+               spin_lock(&base->lock);
+               timer_set_base(timer, base);
        }

        timer->expires = expires;
@@ -1016,7 +1022,7 @@ int try_to_del_timer_sync(struct timer_list *timer)

        base = lock_timer_base(timer, &flags);

-       if (base->running_timer != timer) {
+       if (tbase_get_running(timer->base)) {
                timer_stats_timer_clear_start_info(timer);
                ret = detach_if_pending(timer, base, true);
        }
@@ -1202,6 +1208,7 @@ static inline void __run_timers(struct tvec_base *base)
                        timer_stats_account_timer(timer);

                        base->running_timer = timer;
+                       tbase_set_running(timer->base);
                        detach_expired_timer(timer, base);

                        if (irqsafe) {
@@ -1216,6 +1223,7 @@ static inline void __run_timers(struct tvec_base *base)
                }
        }
        base->running_timer = NULL;
+       tbase_clear_running(timer->base);
        spin_unlock_irq(&base->lock);
 }

------------x--------------------x----------------------

Right?


Now there are few issues I see here (Sorry if they are all imaginary):
- In case a timer re-arms itself from its handler and is migrated from CPU A to B, what
  happens if the re-armed timer fires before the first handler finishes ? i.e. timer->fn()
  hasn't finished running on CPU A and it has fired again on CPU B. Wouldn't this expose
  us to a lot of other problems? It wouldn't be serialized to itself anymore ?

- Because the timer has migrated to another CPU, the locking in __run_timers()
  needs to be fixed. And that will make it complicated ..

  - __run_timer() doesn't lock bases of other CPUs, and it has to do it now..
  - We probably need to take locks of both local CPU and the one to which timer migrated.

- Its possible now that there can be more than one running timer for a base, which wasn't
  true earlier. Not sure if it will break something.


Thanks for your continuous support to reply to my (sometimes stupid) queries.

--
viresh

[1] https://lists.01.org/pipermail/kbuild-all/2014-April/003982.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
