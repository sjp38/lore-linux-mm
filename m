Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C37B56B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 16:55:58 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so61661533pab.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 13:55:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bx10si28769940pdb.154.2015.05.13.13.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 13:55:57 -0700 (PDT)
Date: Wed, 13 May 2015 13:55:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: initialize order with UINT_MAX in
 dissolve_free_huge_pages()
Message-Id: <20150513135556.5d21cd52810f87460eb1f2a1@linux-foundation.org>
In-Reply-To: <20150513014418.GB14599@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda>
	<20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
	<20150512084339.GN16501@mwanda>
	<20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
	<20150512091349.GO16501@mwanda>
	<20150512091640.GE3068@hori1.linux.bs1.fc.nec.co.jp>
	<20150512092034.GF3068@hori1.linux.bs1.fc.nec.co.jp>
	<20150512161511.7967c400cae6c1d693b61d57@linux-foundation.org>
	<20150513014418.GB14599@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 13 May 2015 01:44:22 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> > >  			order = huge_page_order(h);
> > >  	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
> > > +	VM_BUG_ON(order == UINT_MAX);
> > >  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
> > >  		dissolve_free_huge_page(pfn_to_page(pfn));
> > 
> > Do we need to calculate this each time?  Can it be done in
> > hugetlb_init_hstates(), save the result in a global?
> 
> Yes, it should work. How about the following?
> This adds 4bytes to .data due to a new global variable, but reduces 47 bytes
> .text size of code reduces, so it's a win in total.
> 
>    text    data     bss     dec     hex filename                         
>   28313     469   84236  113018   1b97a mm/hugetlb.o (above patch)
>   28266     473   84236  112975   1b94f mm/hugetlb.o (below patch)

Looks good.  Please turn it into a real patch and send it over when
convenient?

> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -40,6 +40,7 @@ int hugepages_treat_as_movable;
>  int hugetlb_max_hstate __read_mostly;
>  unsigned int default_hstate_idx;
>  struct hstate hstates[HUGE_MAX_HSTATE];
> +unsigned int minimum_order __read_mostly;

static.

And a comment would be nice ;)

>
> ...
>
> @@ -1626,11 +1621,16 @@ static void __init hugetlb_init_hstates(void)
>  {
>  	struct hstate *h;
>  
> +	minimum_order = UINT_MAX;

Do this at compile time.

>  	for_each_hstate(h) {
> +		if (minimum_order > huge_page_order(h))
> +			minimum_order = huge_page_order(h);
> +
>  		/* oversize hugepages were init'ed in early boot */
>  		if (!hstate_is_gigantic(h))
>  			hugetlb_hstate_alloc_pages(h);
>  	}
> +	VM_BUG_ON(minimum_order == UINT_MAX);

Is the system hopelessly screwed up when this happens, or will it still
be able to boot up and do useful things?

If the system is hopelessly broken then BUG_ON or, better, panic should
be used here.  But if there's still potential to do useful things then
I guess VM_BUG_ON is appropriate.


>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
