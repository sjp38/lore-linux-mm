Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 082376B017C
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 16:16:05 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1181450pab.8
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 13:16:05 -0800 (PST)
Received: from psmtp.com ([74.125.245.143])
        by mx.google.com with SMTP id t6si4215749paa.337.2013.11.07.13.16.03
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 13:16:04 -0800 (PST)
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <CANN689FqUSnr=Prum0Kt6+0gr9dWKD8GT9Gbrtiyyg+PTyFkyA@mail.gmail.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	 <1383773827.11046.355.camel@schen9-DESK>
	 <CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
	 <CANN689HkNP-UZOu+vDCFPG5_k=BNZG6a+oP+Ope16vLc2ShFzw@mail.gmail.com>
	 <CA+55aFwn1HUt3iXo6Zz8j1HUJi+qJ1NfcnUz-P+XCYLL7gjCMQ@mail.gmail.com>
	 <CANN689EgdDQV=srsLELUpiTGOSF0SLUZ=BC2LnMxNrYTv3H=Wg@mail.gmail.com>
	 <20131107143139.GT18245@linux.vnet.ibm.com>
	 <CANN689FqUSnr=Prum0Kt6+0gr9dWKD8GT9Gbrtiyyg+PTyFkyA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Nov 2013 13:15:51 -0800
Message-ID: <1383858951.11046.399.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Figo. zhang" <figo1802@gmail.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Thu, 2013-11-07 at 11:59 -0800, Michel Lespinasse wrote:
> On Thu, Nov 7, 2013 at 6:31 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Thu, Nov 07, 2013 at 04:50:23AM -0800, Michel Lespinasse wrote:
> >> On Thu, Nov 7, 2013 at 4:06 AM, Linus Torvalds
> >> <torvalds@linux-foundation.org> wrote:
> >> >
> >> > On Nov 7, 2013 6:55 PM, "Michel Lespinasse" <walken@google.com> wrote:
> >> >>
> >> >> Rather than writing arch-specific locking code, would you agree to
> >> >> introduce acquire and release memory operations ?
> >> >
> >> > Yes, that's probably the right thing to do. What ops do we need? Store with
> >> > release, cmpxchg and load with acquire? Anything else?
> >>
> >> Depends on what lock types we want to implement on top; for MCS we would need:
> >> - xchg acquire (common case) and load acquire (for spinning on our
> >> locker's wait word)
> >> - cmpxchg release (when there is no next locker) and store release
> >> (when writing to the next locker's wait word)
> >>
> >> One downside of the proposal is that using a load acquire for spinning
> >> puts the memory barrier within the spin loop. So this model is very
> >> intuitive and does not add unnecessary barriers on x86, but it my
> >> place the barriers in a suboptimal place for architectures that need
> >> them.
> >
> > OK, I will bite...  Why is a barrier in the spinloop suboptimal?
> 
> It's probably not a big deal - all I meant to say is that if you were
> manually placing barriers, you would probably put one after the loop
> instead. I don't deal much with architectures where such barriers are
> needed, so I don't know for sure if the difference means much.

We could do a load acquire at the end of the 
spin loop in the lock function and not in the spin loop itself if cost
of barrier within spin loop is a concern.

Michel, are you planning to do an implementation of
load-acquire/store-release functions of various architectures?

Or is the approach of arch specific memory barrier for MCS 
an acceptable one before load-acquire and store-release
are available?  Are there any technical issues remaining with 
the patchset after including including Waiman's arch specific barrier?

Tim

> 
> > Can't say that I have tried measuring it, but the barrier should not
> > normally result in interconnect traffic.  Given that the barrier is
> > required anyway, it should not affect lock-acquisition latency.
> 
> Agree
> 
> > So what am I missing here?
> 
> I think you read my second email as me trying to shoot down a proposal
> - I wasn't, as I really like the acquire/release model and find it
> easy to program with, which is why I'm proposing it in the first
> place. I just wanted to be upfront about all potential downsides, so
> we can consider them and see if they are significant - I don't think
> they are, but I'm not the best person to judge that as I mostly just
> deal with x86 stuff.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
