Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD976B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 12:25:33 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so74913162wgb.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 09:25:32 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id kc1si18926147wjc.145.2015.03.30.09.25.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 09:25:32 -0700 (PDT)
Date: Mon, 30 Mar 2015 18:25:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150330162519.GB23123@twins.programming.kicks-ass.net>
References: <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
 <20150328095322.GH27490@worktop.programming.kicks-ass.net>
 <55169723.3070006@linaro.org>
 <20150328134457.GK27490@worktop.programming.kicks-ass.net>
 <20150329102440.GC32047@worktop.ger.corp.intel.com>
 <CAKohpon2GSpk+6pNuHEsDC55hHtowwfGJivPM0Gh0wt1A2cd-w@mail.gmail.com>
 <20150330124746.GI21418@twins.programming.kicks-ass.net>
 <CAKohpo=2_v8n+tnrEbb4bYAxU8cgA+OWpTNe8XX3yjpzL4ySGw@mail.gmail.com>
 <20150330135948.GY23123@twins.programming.kicks-ass.net>
 <CAKohponEAivnev-fcWdjD0OcwQaXHN58tESCfqbZ_-W+_N+DvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKohponEAivnev-fcWdjD0OcwQaXHN58tESCfqbZ_-W+_N+DvA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Mar 30, 2015 at 09:47:01PM +0530, Viresh Kumar wrote:
> And all I get it is 8256 bytes, with or without the change.

Duh, rounded up to cacheline boundary ;-)

Trades two 4 byte holes at the start for a bigger 'hole' at the end.

struct tvec_base {
        spinlock_t                 lock;                 /*     0     2 */

        /* XXX 6 bytes hole, try to pack */

        struct timer_list *        running_timer;        /*     8     8 */
        long unsigned int          timer_jiffies;        /*    16     8 */
        long unsigned int          next_timer;           /*    24     8 */
        long unsigned int          active_timers;        /*    32     8 */
        long unsigned int          all_timers;           /*    40     8 */
        int                        cpu;                  /*    48     4 */

        /* XXX 4 bytes hole, try to pack */

        struct tvec_root           tv1;                  /*    56  4096 */
        /* --- cacheline 64 boundary (4096 bytes) was 56 bytes ago --- */
        struct tvec                tv2;                  /*  4152  1024 */
        /* --- cacheline 80 boundary (5120 bytes) was 56 bytes ago --- */
        struct tvec                tv3;                  /*  5176  1024 */
        /* --- cacheline 96 boundary (6144 bytes) was 56 bytes ago --- */
        struct tvec                tv4;                  /*  6200  1024 */
        /* --- cacheline 112 boundary (7168 bytes) was 56 bytes ago --- */
        struct tvec                tv5;                  /*  7224  1024 */
        /* --- cacheline 128 boundary (8192 bytes) was 56 bytes ago --- */

        /* size: 8256, cachelines: 129, members: 12 */
        /* sum members: 8238, holes: 2, sum holes: 10 */
        /* padding: 8 */
};

vs

struct tvec_base {
	spinlock_t                 lock;                 /*     0     2 */

	/* XXX 2 bytes hole, try to pack */

	int                        cpu;                  /*     4     4 */
	struct timer_list *        running_timer;        /*     8     8 */
	long unsigned int          timer_jiffies;        /*    16     8 */
	long unsigned int          next_timer;           /*    24     8 */
	long unsigned int          active_timers;        /*    32     8 */
	long unsigned int          all_timers;           /*    40     8 */
	struct tvec_root           tv1;                  /*    48  4096 */
	/* --- cacheline 64 boundary (4096 bytes) was 48 bytes ago --- */
	struct tvec                tv2;                  /*  4144  1024 */
	/* --- cacheline 80 boundary (5120 bytes) was 48 bytes ago --- */
	struct tvec                tv3;                  /*  5168  1024 */
	/* --- cacheline 96 boundary (6144 bytes) was 48 bytes ago --- */
	struct tvec                tv4;                  /*  6192  1024 */
	/* --- cacheline 112 boundary (7168 bytes) was 48 bytes ago --- */
	struct tvec                tv5;                  /*  7216  1024 */
	/* --- cacheline 128 boundary (8192 bytes) was 48 bytes ago --- */

	/* size: 8256, cachelines: 129, members: 12 */
	/* sum members: 8238, holes: 1, sum holes: 2 */
	/* padding: 16 */
};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
