Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE158E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 05:00:05 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id p4so7128193pgj.21
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 02:00:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u7si10321156pfu.270.2018.12.10.02.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Dec 2018 02:00:03 -0800 (PST)
Date: Mon, 10 Dec 2018 10:59:55 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/6] __wr_after_init: write rare for static allocation
Message-ID: <20181210095955.GI5289@hirez.programming.kicks-ass.net>
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
 <20181204121805.4621-3-igor.stoppa@huawei.com>
 <CALCETrVvoui0vksdt0Y9rdGL5ipEn_FtSXVVUFdH03ZC93cy_A@mail.gmail.com>
 <20181206094451.GC13538@hirez.programming.kicks-ass.net>
 <d9382720-3c39-5f10-afcd-dc17727fe4dc@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9382720-3c39-5f10-afcd-dc17727fe4dc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Igor Stoppa <igor.stoppa@huawei.com>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity <linux-integrity@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 10, 2018 at 12:32:21AM +0200, Igor Stoppa wrote:
> 
> 
> On 06/12/2018 11:44, Peter Zijlstra wrote:
> > On Wed, Dec 05, 2018 at 03:13:56PM -0800, Andy Lutomirski wrote:
> > 
> > > > +       if (op == WR_MEMCPY)
> > > > +               memcpy((void *)wr_poking_addr, (void *)src, len);
> > > > +       else if (op == WR_MEMSET)
> > > > +               memset((u8 *)wr_poking_addr, (u8)src, len);
> > > > +       else if (op == WR_RCU_ASSIGN_PTR)
> > > > +               /* generic version of rcu_assign_pointer */
> > > > +               smp_store_release((void **)wr_poking_addr,
> > > > +                                 RCU_INITIALIZER((void **)src));
> > > > +       kasan_enable_current();
> > > 
> > > Hmm.  I suspect this will explode quite badly on sane architectures
> > > like s390.  (In my book, despite how weird s390 is, it has a vastly
> > > nicer model of "user" memory than any other architecture I know
> > > of...).  I think you should use copy_to_user(), etc, instead.  I'm not
> > > entirely sure what the best smp_store_release() replacement is.
> > > Making this change may also mean you can get rid of the
> > > kasan_disable_current().
> > 
> > If you make the MEMCPY one guarantee single-copy atomicity for native
> > words then you're basically done.
> > 
> > smp_store_release() can be implemented with:
> > 
> > 	smp_mb();
> > 	WRITE_ONCE();
> > 
> > So if we make MEMCPY provide the WRITE_ONCE(), all we need is that
> > barrier, which we can easily place at the call site and not overly
> > complicate our interface with this.
> 
> Ok, so the 3rd case (WR_RCU_ASSIGN_PTR) could be handled outside of this
> function.
> But, since now memcpy() will be replaced by copy_to_user(), can I assume
> that also copy_to_user() will be atomic, if the destination is properly
> aligned? On x86_64 it seems yes, however it's not clear to me if this is the
> outcome of an optimization or if I can expect it to be always true.

This would be a new contraint; one that needs to be documented and
verified by the various arch maintainers as they enable this feature on
their platform.
