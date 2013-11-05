Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8055F6B00A8
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 18:56:23 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2699948pbb.41
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 15:56:23 -0800 (PST)
Received: from psmtp.com ([74.125.245.107])
        by mx.google.com with SMTP id je1si15087928pbb.210.2013.11.05.15.56.21
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 15:56:22 -0800 (PST)
Date: Tue, 5 Nov 2013 15:56:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: create a separate slab for page->ptl allocation
Message-Id: <20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
In-Reply-To: <20131105224217.GC20167@shutemov.name>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
	<20131105224217.GC20167@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Wed, 6 Nov 2013 00:42:17 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > >  #if USE_SPLIT_PTE_PTLOCKS
> > > +struct kmem_cache *page_ptl_cachep;
> > > +void __init ptlock_cache_init(void)
> > > +{
> > > +	if (sizeof(spinlock_t) > sizeof(long))
> > > +		page_ptl_cachep = kmem_cache_create("page->ptl",
> > > +				sizeof(spinlock_t), 0, SLAB_PANIC, NULL);
> > > +}
> > 
> > Confused.  If (sizeof(spinlock_t) > sizeof(long)) happens to be false
> > then the kernel will later crash.  It would be better to use BUILD_BUG_ON()
> > here, if that works.  Otherwise BUG_ON.
> 
> if (sizeof(spinlock_t) > sizeof(long)) is false, we don't need dynamicly
> allocate page->ptl. It's embedded to struct page itself. __ptlock_alloc()
> never called in this case.

OK.  Please add a comment explaining this so the next reader doesn't get
tripped up like I was.

Really the function shouldn't exist in this case.  It is __init so the
sin is not terrible, but can this be arranged?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
