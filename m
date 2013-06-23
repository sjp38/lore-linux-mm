Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 787A56B0034
	for <linux-mm@kvack.org>; Sun, 23 Jun 2013 01:10:20 -0400 (EDT)
Date: Sun, 23 Jun 2013 07:10:18 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] rwsem: check the lock before cpmxchg in
 down_write_trylock and rwsem_do_wake
Message-ID: <20130623051018.GS6123@two.firstfloor.org>
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>
 <1371858695.22432.4.camel@schen9-DESK>
 <51C55082.5040500@hurleysoftware.com>
 <51C64C5D.5090400@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C64C5D.5090400@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

> >> diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
> >> index bb1e2cd..052d973 100644
> >> --- a/include/asm-generic/rwsem.h
> >> +++ b/include/asm-generic/rwsem.h
> >> @@ -70,11 +70,11 @@ static inline void __down_write(struct
> >> rw_semaphore *sem)
> >>
> >>   static inline int __down_write_trylock(struct rw_semaphore *sem)
> >>   {
> >> -    long tmp;
> >> +    if (unlikely(&sem->count != RWSEM_UNLOCKED_VALUE))
> >                      ^^^^^^^^^^^
> > 
> > This is probably not what you want.
> > 
> 
> this function logical is quite simple. check the sem->count before
> cmpxchg is no harm this logical.
> 
> So could you like to tell us what should we want?

You are comparing the address, not the value. Remove the &
This was a nop too.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
