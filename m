Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1762C6B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 09:37:50 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id c18so8467159itd.8
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:37:50 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 193si2815921iou.68.2017.12.14.06.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 06:37:48 -0800 (PST)
Date: Thu, 14 Dec 2017 15:37:30 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 14, 2017 at 01:41:17PM +0100, Peter Zijlstra wrote:
> On Thu, Dec 14, 2017 at 12:27:27PM +0100, Peter Zijlstra wrote:
> > The gup_*_range() functions which implement __get_user_pages_fast() do
> > a p*_access_permitted() test to see if the memory is at all accessible
> > (tests both _PAGE_USER|_PAGE_RW as well as architectural things like
> > pkeys).
> > 
> > But the follow_*() functions which implement __get_user_pages() do not
> > have this test. Recently, commit:
> > 
> >   5c9d2d5c269c ("mm: replace pte_write with pte_access_permitted in fault + gup paths")
> > 
> > added it to a few specific write paths, but it failed to consistently
> > apply it (I've not audited anything outside of gup).
> > 
> > Revert the change from that patch and insert the tests in the right
> > locations such that they cover all READ / WRITE accesses for all
> > pte/pmd/pud levels.
> > 
> > In particular I care about the _PAGE_USER test, we should not ever,
> > allow access to pages not marked with it, but it also makes the pkey
> > accesses more consistent.
> 
> This should probably go on top. These are now all superfluous and
> slightly wrong.

I also cannot explain dax_mapping_entry_mkclean(), why would we not make
clean those pages that are not pkey writable (but clearly are writable
and dirty)? That doesn't make any sense at all.

Kirill did point out that my patch(es) break FOLL_DUMP in that it would
now exclude pkey protected pages from core-dumps.

My counter argument is that it will now properly exclude !_PAGE_USER
pages.

If we change p??_access_permitted() to pass the full follow flags
instead of just the write part we could fix that.

I'm also looking at pte_access_permitted() in handle_pte_fault(); that
looks very dodgy to me. How does that not result in endlessly CoW'ing
the same page over and over when we have a PKEY disallowing write access
on that page?

Bah... /me grumpy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
