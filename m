Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 536AF6B0035
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 12:38:54 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id w5so2883512qac.7
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 09:38:54 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id a4si11086786qar.172.2013.11.30.09.38.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 30 Nov 2013 09:38:53 -0800 (PST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 30 Nov 2013 10:38:52 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B18241FF0021
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 10:38:29 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAUFaxR341746476
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 16:36:59 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAUHfkmN007016
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 10:41:48 -0700
Date: Sat, 30 Nov 2013 09:38:43 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131130173843.GZ4137@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131127101613.GC9032@mudshark.cambridge.arm.com>
 <20131127171143.GN4137@linux.vnet.ibm.com>
 <20131128114058.GC21354@mudshark.cambridge.arm.com>
 <20131128173853.GV4137@linux.vnet.ibm.com>
 <20131128180318.GE16203@mudshark.cambridge.arm.com>
 <20131128182712.GW4137@linux.vnet.ibm.com>
 <20131128185341.GG16203@mudshark.cambridge.arm.com>
 <20131128195039.GX4137@linux.vnet.ibm.com>
 <20131129161711.GG31000@mudshark.cambridge.arm.com>
 <CA+55aFwHgnH4h0YwybThQjvicFCVbGbwaAy3Fw0b738gJMtqBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwHgnH4h0YwybThQjvicFCVbGbwaAy3Fw0b738gJMtqBA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "Figo. zhang" <figo1802@gmail.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Rik van Riel <riel@redhat.com>, Waiman Long <waiman.long@hp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, George Spelvin <linux@horizon.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Alex Shi <alex.shi@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Fri, Nov 29, 2013 at 08:44:41AM -0800, Linus Torvalds wrote:
> On Nov 29, 2013 8:18 AM, "Will Deacon" <will.deacon@arm.com> wrote:
> >
> >  To get some sort of
> > idea, I tried adding a dmb to the start of spin_unlock on ARMv7 and I saw
> a
> > 3% performance hit in hackbench on my dual-cluster board.
> 
> Don't do a dmb. Just do a dummy release. You just said that on arm64 a
> unlock+lock is a memory barrier, so just make the mb__before_spinlock() be
> a dummy store with release to the stack..
> 
> That should be noticeably cheaper than a full dmb.

Cute!  I like it!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
