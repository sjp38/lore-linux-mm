Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 478A16B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 12:37:17 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f64so721060pfd.6
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 09:37:17 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z15si359187pgr.595.2017.12.05.09.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 09:37:15 -0800 (PST)
Date: Tue, 5 Dec 2017 09:37:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] dax: fix potential overflow on 32bit machine
Message-ID: <20171205173713.GA26021@bombadil.infradead.org>
References: <20171205033210.38338-1-yi.zhang@huawei.com>
 <20171205052407.GA20757@bombadil.infradead.org>
 <20171205170709.GA21010@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205170709.GA21010@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, viro@zeniv.linux.org.uk, miaoxie@huawei.com

On Tue, Dec 05, 2017 at 10:07:09AM -0700, Ross Zwisler wrote:
> >  /* The 'colour' (ie low bits) within a PMD of a page offset.  */
> >  #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
> > +#define PG_PMD_NR	(PMD_SIZE >> PAGE_SHIFT)
> 
> I wonder if it's confusing that PG_PMD_COLOUR is a mask, but PG_PMD_NR is a
> count?  Would "PAGES_PER_PMD" be clearer, in the spirit of
> PTRS_PER_{PGD,PMD,PTE}? 

Maybe.  I don't think that 'NR' can ever be confused with a mask.
I went with PG_PMD_NR because I didn't want to use HPAGE_PMD_NR, but
in retrospect I just needed to go to sleep and leave thinking about
hard problems like naming things for the morning.  I decided to call it
'colour' rather than 'mask' originally because I got really confused with
PMD_MASK masking off the low bits.  If you ask 'What colour is this page
within the PMD', you know you're talking about the low bits.

I actually had cause to define PMD_ORDER in a separate unrelated patch
I was working on this morning.  How does this set of definitions grab you?

#define PMD_ORDER	(PMD_SHIFT - PAGE_SHIFT)
#define PMD_PAGES	(1UL << PMD_ORDER)
#define PMD_PAGE_COLOUR	(PMD_PAGES - 1)

and maybe put them in linux/mm.h so everybody can see them?

> Also, can we use the same define both in fs/dax.c and in mm/truncate.c,
> instead of the latter using HPAGE_PMD_NR?

I'm OK with the latter using HPAGE_PMD_NR because it's explicitly "is
this a huge page?"  But I'd kind of like to get rid of a lot of the HPAGE_*
definitions, so 

> >  static wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
> >  
> > @@ -375,8 +376,8 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
> >  		 * unmapped.
> >  		 */
> >  		if (pmd_downgrade && dax_is_zero_entry(entry))
> > -			unmap_mapping_range(mapping,
> > -				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> > +			unmap_mapping_pages(mapping, index & ~PG_PMD_COLOUR,
> > +							PG_PMD_NR, 0);
> >  
> >  		err = radix_tree_preload(
> >  				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
> > @@ -538,12 +539,10 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
> >  	if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_ZERO_PAGE)) {
> >  		/* we are replacing a zero page with block mapping */
> >  		if (dax_is_pmd_entry(entry))
> > -			unmap_mapping_range(mapping,
> > -					(vmf->pgoff << PAGE_SHIFT) & PMD_MASK,
> > -					PMD_SIZE, 0);
> > +			unmap_mapping_pages(mapping, vmf->pgoff & PG_PMD_COLOUR,
> 
> I think you need: 						 ~PG_PMD_COLOUR,

Heh, yeah, I fixed that in v2 ... which I forgot to cc you on.  Sorry.
It's on linux-fsdevel & linux-mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
