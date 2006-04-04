Date: Tue, 4 Apr 2006 12:21:02 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/3] mm: speculative get_page
Message-ID: <20060404102101.GA21329@wotan.suse.de>
References: <20060219020140.9923.43378.sendpatchset@linux.site> <20060219020159.9923.94877.sendpatchset@linux.site> <20060404024715.6555d8e2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060404024715.6555d8e2.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 04, 2006 at 02:47:15AM -0700, Andrew Morton wrote:
> Nick Piggin <npiggin@suse.de> wrote:
> >
> > +static inline struct page *page_cache_get_speculative(struct page **pagep)
> 
> Seems rather large to inline.
> 

Possibly... with all the debugging turned off, it is only atomic_inc
on UP, and atomic_inc_not_zero + several branches and barriers on SMP.

With only two callsites, I figure it is probably OK to be inline. It
probably looks bigger than it is...

> >  +{
> >  +	struct page *page;
> >  +
> >  +	VM_BUG_ON(in_interrupt());
> >  +
> >  +#ifndef CONFIG_SMP
> >  +	page = *pagep;
> >  +	if (unlikely(!page))
> >  +		return NULL;
> >  +
> >  +	VM_BUG_ON(!in_atomic());
> 
> This will go blam if !CONFIG_PREEMPT.

Hmm yes. Is there a safe way to do that? I guess it is pretty trivally
safely under rcu_read_lock , so that can probably just be removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
