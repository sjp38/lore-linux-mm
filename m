Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 775C16B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 13:59:42 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so1714639obc.21
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 10:59:42 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id pp9si22454797obc.141.2013.11.22.10.59.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 10:59:41 -0800 (PST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 22 Nov 2013 11:59:40 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 45CAA1FF001C
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 11:59:20 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAMGvdNk9830694
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 17:57:39 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAMJ2Uqo004489
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:02:33 -0700
Date: Fri, 22 Nov 2013 10:59:32 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131122185932.GZ4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131120171400.GI4138@linux.vnet.ibm.com>
 <20131121110308.GC10022@twins.programming.kicks-ass.net>
 <20131121125616.GI3694@twins.programming.kicks-ass.net>
 <20131121132041.GS4138@linux.vnet.ibm.com>
 <20131121172558.GA27927@linux.vnet.ibm.com>
 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
 <20131121221859.GH4138@linux.vnet.ibm.com>
 <20131122155835.GR3866@twins.programming.kicks-ass.net>
 <20131122182632.GW4138@linux.vnet.ibm.com>
 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 07:51:07PM +0100, Peter Zijlstra wrote:
> On Fri, Nov 22, 2013 at 10:26:32AM -0800, Paul E. McKenney wrote:
> > The real source of my cognitive pain is that here we have a sequence of
> > code that has neither atomic instructions or memory-barrier instructions,
> > but it looks like it still manages to act as a full memory barrier.
> > Still not quite sure I should trust it...
> 
> Yes, this is something that puzzles me too.
> 
> That said, the two rules that:
> 
> 1)  stores aren't re-ordered against other stores
> 2)  reads aren't re-ordered against other reads
> 
> Do make that:
> 
> 	STORE x
> 	LOAD  x
> 
> form a fence that neither stores nor loads can pass through from
> either side; note however that they themselves rely on the data
> dependency to not reorder against themselves.
> 
> If you put them the other way around:
> 
> 	LOAD x
> 	STORE y
> 
> we seem to get a stronger variant because stores are not re-ordered
> against older reads.
> 
> There is however the exception cause for rule 1) above, which includes
> clflush, non-temporal stores and string ops; the actual mfence
> instruction doesn't seem to have this exception and would thus be
> slightly stronger still.
> 
> Still confusion situation all round.

At some point, we need people from Intel and AMD to look at it.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
