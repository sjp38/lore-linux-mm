Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7CC6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 03:11:24 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so7210957wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 00:11:24 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id om6si3027225wjc.33.2015.09.25.00.11.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 00:11:23 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so7210378wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 00:11:22 -0700 (PDT)
Date: Fri, 25 Sep 2015 09:11:19 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
Message-ID: <20150925071119.GB15753@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com>
 <20150924093026.GA29699@gmail.com>
 <560435B4.1010603@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560435B4.1010603@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Dave Hansen <dave@sr71.net> wrote:

> On 09/24/2015 02:30 AM, Ingo Molnar wrote:
> >> To answer your question in the comment: it looks useful to have some sort of 
> >> 'extended page fault error code' information here, which shows why the page fault 
> >> happened. With the regular error_code it's easy - with protection keys there's 16 
> >> separate keys possible and user-space might not know the actual key value in the 
> >> pte.
> > 
> > Btw., alternatively we could also say that user-space should know what protection 
> > key it used when it created the mapping - there's no need to recover it for every 
> > page fault.
> 
> That's true.  We don't, for instance, tell userspace whether it was a
> write that caused a fault.

I think we do put it into the signal frame, see setup_sigcontext():

                put_user_ex(current->thread.error_code, &sc->err);

and 'error_code & PF_WRITE' tells us whether it's a write fault.

And I'm pretty sure applications like Valgrind rely on this.

> But, other than smaps we don't have *any* way to tell userspace what protection 
> key a page has.  I think some mechanism is going to be required for this to be 
> reasonably debuggable.

I think it's a conceptual extension of sigcontext::err and we need it for similar 
reasons.

> > OTOH, as long as we don't do a separate find_vma(), it looks cheap enough to 
> > look up the pkey value of that address and give it to user-space in the signal 
> > frame.
> 
> I still think that find_vma() in this case is pretty darn cheap, definitely if 
> you compare it to the cost of the entire fault path.

So where's the problem? We have already looked up the vma and know whether there's 
any vma there or not. Why not pass in that pointer and be done with it? Why 
complicate the code by looking up a second time (and exposing us to various 
races)?

> > Btw., how does pkey support interact with hugepages?
> 
> Surprisingly little.  I've made sure that everything works with huge pages and 
> that the (huge) PTEs and VMAs get set up correctly, but I'm not sure I had to 
> touch the huge page code at all.  I have test code to ensure that it works the 
> same as with small pages, but everything worked pretty naturally.

Yeah, so the reason I'm asking about expectations is that this code:

+       follow_ret = follow_pte(tsk->mm, address, &ptep, &ptl);
+       if (!follow_ret) {
+               /*
+                * On a successful follow, make sure to
+                * drop the lock.
+                */
+               pte = *ptep;
+               pte_unmap_unlock(ptep, ptl);
+               ret = pte_pkey(pte);

is visibly hugepage-unsafe: if a vma is hugepage mapped, there are no ptes, only 
pmds - and the protection key index lives in the pmd. We don't seem to recover 
that information properly.

In any case, please put those hugepage tests into tools/tests/selftests/x86/ as 
well, as part of the pkey series.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
