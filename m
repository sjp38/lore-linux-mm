Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 718F66B0160
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 09:32:52 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so682301pab.40
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 06:32:52 -0800 (PST)
Received: from psmtp.com ([74.125.245.136])
        by mx.google.com with SMTP id sd2si2817333pbb.289.2013.11.07.06.32.50
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 06:32:51 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 7 Nov 2013 09:32:48 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id CFED36E807F
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 09:32:40 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA7EWfHi66715856
	for <linux-mm@kvack.org>; Thu, 7 Nov 2013 14:32:41 GMT
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rA7EYTVa013564
	for <linux-mm@kvack.org>; Thu, 7 Nov 2013 07:34:31 -0700
Date: Thu, 7 Nov 2013 06:31:39 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
Message-ID: <20131107143139.GT18245@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
 <1383773827.11046.355.camel@schen9-DESK>
 <CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
 <CANN689HkNP-UZOu+vDCFPG5_k=BNZG6a+oP+Ope16vLc2ShFzw@mail.gmail.com>
 <CA+55aFwn1HUt3iXo6Zz8j1HUJi+qJ1NfcnUz-P+XCYLL7gjCMQ@mail.gmail.com>
 <CANN689EgdDQV=srsLELUpiTGOSF0SLUZ=BC2LnMxNrYTv3H=Wg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689EgdDQV=srsLELUpiTGOSF0SLUZ=BC2LnMxNrYTv3H=Wg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Figo. zhang" <figo1802@gmail.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, linux-kernel@vger.kernel.org, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Thu, Nov 07, 2013 at 04:50:23AM -0800, Michel Lespinasse wrote:
> On Thu, Nov 7, 2013 at 4:06 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > On Nov 7, 2013 6:55 PM, "Michel Lespinasse" <walken@google.com> wrote:
> >>
> >> Rather than writing arch-specific locking code, would you agree to
> >> introduce acquire and release memory operations ?
> >
> > Yes, that's probably the right thing to do. What ops do we need? Store with
> > release, cmpxchg and load with acquire? Anything else?
> 
> Depends on what lock types we want to implement on top; for MCS we would need:
> - xchg acquire (common case) and load acquire (for spinning on our
> locker's wait word)
> - cmpxchg release (when there is no next locker) and store release
> (when writing to the next locker's wait word)
> 
> One downside of the proposal is that using a load acquire for spinning
> puts the memory barrier within the spin loop. So this model is very
> intuitive and does not add unnecessary barriers on x86, but it my
> place the barriers in a suboptimal place for architectures that need
> them.

OK, I will bite...  Why is a barrier in the spinloop suboptimal?

Can't say that I have tried measuring it, but the barrier should not
normally result in interconnect traffic.  Given that the barrier is
required anyway, it should not affect lock-acquisition latency.

So what am I missing here?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
