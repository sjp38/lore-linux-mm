Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4CC6B0156
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 07:50:27 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kq14so555111pab.7
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 04:50:26 -0800 (PST)
Received: from psmtp.com ([74.125.245.116])
        by mx.google.com with SMTP id cx4si2558268pbc.119.2013.11.07.04.50.25
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 04:50:26 -0800 (PST)
Received: by mail-qc0-f174.google.com with SMTP id v1so335491qcw.19
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 04:50:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwn1HUt3iXo6Zz8j1HUJi+qJ1NfcnUz-P+XCYLL7gjCMQ@mail.gmail.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	<1383773827.11046.355.camel@schen9-DESK>
	<CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
	<CANN689HkNP-UZOu+vDCFPG5_k=BNZG6a+oP+Ope16vLc2ShFzw@mail.gmail.com>
	<CA+55aFwn1HUt3iXo6Zz8j1HUJi+qJ1NfcnUz-P+XCYLL7gjCMQ@mail.gmail.com>
Date: Thu, 7 Nov 2013 04:50:23 -0800
Message-ID: <CANN689EgdDQV=srsLELUpiTGOSF0SLUZ=BC2LnMxNrYTv3H=Wg@mail.gmail.com>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Waiman Long <waiman.long@hp.com>, Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, Aswin Chandramouleeswaran <aswin@hp.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Figo. zhang" <figo1802@gmail.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, linux-kernel@vger.kernel.org, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Thu, Nov 7, 2013 at 4:06 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Nov 7, 2013 6:55 PM, "Michel Lespinasse" <walken@google.com> wrote:
>>
>> Rather than writing arch-specific locking code, would you agree to
>> introduce acquire and release memory operations ?
>
> Yes, that's probably the right thing to do. What ops do we need? Store with
> release, cmpxchg and load with acquire? Anything else?

Depends on what lock types we want to implement on top; for MCS we would need:
- xchg acquire (common case) and load acquire (for spinning on our
locker's wait word)
- cmpxchg release (when there is no next locker) and store release
(when writing to the next locker's wait word)

One downside of the proposal is that using a load acquire for spinning
puts the memory barrier within the spin loop. So this model is very
intuitive and does not add unnecessary barriers on x86, but it my
place the barriers in a suboptimal place for architectures that need
them.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
