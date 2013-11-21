Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 810EC6B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 06:03:35 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so3904299qae.6
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 03:03:35 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id c3si16116296qai.158.2013.11.21.03.03.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Nov 2013 03:03:33 -0800 (PST)
Date: Thu, 21 Nov 2013 12:03:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131121110308.GC10022@twins.programming.kicks-ass.net>
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
 <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131120171400.GI4138@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, Nov 20, 2013 at 09:14:00AM -0800, Paul E. McKenney wrote:
> > Hmm, so in the following case:
> > 
> >   Access A
> >   unlock()	/* release semantics */
> >   lock()	/* acquire semantics */
> >   Access B
> > 
> > A cannot pass beyond the unlock() and B cannot pass the before the lock().
> > 
> > I agree that accesses between the unlock and the lock can be move across both
> > A and B, but that doesn't seem to matter by my reading of the above.
> > 
> > What is the problematic scenario you have in mind? Are you thinking of the
> > lock() moving before the unlock()? That's only permitted by RCpc afaiu,
> > which I don't think any architectures supported by Linux implement...
> > (ARMv8 acquire/release is RCsc).
> 
> If smp_load_acquire() and smp_store_release() are both implemented using
> lwsync on powerpc, and if Access A is a store and Access B is a load,
> then Access A and Access B can be reordered.
> 
> Of course, if every other architecture will be providing RCsc implementations
> for smp_load_acquire() and smp_store_release(), which would not be a bad
> thing, then another approach is for powerpc to use sync rather than lwsync
> for one or the other of smp_load_acquire() or smp_store_release().

So which of the two would make most sense?

As per the Document, loads/stores should not be able to pass up through
an ACQUIRE and loads/stores should not be able to pass down through a
RELEASE.

I think PPC would match that if we use sync for smp_store_release() such
that it will flush the store buffer, and thereby guarantee all stores
are kept within the required section.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
