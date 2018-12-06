Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8E26B7949
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 04:45:11 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e14so17090678wru.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 01:45:11 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 200si153911wmb.57.2018.12.06.01.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 01:45:10 -0800 (PST)
Date: Thu, 6 Dec 2018 10:44:51 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/6] __wr_after_init: write rare for static allocation
Message-ID: <20181206094451.GC13538@hirez.programming.kicks-ass.net>
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
 <20181204121805.4621-3-igor.stoppa@huawei.com>
 <CALCETrVvoui0vksdt0Y9rdGL5ipEn_FtSXVVUFdH03ZC93cy_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVvoui0vksdt0Y9rdGL5ipEn_FtSXVVUFdH03ZC93cy_A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Igor Stoppa <igor.stoppa@gmail.com>, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Igor Stoppa <igor.stoppa@huawei.com>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity <linux-integrity@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 05, 2018 at 03:13:56PM -0800, Andy Lutomirski wrote:

> > +       if (op == WR_MEMCPY)
> > +               memcpy((void *)wr_poking_addr, (void *)src, len);
> > +       else if (op == WR_MEMSET)
> > +               memset((u8 *)wr_poking_addr, (u8)src, len);
> > +       else if (op == WR_RCU_ASSIGN_PTR)
> > +               /* generic version of rcu_assign_pointer */
> > +               smp_store_release((void **)wr_poking_addr,
> > +                                 RCU_INITIALIZER((void **)src));
> > +       kasan_enable_current();
> 
> Hmm.  I suspect this will explode quite badly on sane architectures
> like s390.  (In my book, despite how weird s390 is, it has a vastly
> nicer model of "user" memory than any other architecture I know
> of...).  I think you should use copy_to_user(), etc, instead.  I'm not
> entirely sure what the best smp_store_release() replacement is.
> Making this change may also mean you can get rid of the
> kasan_disable_current().

If you make the MEMCPY one guarantee single-copy atomicity for native
words then you're basically done.

smp_store_release() can be implemented with:

	smp_mb();
	WRITE_ONCE();

So if we make MEMCPY provide the WRITE_ONCE(), all we need is that
barrier, which we can easily place at the call site and not overly
complicate our interface with this.

Because performance is down the drain already, an additional full
memory barrier is peanuts here (and in fact already implied by the x86
CR3 munging).
