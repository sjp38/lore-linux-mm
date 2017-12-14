Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD326B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:19:03 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h200so10883781itb.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:19:03 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 16si3788914itw.142.2017.12.14.13.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 13:19:02 -0800 (PST)
Date: Thu, 14 Dec 2017 22:18:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171214211841.GJ3857@worktop>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
 <20171214205450.GI3326@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214205450.GI3326@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 14, 2017 at 09:54:50PM +0100, Peter Zijlstra wrote:
> On Thu, Dec 14, 2017 at 12:44:58PM -0800, Dave Hansen wrote:
> > On 12/14/2017 06:37 AM, Peter Zijlstra wrote:
> > > I'm also looking at pte_access_permitted() in handle_pte_fault(); that
> > > looks very dodgy to me. How does that not result in endlessly CoW'ing
> > > the same page over and over when we have a PKEY disallowing write access
> > > on that page?
> > 
> > I'm not seeing the pte_access_permitted() in handle_pte_fault().  I
> > assume that's something you added in this series.
> 
> No, Dan did in 5c9d2d5c269c4.
> 
> > But, one of the ways that we keep pkeys from causing these kinds of
> > repeating loops when interacting with other things is this hunk in the
> > page fault code:
> > 
> > > static inline int
> > > access_error(unsigned long error_code, struct vm_area_struct *vma)
> > > {
> > ...
> > >         /*
> > >          * Read or write was blocked by protection keys.  This is
> > >          * always an unconditional error and can never result in
> > >          * a follow-up action to resolve the fault, like a COW.
> > >          */
> > >         if (error_code & PF_PK)
> > >                 return 1;
> > 
> > That short-circuits the page fault pretty quickly.  So, basically, the
> > rule is: if the hardware says you tripped over pkey permissions, you
> > die.  We don't try to do anything to the underlying page *before* saying
> > that you die.
> 
> That only works when you trip the fault from hardware. Not if you do a
> software fault using gup().
> 
> AFAIK __get_user_pages(FOLL_FORCE|FOLL_WRITE|FOLL_GET) will loop
> indefinitely on the case I described.

Note that my patch actually fixes this by making can_follow_write_pte()
not return NULL (we'll take the CoW fault irrespective of PKEYs) and
then on the second go-around, we'll find a writable PTE but return
-EFAULT from follow_page_mask() because of PKEY and terminate.

But as is, follow_page_mask() will return NULL because either !write or
PKEY, faultin_page()->handle_mm_fault() will see !write because of PKEY
go into the CoW path, we rety follow_page_mask() it will _still_ return
NULL because PKEY, again to the fault, again retry, again ....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
