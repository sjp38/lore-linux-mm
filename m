From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 1/2] mm: implement remap_pfn_range with apply_to_page_range
Date: Fri, 14 Nov 2008 18:35:16 +1100
References: <491C61B1.10005@goop.org> <200811141417.35724.nickpiggin@yahoo.com.au> <491D0B2F.7050900@goop.org>
In-Reply-To: <491D0B2F.7050900@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811141835.17073.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

On Friday 14 November 2008 16:22, Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> > On Friday 14 November 2008 13:56, Jeremy Fitzhardinge wrote:
> >> Nick Piggin wrote:
> >>> This isn't performance critical to anyone?
> >>
> >> The only difference should be between having the specialized code and an
> >> indirect function call, no?
> >
> > Indirect function call per pte. It's going to be slower surely.
>
> Yes, though changing the calling convention to handle (up to) a whole
> page worth of ptes in one call would be fairly simple I think.

Yep. And leaving it alone is even simpler and still faster :)


> > It is accepted practice to (carefully) duplicate the page table walking
> > functions in memory management code. I don't think that's a problem,
> > there is already so many instances of them (just be sure to stick to
> > exactly the same form and variable names, and any update or bugfix to
> > any of them is trivially applicable to all).
>
> I think that's pretty awful practice, frankly, and I'd much prefer there
> to be a single iterator function which everyone uses.

I think its pretty nice. It means you can make the loops fairly
optimal even if they might have slightly different requirements
(different arguments, latency breaks, copy_page_range etc).


> The open-coded 
> iterators everywhere just makes it completely impractical to even think
> about other kinds of pagetable structures.  (Of course we have at least
> two "general purpose" pagetable walkers now...)

I think that's being way over dramatic. When switching to a
different page table structure, I assure you that copying and
pasting your new walking algorithm a few times will be the least
of your worries :)

It's not meant to be pluggable. Actually this came up last I think
when the UNSW wanted to add page table accessors to abstract this.
They came up with a good set of things, but in the end you can't
justify slowing things down in these paths unless you actually have
a replacement page table structure that gets you a *net win*. So
far, I haven't heard from them again.

No, adding a cycle here or an indirect function call there IMO is
not acceptable in core mm/ code without a good reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
