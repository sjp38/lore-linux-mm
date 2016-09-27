Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD3FE6B02A8
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:48:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v67so32871305pfv.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:48:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 13si3052610pfk.66.2016.09.27.07.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 07:48:08 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8REm0KI081243
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:48:07 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25qmu232gp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:48:07 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 27 Sep 2016 08:48:06 -0600
Date: Tue, 27 Sep 2016 07:48:00 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
Reply-To: paulmck@linux.vnet.ibm.com
References: <20160830075854.GZ10153@twins.programming.kicks-ass.net>
 <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com>
 <CALCETrWyKExm9Od3VJ2P9xbL23NPKScgxdQ4R1v5QdNuNXKjmA@mail.gmail.com>
 <e659a498-d951-7d9f-dc0c-9734be3fd826@mellanox.com>
 <CALCETrXA38kv_PEd65j8RHvJKkW5mMxXEmYSr5mec1h3X1hj1w@mail.gmail.com>
 <d15b35ce-5c5d-c451-e47e-d2f915bf70f3@mellanox.com>
 <CALCETrX80akvpLNRQfJsDV560npSa33hSsUB5OYkAtnAn8R7Dg@mail.gmail.com>
 <3f84f736-ed7f-adff-d5f0-4f7db664208f@mellanox.com>
 <CALCETrXrsZjMjdd1jACbrz8GMXQC5FmF8BbkHobmMCbG5GPN7w@mail.gmail.com>
 <20160927142219.GC6242@lerouge>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160927142219.GC6242@lerouge>
Message-Id: <20160927144800.GE14933@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Gilad Ben Yossef <giladb@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Viresh Kumar <viresh.kumar@linaro.org>, Linux API <linux-api@vger.kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Sep 27, 2016 at 04:22:20PM +0200, Frederic Weisbecker wrote:
> On Fri, Sep 02, 2016 at 10:28:00AM -0700, Andy Lutomirski wrote:
> > 
> > Unless I'm missing something (which is reasonably likely), couldn't
> > the isolation code just force or require rcu_nocbs on the isolated
> > CPUs to avoid this problem entirely.
> 
> rcu_nocb is already implied by nohz_full. Which means that RCU callbacks
> are offlined outside the nohz_full set of CPUs.

Indeed, at boot time, RCU makes any nohz_full CPU also be a rcu_nocb
CPU.

> > I admit I still don't understand why the RCU context tracking code
> > can't just run the callback right away instead of waiting however many
> > microseconds in general.  I feel like paulmck has explained it to me
> > at least once, but that doesn't mean I remember the answer.
> 
> The RCU context tracking doesn't take care of callbacks. It's only there
> to tell the RCU core whether the CPU runs code that may or may not run
> RCU read side critical sections. This is assumed by "kernel may use RCU,
> userspace can't".

And RCU has to wait for read-side critical sections to complete before
invoking callbacks.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
