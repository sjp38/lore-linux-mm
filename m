Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D0EA06B0074
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 11:21:37 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so2751469pab.41
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 08:21:37 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id vu10si6017974pbc.219.2014.03.14.08.21.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 08:21:36 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so2659604pdi.21
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 08:21:36 -0700 (PDT)
Date: Fri, 14 Mar 2014 15:24:17 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 3/6] mm: support madvise(MADV_FREE)
Message-ID: <20140314152417.GA4008@gmail.com>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
 <1394779070-8545-4-git-send-email-minchan@kernel.org>
 <20140314133311.GA6316@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140314133311.GA6316@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>

On Fri, Mar 14, 2014 at 03:33:11PM +0200, Kirill A. Shutemov wrote:
> On Fri, Mar 14, 2014 at 03:37:47PM +0900, Minchan Kim wrote:
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index c1b7414c7bef..9b048cabce27 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -933,10 +933,16 @@ void page_address_init(void);
> >   * Please note that, confusingly, "page_mapping" refers to the inode
> >   * address_space which maps the page from disk; whereas "page_mapped"
> >   * refers to user virtual address space into which the page is mapped.
> > + *
> > + * PAGE_MAPPING_LZFREE bit is set along with PAGE_MAPPING_ANON bit
> > + * and then page->mapping points to an anon_vma. This flag is used
> > + * for lazy freeing the page instead of swap.
> >   */
> >  #define PAGE_MAPPING_ANON	1
> >  #define PAGE_MAPPING_KSM	2
> > -#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
> > +#define PAGE_MAPPING_LZFREE	4
> > +#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM | \
> > +				 PAGE_MAPPING_LZFREE)
> 
> Is it safe to use third bit in pointer everywhere?

I overlooked ARCH_SLAB_MINALIGN which is 8 byte for most arch but
surely some of arch would have less than it(ex, 4 byte).

Alternative is PG_private or PG_private2. That flags is used for
file pages mostly while zsmalloc uses it but it should not LRU page.
Other thing in mm/ is memory-hotplug but I guess we don't need to set
PG_private because I couldn't find PagePrivate for that.

So, I think using that flag for anon page has no problem if we tweak
page_has_private works with only !PageAnon.

> 
> -- 
>  Kirill A. Shutemov
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
