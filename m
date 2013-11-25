Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6C85E6B0037
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:37:08 -0500 (EST)
Received: by mail-oa0-f52.google.com with SMTP id h16so5162586oag.39
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:37:08 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id si5si25385197oeb.113.2013.11.25.15.37.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 15:37:07 -0800 (PST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 25 Nov 2013 16:37:06 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id AC5731FF001E
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:36:44 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAPLZ3ZX4456924
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 22:35:03 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAPNdwbJ017859
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:40:00 -0700
Date: Mon, 25 Nov 2013 15:36:58 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131125233658.GV4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131121125616.GI3694@twins.programming.kicks-ass.net>
 <20131121132041.GS4138@linux.vnet.ibm.com>
 <20131121172558.GA27927@linux.vnet.ibm.com>
 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
 <20131121221859.GH4138@linux.vnet.ibm.com>
 <20131122155835.GR3866@twins.programming.kicks-ass.net>
 <20131122182632.GW4138@linux.vnet.ibm.com>
 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
 <20131125173540.GK3694@twins.programming.kicks-ass.net>
 <52939C5A.3070208@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52939C5A.3070208@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Nov 25, 2013 at 10:52:10AM -0800, H. Peter Anvin wrote:
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
> 
> Yes, because although r[l2] and r[y] are ordered with respect to each
> other, they are allowed to be executed before w[x] and w[l1].  In other
> words, smp_store_release() followed by smp_load_acquire() to a different
> location do not form a full barrier.  To the *same* location, they will.

In the case where we have a single CPU doing an unlock of one lock
followed by a lock of another lock using Tim Chen's MCS lock, there
will be an xchg() that will provide the needed full barrier.

If the unlock is from one CPU and the lock is from another CPU, then
Linux kernel only requires a full barrier in the case where both
the unlock and lock are acting on the same lock variable.  Which is
the scenario under investigation.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
