Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 402B86B0039
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:51:15 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id o15so8095233qap.3
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:51:15 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id q6si9343318qag.88.2013.11.25.15.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 15:51:14 -0800 (PST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 25 Nov 2013 16:51:13 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D3BB61FF001F
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:50:52 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAPLnNkX37880056
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 22:49:23 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAPNs6x2021832
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:54:08 -0700
Date: Mon, 25 Nov 2013 15:51:06 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131125235106.GZ4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131121172558.GA27927@linux.vnet.ibm.com>
 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
 <20131121221859.GH4138@linux.vnet.ibm.com>
 <20131122155835.GR3866@twins.programming.kicks-ass.net>
 <20131122182632.GW4138@linux.vnet.ibm.com>
 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
 <20131125173540.GK3694@twins.programming.kicks-ass.net>
 <52939C5A.3070208@zytor.com>
 <1385420302.11046.539.camel@schen9-DESK>
 <5293DD20.4020904@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5293DD20.4020904@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Nov 25, 2013 at 03:28:32PM -0800, H. Peter Anvin wrote:
> On 11/25/2013 02:58 PM, Tim Chen wrote:
> > 
> > Peter,
> > 
> > Want to check with you on Paul's example, 
> > where we are indeed writing and reading to the same
> > lock location when passing the lock on x86 with smp_store_release and
> > smp_load_acquire.  So the unlock and lock sequence looks like:
> > 
> >         CPU 0 (releasing)       CPU 1 (acquiring)
> >         -----                   -----
> >         ACCESS_ONCE(X) = 1;     while (ACCESS_ONCE(lock) == 1)
> >                                   continue;
> >         ACCESS_ONCE(lock) = 0;  
> >                                 r1 = ACCESS_ONCE(Y);
> > 
> 
> Here we can definitely state that the read from Y must have happened
> after X was set to 1 (assuming lock starts out as 1).
> 
> > observer CPU 2:
> > 
> >         CPU 2
> >         -----
> >         ACCESS_ONCE(Y) = 1;
> >         smp_mb();
> >         r2 = ACCESS_ONCE(X);
> > 
> > If the write and read to lock act as a full memory barrier, 
> > it would be impossible to
> > end up with (r1 == 0 && r2 == 0), correct?
> > 
> 
> It would be impossible to end up with r1 == 1 && r2 == 0, I presume
> that's what you meant.

Yes, that is the correct impossibility.  Thank you, Peter!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
