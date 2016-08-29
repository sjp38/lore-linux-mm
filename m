Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF67B83102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 12:48:16 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id le9so276921489pab.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:48:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 68si39943190pfr.68.2016.08.29.09.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 09:48:16 -0700 (PDT)
Date: Mon, 29 Aug 2016 18:48:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
Message-ID: <20160829164809.GW10153@twins.programming.kicks-ass.net>
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Aug 29, 2016 at 12:40:32PM -0400, Chris Metcalf wrote:
> On 8/29/2016 12:33 PM, Peter Zijlstra wrote:
> >On Tue, Aug 16, 2016 at 05:19:27PM -0400, Chris Metcalf wrote:
> >>+	/*
> >>+	 * Request rescheduling unless we are in full dynticks mode.
> >>+	 * We would eventually get pre-empted without this, and if
> >>+	 * there's another task waiting, it would run; but by
> >>+	 * explicitly requesting the reschedule, we may reduce the
> >>+	 * latency.  We could directly call schedule() here as well,
> >>+	 * but since our caller is the standard place where schedule()
> >>+	 * is called, we defer to the caller.
> >>+	 *
> >>+	 * A more substantive approach here would be to use a struct
> >>+	 * completion here explicitly, and complete it when we shut
> >>+	 * down dynticks, but since we presumably have nothing better
> >>+	 * to do on this core anyway, just spinning seems plausible.
> >>+	 */
> >>+	if (!tick_nohz_tick_stopped())
> >>+		set_tsk_need_resched(current);
> >This is broken.. and it would be really good if you don't actually need
> >to do this.
> 
> Can you elaborate?  

Naked use of TIF_NEED_RESCHED like this is busted. There is more state
that needs to be poked to keep things consistent / working.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
