Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00AAB6B014E
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 04:55:41 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id xa7so366262pbc.10
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 01:55:41 -0800 (PST)
Received: from psmtp.com ([74.125.245.168])
        by mx.google.com with SMTP id pz2si2444496pac.86.2013.11.07.01.55.39
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 01:55:40 -0800 (PST)
Received: by mail-qa0-f47.google.com with SMTP id w8so239772qac.20
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 01:55:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	<1383773827.11046.355.camel@schen9-DESK>
	<CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
Date: Thu, 7 Nov 2013 01:55:37 -0800
Message-ID: <CANN689HkNP-UZOu+vDCFPG5_k=BNZG6a+oP+Ope16vLc2ShFzw@mail.gmail.com>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, "Figo. zhang" <figo1802@gmail.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Rik van Riel <riel@redhat.com>, Waiman Long <waiman.long@hp.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Alex Shi <alex.shi@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Scott J Norton <scott.norton@hp.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Wed, Nov 6, 2013 at 5:39 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Sorry about the HTML crap, the internet connection is too slow for my normal
> email habits, so I'm using my phone.
>
> I think the barriers are still totally wrong for the locking functions.
>
> Adding an smp_rmb after waiting for the lock is pure BS. Writes in the
> locked region could percolate out of the locked region.
>
> The thing is, you cannot do the memory ordering for locks in any same
> generic way. Not using our current barrier system. On x86 (and many others)
> the smp_rmb will work fine, because writes are never moved earlier. But on
> other architectures you really need an acquire to get a lock efficiently. No
> separate barriers. An acquire needs to be on the instruction that does the
> lock.
>
> Same goes for unlock. On x86 any store is a fine unlock, but on other
> architectures you need a store with a release marker.
>
> So no amount of barriers will ever do this correctly. Sure, you can add full
> memory barriers and it will be "correct" but it will be unbearably slow, and
> add totally unnecessary serialization. So *correct* locking will require
> architecture support.

Rather than writing arch-specific locking code, would you agree to
introduce acquire and release memory operations ?

The semantics of an acquire memory operation would be: the specified
memory operation occurs, and any reads or writes after that operation
are guaranteed not to be reordered before it (useful to implement lock
acquisitions).
The semantics of a release memory operation would be: the specified
memory operation occurs, and any reads or writes before that operation
are guaranteed not to be reordered after it (useful to implement lock
releases).

Now each arch would still need to define several acquire and release
operations, but this is a quite useful model to build generic code on.
For example, the fast path for the x86 spinlock implementation could
be expressed generically as an acquire fetch-and-add (for
__ticket_spin_lock) and a release add (for __ticket_spin_unlock).

Would you think this is a useful direction to move to ?

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
