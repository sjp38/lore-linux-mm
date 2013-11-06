Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB916B00DE
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 09:30:53 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so10541388pad.39
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 06:30:53 -0800 (PST)
Received: from psmtp.com ([74.125.245.160])
        by mx.google.com with SMTP id t6si3474186paa.163.2013.11.06.06.30.50
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 06:30:51 -0800 (PST)
Date: Wed, 6 Nov 2013 15:30:37 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: create a separate slab for page->ptl allocation
Message-ID: <20131106143037.GO10651@twins.programming.kicks-ass.net>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
 <20131105224217.GC20167@shutemov.name>
 <20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
 <20131105231310.GE20167@shutemov.name>
 <20131106093131.GU28601@twins.programming.kicks-ass.net>
 <20131106132155.GA22132@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131106132155.GA22132@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Wed, Nov 06, 2013 at 03:21:55PM +0200, Kirill A. Shutemov wrote:
> On Wed, Nov 06, 2013 at 10:31:31AM +0100, Peter Zijlstra wrote:
> > On Wed, Nov 06, 2013 at 01:13:11AM +0200, Kirill A. Shutemov wrote:
> > > I would like to get rid of __ptlock_alloc()/__ptlock_free() too, but I
> > > don't see a way within C: we need to know sizeof(spinlock_t) on
> > > preprocessor stage.
> > > 
> > > We can have a hack on kbuild level: write small helper program to find out
> > > sizeof(spinlock_t) before start building and turn it into define.
> > > But it's overkill from my POV. And cross-compilation will be a fun.
> > 
> > Ah, I just remembered, we have such a thing!
> 
> Great!
> 
> > @@ -1354,7 +1356,7 @@ static inline bool ptlock_init(struct page *page)
> >  	 * slab code uses page->slab_cache and page->first_page (for tail
> >  	 * pages), which share storage with page->ptl.
> >  	 */
> > -	VM_BUG_ON(page->ptl);
> > +	VM_BUG_ON(*(unsigned long *)&page->ptl);
> 
> Huh? Why not direct cast to unsigned long?
> 
> VM_BUG_ON((unsigned long)page->ptl);

I tried, GCC didn't dig that. I think because spinlock_t is a composite
type and you cannot cast that to a primitive type.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
