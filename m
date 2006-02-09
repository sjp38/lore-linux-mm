Received: by uproxy.gmail.com with SMTP id m3so15161uge
        for <linux-mm@kvack.org>; Wed, 08 Feb 2006 18:35:18 -0800 (PST)
Message-ID: <aec7e5c30602081835s8870713qa40a6cf88431cad1@mail.gmail.com>
Date: Thu, 9 Feb 2006 11:35:18 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [RFC] Removing page->flags
In-Reply-To: <43E9DBE8.8020900@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1139381183.22509.186.camel@localhost>
	 <43E9DBE8.8020900@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

On 2/8/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Magnus Damm wrote:
> > [RFC] Removing page-flags
> >
> > Removing page->flags might not be the right way to put this idea, but it
> > sums it up pretty good IMO. The idea is to save memory for smaller
> > machines and also improve scalability for large SMP systems. Maybe too
> > much overhead is introduced, hopefully someone of you can tell.
> >
> > Today each page->flags contain two types of information:
> > A) 21 bits defined in linux/page-flags.h
> > B) Zone, node and sparsemem section bit fields, covered in linux/mm.h
> >
> > On smaller systems (like my laptop), type B is only used to determine
> > which zone it belongs to using any given struct page. At least 8 bits
> > per struct page are unused in that case.
> >
> > Large NUMA systems use type B more efficiently, but the fact that type A
> > contains a mix of bits might be suboptimal. Especially since some bits
> > may require atomic operations while others are already protected and
> > doesn't require atomicy. The fact that the bits share the same word
> > forces us to use atomic-only operation, which may result in unnecessary
> > cache line bouncing.
> >
> > Moving type A bits:
> >
> > Instead of keeping the bits together, we spread them out and store a
> > pointer to them from pg_data_t.
> >
> > To be more exact, pg_data_t is extended to include an array of pointers,
> > one pointer per bit defined in linux/page-flags.h. Today that would be
> > 21 pointers. Each pointer is pointing to a bitmap, and the bitmap
> > contains one bit per page in the node. The bitmap should be indexed
> > using (pfn - node_start_pfn). Each one of these (21) bitmaps may be
> > accessed using atomic or non-atomic operations, all depending on how the
> > flag is used. This hopefully improves scalability.
> >
>
> There are a large number of paths which access essentially random struct
> pages (any memory allocation / deallocation, many pagecache operations).
> Your proposal basically guarantees at least an extra cache miss on such
> paths. On most modern machines the struct page should be less than or
> equal to a cacheline I think.

And this extra cache miss comes from accessing the flags in a
different cache line than the rest of the struct page, right? OTOH,
maybe it is more likely that a certain struct page is in the cache if
struct page would become smaller.

> Also, would you mind explaining how you'd allow non-atomic access to
> bits which are already protected somewhere else? Without adding extra
> cache misses for each different type of bit that is manipulated? Which
> bits do you have in mind, exactly?

I'm thinking about PG_lru and PG_active. PG_lru is always modified
under zone->lru_lock, and the same goes for PG_active (except in
shrink_list(), grr). But as you say above, breaking out the page flags
may result in an extra cache miss...

Also, I think it would be interesting to break out the page
replacement policy code and make it pluggable. Different page
replacement algorithms need different flags/information associated
with each page, so moving the flags from struct page was my way of
solving that. Page replacement flags would in that case be stored
somewhere else than the rest of the flags.

> I don't think operations on page flags should ever inhibit scalability
> just due to the fact they are atomic. Atomic bitops will hurt single
> threaded performance, but scalability would probably be impacted more
> by the extra cache misses and memory traffic.

Ok, so scalability is probably not improved by my proposal.

> The real hit to scalability is when there is multiple access to the same
> flags, but in that case the problem remains.

I'm not going to try to solve that one! =)

> > Removing type B bits:
> >
> > Instead of using the highest bits of page->flags to locate zones, nodes
> > or sparsemem section, let's remove them and locate them using alignment!
> >
>
> If we accept that type A bits are a good idea, then removing just type B
> is no point. Sometimes the more complex memory layouts will require more
> than just arithmetic (ie. memory loads) so I doubt that is worthwhile
> either.

Yes, removing type B bits only is no point. But I wonder how the
performance would be affected by using the "parent" struct page
instead of type B bits.

Thanks for the comments!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
