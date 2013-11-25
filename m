Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id B93C16B00DD
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 13:03:00 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id uy5so4526216obc.40
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:03:00 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id uq6si29107904obc.109.2013.11.25.10.02.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 10:02:59 -0800 (PST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 25 Nov 2013 11:02:59 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 67E3A3E4003F
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 11:02:56 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAPG0tjn6488436
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:00:55 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAPI5o42016291
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 11:05:52 -0700
Date: Mon, 25 Nov 2013 10:02:50 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131125180250.GR4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131121110308.GC10022@twins.programming.kicks-ass.net>
 <20131121125616.GI3694@twins.programming.kicks-ass.net>
 <20131121132041.GS4138@linux.vnet.ibm.com>
 <20131121172558.GA27927@linux.vnet.ibm.com>
 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
 <20131121221859.GH4138@linux.vnet.ibm.com>
 <20131122155835.GR3866@twins.programming.kicks-ass.net>
 <20131122182632.GW4138@linux.vnet.ibm.com>
 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
 <20131125173540.GK3694@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131125173540.GK3694@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Nov 25, 2013 at 06:35:40PM +0100, Peter Zijlstra wrote:
> On Fri, Nov 22, 2013 at 07:51:07PM +0100, Peter Zijlstra wrote:
> > On Fri, Nov 22, 2013 at 10:26:32AM -0800, Paul E. McKenney wrote:
> > > The real source of my cognitive pain is that here we have a sequence of
> > > code that has neither atomic instructions or memory-barrier instructions,
> > > but it looks like it still manages to act as a full memory barrier.
> > > Still not quite sure I should trust it...
> > 
> > Yes, this is something that puzzles me too.
> > 
> > That said, the two rules that:
> > 
> > 1)  stores aren't re-ordered against other stores
> > 2)  reads aren't re-ordered against other reads
> > 
> > Do make that:
> > 
> > 	STORE x
> > 	LOAD  x
> > 
> > form a fence that neither stores nor loads can pass through from
> > either side; note however that they themselves rely on the data
> > dependency to not reorder against themselves.
> > 
> > If you put them the other way around:
> > 
> > 	LOAD x
> > 	STORE y
> > 
> > we seem to get a stronger variant because stores are not re-ordered
> > against older reads.
> > 
> > There is however the exception cause for rule 1) above, which includes
> > clflush, non-temporal stores and string ops; the actual mfence
> > instruction doesn't seem to have this exception and would thus be
> > slightly stronger still.
> > 
> > Still confusion situation all round.
> 
> I think this means x86 needs help too.

I still do not believe that it does.  Again, strangely enough.

We need to ask someone in Intel that understands this all the way down
to the silicon.  The guy I used to rely on for this no longer works
at Intel.

Do you know someone who fits this description, or should I start sending
cold-call emails to various Intel contacts?

> Consider:
> 
> x = y = 0
> 
>   w[x] = 1  |  w[y] = 1
>   mfence    |  mfence
>   r[y] = 0  |  r[x] = 0
> 
> This is generally an impossible case, right? (Since if we observe y=0
> this means that w[y]=1 has not yet happened, and therefore x=1, and
> vice-versa).
> 
> Now replace one of the mfences with smp_store_release(l1);
> smp_load_acquire(l2); such that we have a RELEASE+ACQUIRE pair that
> _should_ form a full barrier:
> 
>   w[x] = 1   | w[y] = 1
>   w[l1] = 1  | mfence
>   r[l2] = 0  | r[x] = 0
>   r[y] = 0   |
> 
> At which point we can observe the impossible, because as per the rule:
> 
> 'reads may be reordered with older writes to different locations'
> 
> Our r[y] can slip before the w[x]=1.
> 
> Thus x86's smp_store_release() would need to be:
> 
> +#define smp_store_release(p, v)						\
> +do {									\
> +	compiletime_assert_atomic_type(*p);				\
> +	smp_mb();							\
> +	ACCESS_ONCE(*p) = (v);						\
> +} while (0)
> 
> Or: (void)xchg((p), (v));
> 
> Idem for s390 and sparc I suppose.
> 
> The only reason your example worked is because the unlock and lock were
> for the same lock.

Exactly!!!

And if the two locks are different, then the guarantee applies only
when the unlock and lock are on the same CPU, in which case, as Linus
noted, the xchg() on entry to the slow path does the job for use.

> This of course leaves us without joy for circular buffers, which can do
> without this LOCK'ed op and without sync on PPC. Now I'm not at all sure
> we've got enough of those to justify primitives just for them.

I am beginning to think that we do, but that is a separate discussion.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
