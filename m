Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 1A51B6B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 06:39:00 -0400 (EDT)
Date: Tue, 16 Jul 2013 05:38:58 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
Message-ID: <20130716103857.GH3421@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <1373594635-131067-5-git-send-email-holt@sgi.com>
 <20130715143037.8287ffbf2fb0e72bc8efb287@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130715143037.8287ffbf2fb0e72bc8efb287@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

On Mon, Jul 15, 2013 at 02:30:37PM -0700, Andrew Morton wrote:
> On Thu, 11 Jul 2013 21:03:55 -0500 Robin Holt <holt@sgi.com> wrote:
> 
> > During boot of large memory machines, a significant portion of boot
> > is spent initializing the struct page array.  The vast majority of
> > those pages are not referenced during boot.
> > 
> > Change this over to only initializing the pages when they are
> > actually allocated.
> > 
> > Besides the advantage of boot speed, this allows us the chance to
> > use normal performance monitoring tools to determine where the bulk
> > of time is spent during page initialization.
> > 
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1330,8 +1330,19 @@ static inline void __free_reserved_page(struct page *page)
> >  	__free_page(page);
> >  }
> >  
> > +extern void __reserve_bootmem_region(phys_addr_t start, phys_addr_t end);
> > +
> > +static inline void __reserve_bootmem_page(struct page *page)
> > +{
> > +	phys_addr_t start = page_to_pfn(page) << PAGE_SHIFT;
> > +	phys_addr_t end = start + PAGE_SIZE;
> > +
> > +	__reserve_bootmem_region(start, end);
> > +}
> 
> It isn't obvious that this needed to be inlined?

It is being declared in a header file.  All the other functions I came
across in that header file are declared as inline (or __always_inline).
It feels to me like this is right.  Can I leave it as-is?

> 
> >  static inline void free_reserved_page(struct page *page)
> >  {
> > +	__reserve_bootmem_page(page);
> >  	__free_reserved_page(page);
> >  	adjust_managed_page_count(page, 1);
> >  }
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > index 6d53675..79e8eb7 100644
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -83,6 +83,7 @@ enum pageflags {
> >  	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
> >  	PG_arch_1,
> >  	PG_reserved,
> > +	PG_uninitialized2mib,	/* Is this the right spot? ntz - Yes - rmh */
> 
> "mib" creeps me out too.  And it makes me think of SNMP, which I'd
> prefer not to think about.
> 
> We've traditionally had fears of running out of page flags, but I've
> lost track of how close we are to that happening.  IIRC the answer
> depends on whether you believe there is such a thing as a 32-bit NUMA
> system.
> 
> Can this be avoided anyway?  I suspect there's some idiotic combination
> of flags we could use to indicate the state.  PG_reserved|PG_lru or
> something.
> 
> "2MB" sounds terribly arch-specific.  Shouldn't we make it more generic
> for when the hexagon64 port wants to use 4MB?
> 
> That conversational code comment was already commented on, but it's
> still there?

I am going to work on making it non-2m based over the course of this
week, so expect the _2m (current name based on Yinghai's comments)
to go away entirely.

> > 
> > ...
> >
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -740,6 +740,54 @@ static void __init_single_page(struct page *page, unsigned long zone, int nid, i
> >  #endif
> >  }
> >  
> > +static void expand_page_initialization(struct page *basepage)
> > +{
> > +	unsigned long pfn = page_to_pfn(basepage);
> > +	unsigned long end_pfn = pfn + PTRS_PER_PMD;
> > +	unsigned long zone = page_zonenum(basepage);
> > +	int reserved = PageReserved(basepage);
> > +	int nid = page_to_nid(basepage);
> > +
> > +	ClearPageUninitialized2Mib(basepage);
> > +
> > +	for( pfn++; pfn < end_pfn; pfn++ )
> > +		__init_single_page(pfn_to_page(pfn), zone, nid, reserved);
> > +}
> > +
> > +void ensure_pages_are_initialized(unsigned long start_pfn,
> > +				  unsigned long end_pfn)
> 
> I think this can be made static.  I hope so, as it's a somewhat
> odd-sounding identifier for a global.

Done.

> > +{
> > +	unsigned long aligned_start_pfn = start_pfn & ~(PTRS_PER_PMD - 1);
> > +	unsigned long aligned_end_pfn;
> > +	struct page *page;
> > +
> > +	aligned_end_pfn = end_pfn & ~(PTRS_PER_PMD - 1);
> > +	aligned_end_pfn += PTRS_PER_PMD;
> > +	while (aligned_start_pfn < aligned_end_pfn) {
> > +		if (pfn_valid(aligned_start_pfn)) {
> > +			page = pfn_to_page(aligned_start_pfn);
> > +
> > +			if(PageUninitialized2Mib(page))
> 
> checkpatch them, please.

Will certainly do.

> > +				expand_page_initialization(page);
> > +		}
> > +
> > +		aligned_start_pfn += PTRS_PER_PMD;
> > +	}
> > +}
> 
> Some nice code comments for the above two functions would be helpful.

Will do.

> > 
> > ...
> >
> > +int __meminit pfn_range_init_avail(unsigned long pfn, unsigned long end_pfn,
> > +				   unsigned long size, int nid)
> > +{
> > +	unsigned long validate_end_pfn = pfn + size;
> > +
> > +	if (pfn & (size - 1))
> > +		return 1;
> > +
> > +	if (pfn + size >= end_pfn)
> > +		return 1;
> > +
> > +	while (pfn < validate_end_pfn)
> > +	{
> > +		if (!early_pfn_valid(pfn))
> > +			return 1;
> > +		if (!early_pfn_in_nid(pfn, nid))
> > +			return 1;
> > +		pfn++;
> > + 	}
> > +
> > +	return size;
> > +}
> 
> Document it, please.  The return value semantics look odd, so don't
> forget to explain all that as well.

Will do.  Will also work on the name to make it more clear what we
are returning.

> > 
> > ...
> >
> > @@ -6196,6 +6302,7 @@ static const struct trace_print_flags pageflag_names[] = {
> >  	{1UL << PG_owner_priv_1,	"owner_priv_1"	},
> >  	{1UL << PG_arch_1,		"arch_1"	},
> >  	{1UL << PG_reserved,		"reserved"	},
> > +	{1UL << PG_uninitialized2mib,	"Uninit_2MiB"	},
> 
> It would be better if the name which is visible in procfs matches the
> name in the kernel source code.

Done and will try to maintain the consistency.

> >  	{1UL << PG_private,		"private"	},
> >  	{1UL << PG_private_2,		"private_2"	},
> >  	{1UL << PG_writeback,		"writeback"	},

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
