Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6599C6B00C8
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 05:34:37 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id q10so9972509pdj.13
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 02:34:36 -0800 (PST)
Received: from psmtp.com ([74.125.245.155])
        by mx.google.com with SMTP id qk4si16906846pac.235.2013.11.06.02.34.34
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 02:34:35 -0800 (PST)
Date: Wed, 6 Nov 2013 10:34:03 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: create a separate slab for page->ptl allocation
Message-ID: <20131106103403.GB21074@mudshark.cambridge.arm.com>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
 <20131105224217.GC20167@shutemov.name>
 <20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
 <20131105231310.GE20167@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131105231310.GE20167@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Tue, Nov 05, 2013 at 11:13:11PM +0000, Kirill A. Shutemov wrote:
> On Tue, Nov 05, 2013 at 03:56:19PM -0800, Andrew Morton wrote:
> > On Wed, 6 Nov 2013 00:42:17 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > 
> > > > >  #if USE_SPLIT_PTE_PTLOCKS
> > > > > +struct kmem_cache *page_ptl_cachep;
> > > > > +void __init ptlock_cache_init(void)
> > > > > +{
> > > > > +	if (sizeof(spinlock_t) > sizeof(long))
> > > > > +		page_ptl_cachep = kmem_cache_create("page->ptl",
> > > > > +				sizeof(spinlock_t), 0, SLAB_PANIC, NULL);
> > > > > +}
> > > > 
> > > > Confused.  If (sizeof(spinlock_t) > sizeof(long)) happens to be false
> > > > then the kernel will later crash.  It would be better to use BUILD_BUG_ON()
> > > > here, if that works.  Otherwise BUG_ON.
> > > 
> > > if (sizeof(spinlock_t) > sizeof(long)) is false, we don't need dynamicly
> > > allocate page->ptl. It's embedded to struct page itself. __ptlock_alloc()
> > > never called in this case.
> > 
> > OK.  Please add a comment explaining this so the next reader doesn't get
> > tripped up like I was.
> 
> Okay, I will tomorrow.
> 
> > Really the function shouldn't exist in this case.  It is __init so the
> > sin is not terrible, but can this be arranged?
> 
> I would like to get rid of __ptlock_alloc()/__ptlock_free() too, but I
> don't see a way within C: we need to know sizeof(spinlock_t) on
> preprocessor stage.

FWIW: if the architecture selects ARCH_USE_CMPXCHG_LOCKREF, then a spinlock_t
is 32-bit (assuming that unsigned int is also 32-bit).

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
