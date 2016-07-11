Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A15596B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 03:26:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so103508015pfx.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 00:26:20 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id c63si2232947pfa.138.2016.07.11.00.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 00:26:19 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id g202so2244551pfb.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 00:26:19 -0700 (PDT)
Date: Mon, 11 Jul 2016 16:24:17 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 3/3] mm/page_owner: track page free call chain
Message-ID: <20160711072417.GA524@swordfish>
References: <20160708121132.8253-1-sergey.senozhatsky@gmail.com>
 <20160708121132.8253-4-sergey.senozhatsky@gmail.com>
 <20160711062115.GC14107@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160711062115.GC14107@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/11/16 15:21), Joonsoo Kim wrote:
[..]
> > +void __page_owner_free_pages(struct page *page, unsigned int order)
> > +{
> > +	int i;
> > +	depot_stack_handle_t handle = save_stack(0);
> > +
> > +	for (i = 0; i < (1 << order); i++) {
> > +		struct page_ext *page_ext = lookup_page_ext(page + i);
> > +
> > +		if (unlikely(!page_ext))
> > +			continue;
> > +
> > +		page_ext->handles[PAGE_OWNER_HANDLE_FREE] = handle;
> > +		__set_bit(PAGE_EXT_OWNER_FREE, &page_ext->flags);
> > +		__clear_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags);
> > +	}
> > +}
> 
> I can't find any clear function to PAGE_EXT_OWNER_FREE. Isn't it
> intended? If so, why?

the PAGE_EXT_OWNER_FREE bit is not heavily used now. the
only place is this test in __dump_page_owner()

	if (!test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags) &&
			!test_bit(PAGE_EXT_OWNER_FREE, &page_ext->flags)) {
		pr_alert("page_owner info is not active (free page?)\n");
		return;
	}

other than that it's for symmetry/future use.

[..]
> > @@ -1073,6 +1073,9 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
> >  			if (!test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags))
> >  				continue;
> >  
> > +			if (!test_bit(PAGE_EXT_OWNER_FREE, &page_ext->flags))
> > +				continue;
> > +
> 
> I don't think this line is correct. Above PAGE_EXT_OWNER_ALLOC
> check is to find allocated page.

you are right. that PAGE_EXT_OWNER_FREE test is wrong, indeed.
thanks for spotting.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
