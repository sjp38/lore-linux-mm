Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 646D46B00A6
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:47:47 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id ar20so805763iec.39
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:47:47 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id m10si418069icu.98.2014.02.26.07.47.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:47:41 -0800 (PST)
Date: Wed, 26 Feb 2014 16:47:36 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm: NULL ptr deref in balance_dirty_pages_ratelimited
Message-ID: <20140226154736.GV9987@twins.programming.kicks-ass.net>
References: <530CEFE2.9090909@oracle.com>
 <CAA_GA1dJA9PmZnoNy59__Ek+KPS3xX4WuR_8=onY8mZSRQrKiQ@mail.gmail.com>
 <20140226140941.GA31230@node.dhcp.inet.fi>
 <CAA_GA1dRS9WghaoG3bYwnEVxdOXQTjcTrZQkgZEU+vq3Lbmm6Q@mail.gmail.com>
 <20140226152051.GA31115@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140226152051.GA31115@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Bob Liu <lliubbo@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Feb 26, 2014 at 05:20:51PM +0200, Kirill A. Shutemov wrote:
> On Wed, Feb 26, 2014 at 10:48:30PM +0800, Bob Liu wrote:
> > > Do you relay on unlock_page() to have a compiler barrier?
> > >
> > 
> > Before your commit mapping is a local variable and be assigned before
> > unlock_page():
> > struct address_space *mapping = page->mapping;
> > unlock_page(dirty_page);
> > put_page(dirty_page);
> > if ((dirtied || page_mkwrite) && mapping) {
> > 
> > 
> > I'm afraid now "fault_page->mapping" might be changed to NULL after
> > "if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {"
> > and then passed down to balance_dirty_pages_ratelimited(NULL).
> 
> I see what you try to fix. I wounder if we need to do
> 
> mapping = ACCESS_ONCE(fault_page->mapping);
> 
> instead.
> 
> The question is if compiler on its own can eliminate intermediate variable
> and dereference fault_page->mapping twice, as code with my patch does.
> I ask because smp_mb__after_clear_bit() in unlock_page() does nothing on
> some architectures.

That's a bug, and I have patches for that. That said; this is only ia64
and sparc32. ia64 has an actual full memory barrier in there very much
including a compiler fence. And sparc32 atomics do too.

In general, any atomic RMW op also implies a compiler fence. This
includes clear_bit().

That said; unlock_page() should have RELEASE semantics, this too
enforces that the read of page->mapping stay before the unlock_page().
The second usage of mapping may leak into the locked region, but it may
not re-read after.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
