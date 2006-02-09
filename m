Received: by uproxy.gmail.com with SMTP id a2so19353ugf
        for <linux-mm@kvack.org>; Wed, 08 Feb 2006 18:50:24 -0800 (PST)
Message-ID: <aec7e5c30602081850n772005bckf729683f446fb2a9@mail.gmail.com>
Date: Thu, 9 Feb 2006 11:50:22 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [RFC] Removing page->flags
In-Reply-To: <1139427478.9452.6.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1139381183.22509.186.camel@localhost>
	 <1139427478.9452.6.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On 2/9/06, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Wed, 2006-02-08 at 15:46 +0900, Magnus Damm wrote:
> > Removing type B bits:
> >
> > Instead of using the highest bits of page->flags to locate zones, nodes
> > or sparsemem section, let's remove them and locate them using alignment!
> >
> > To locate which zone, node and sparsemem section a page belongs to, just
> > use struct page (source_page) and aligment! The page that contains the
> > specific struct page (and also contains other parts of mem_map), it's
> > struct page is located using something like this:
> >
> >   memmap_page = virt_to_page(source_page)
>
> We actually discussed this a number of times when developing sparsemem
> and its predecessors.  It does seem silly to store stuff like the node
> information in *so* *many* copies all over the place.

Exactly!

> Andy's argument at the time (if I remember correctly) was that nobody
> was using those particular page flags for anything, so what shouldn't we
> use them?  Plus, this gives better cache locality.

Sure, that makes sense.

> You hinted at it, but you are completely right that the 'struct pages'
> backing other 'struct pages' aren't used for anything.  They are often
> bootmem-allocated, so that probably have PageReserved set, and have
> never seen the allocator.  All of their fields are basically free for
> any use that we'd like.

Yes, and there is probably quite much free space in those struct pages too.

> The biggest killer for this idea for me is not when the zones or section
> edges are not aligned on big powers of 2, but when the 'struct page' is
> oddly sized.  When it is 32 or 64 bytes, you get a nice, even number of
> them in a full page.  But, when you have a 40-byte 'struct page', things
> go downhill in a hurry.  This can be affected by things like spinlock
> debugging, so it is hard to predict and handle in advance.

I realize that if struct page size is not a power of two we will end
up with struct page elements that cross a lot of page boundaries. But
is that really a problem? I thought we were safe if:

1) struct page could be any size
2) zones have to start and end at pfn:s that are a multiple of PAGE_SIZE
3) for sparsemem, the smallest section size is 1 << (PAGE_SIZE * 2).

> The really basic implementation (without the odd page size handling) is
> here, if you care:
>
> http://www.sr71.net/patches/2.6.10/2.6.10-rc2-mm4-mhp3/broken-out/C6-nonlinear-no-page-section.patch

Cool, I will check it out.

Thanks!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
