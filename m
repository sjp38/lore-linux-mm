Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D02346B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:58:28 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so6486519pdj.31
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 14:58:28 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ty3si24256268pbc.17.2013.11.25.14.58.26
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 14:58:27 -0800 (PST)
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <52939C5A.3070208@zytor.com>
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
	 <20131125173540.GK3694@twins.programming.kicks-ass.net>
	 <52939C5A.3070208@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 25 Nov 2013 14:58:22 -0800
Message-ID: <1385420302.11046.539.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, 2013-11-25 at 10:52 -0800, H. Peter Anvin wrote:
> On 11/25/2013 09:35 AM, Peter Zijlstra wrote:
> > 
> > I think this means x86 needs help too.
> > 
> > Consider:
> > 
> > x = y = 0
> > 
> >   w[x] = 1  |  w[y] = 1
> >   mfence    |  mfence
> >   r[y] = 0  |  r[x] = 0
> > 
> > This is generally an impossible case, right? (Since if we observe y=0
> > this means that w[y]=1 has not yet happened, and therefore x=1, and
> > vice-versa).
> > 
> > Now replace one of the mfences with smp_store_release(l1);
> > smp_load_acquire(l2); such that we have a RELEASE+ACQUIRE pair that
> > _should_ form a full barrier:
> > 
> >   w[x] = 1   | w[y] = 1
> >   w[l1] = 1  | mfence
> >   r[l2] = 0  | r[x] = 0
> >   r[y] = 0   |
> > 
> > At which point we can observe the impossible, because as per the rule:
> > 
> > 'reads may be reordered with older writes to different locations'
> > 
> > Our r[y] can slip before the w[x]=1.
> > 
> 
> Yes, because although r[l2] and r[y] are ordered with respect to each
> other, they are allowed to be executed before w[x] and w[l1].  In other
> words, smp_store_release() followed by smp_load_acquire() to a different
> location do not form a full barrier.  To the *same* location, they will.
> 
> 	-hpa
> 

Peter,

Want to check with you on Paul's example, 
where we are indeed writing and reading to the same
lock location when passing the lock on x86 with smp_store_release and
smp_load_acquire.  So the unlock and lock sequence looks like:

        CPU 0 (releasing)       CPU 1 (acquiring)
        -----                   -----
        ACCESS_ONCE(X) = 1;     while (ACCESS_ONCE(lock) == 1)
                                  continue;
        ACCESS_ONCE(lock) = 0;  
                                r1 = ACCESS_ONCE(Y);

observer CPU 2:

        CPU 2
        -----
        ACCESS_ONCE(Y) = 1;
        smp_mb();
        r2 = ACCESS_ONCE(X);

If the write and read to lock act as a full memory barrier, 
it would be impossible to
end up with (r1 == 0 && r2 == 0), correct?

Tim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
