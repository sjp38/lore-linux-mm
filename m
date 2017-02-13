Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1198B6B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 14:52:54 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y196so637263ity.1
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 11:52:54 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u12si496259ite.32.2017.02.13.11.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 11:52:53 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1DJi6IO011763
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 14:52:52 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28kjhvhp8e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 14:52:52 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 13 Feb 2017 12:52:51 -0700
Date: Mon, 13 Feb 2017 11:52:49 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC v2 tip/core/rcu] Maintain special bits at bottom of
 ->dynticks counter
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170209235103.GA1368@linux.vnet.ibm.com>
 <20170213122115.GO6515@twins.programming.kicks-ass.net>
 <20170213170104.GC30506@linux.vnet.ibm.com>
 <20170213175750.GJ6500@twins.programming.kicks-ass.net>
 <CALCETrXwUeaRbDziA=7vgY3_r9u3E2wLLRwAU=GEiNhYq9jJwg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXwUeaRbDziA=7vgY3_r9u3E2wLLRwAU=GEiNhYq9jJwg@mail.gmail.com>
Message-Id: <20170213195249.GN30506@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Ingo Molnar <mingo@kernel.org>

On Mon, Feb 13, 2017 at 11:08:55AM -0800, Andy Lutomirski wrote:
> On Mon, Feb 13, 2017 at 9:57 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Mon, Feb 13, 2017 at 09:01:04AM -0800, Paul E. McKenney wrote:
> >> > I think I've asked this before, but why does this live in the guts of
> >> > RCU?
> >> >
> >> > Should we lift this state tracking stuff out and make RCU and
> >> > NOHZ(_FULL) users of it, or doesn't that make sense (reason)?
> >>
> >> The dyntick-idle stuff is pretty specific to RCU.  And what precisely
> >> would be helped by moving it?
> >
> > Maybe untangle the inter-dependencies somewhat. It just seems a wee bit
> > odd to have arch TLB invalidate depend on RCU implementation details
> > like this.
> 
> This came out of a courtyard discussion at KS/LPC.  The idea is that
> this optimzation requires an atomic op that could be shared with RCU
> and that we probably care a lot more about this optimization on
> kernels with context tracking enabled, so putting it in RCU has nice
> performance properties.  Other than that, it doesn't make a huge
> amount of sense.
> 
> Amusingly, Darwin appears to do something similar without an atomic
> op, and I have no idea why that's safe.

Given that they run on ARM, I have no idea either.  Maybe they don't
need to be quite as bulletproof on idle-duration detection?  Rumor has it
that their variant of RCU uses program-counter ranges, so they wouldn't
have the RCU tie-in -- just checks of program-counter ranges and
interesting dependencies on the compiler.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
