Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l35FGXX4001842
	for <linux-mm@kvack.org>; Thu, 5 Apr 2007 11:16:33 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l35FGXQm285004
	for <linux-mm@kvack.org>; Thu, 5 Apr 2007 11:16:33 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l35FGXb1020452
	for <linux-mm@kvack.org>; Thu, 5 Apr 2007 11:16:33 -0400
Subject: Re: [RFC] Free up page->private for compound pages
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0704042016490.7885@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704042016490.7885@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 05 Apr 2007 10:13:52 -0500
Message-Id: <1175786037.28125.8.camel@shaggy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, dgc@sgi.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 20:19 -0700, Christoph Lameter wrote:

> Index: linux-2.6.21-rc5-mm4/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.21-rc5-mm4.orig/include/linux/page-flags.h	2007-04-03 23:48:34.000000000 -0700
> +++ linux-2.6.21-rc5-mm4/include/linux/page-flags.h	2007-04-04 18:25:47.000000000 -0700
> @@ -91,6 +91,7 @@
>  #define PG_booked		20	/* Has blocks reserved on-disk */
> 
>  #define PG_readahead		21	/* Reminder to do read-ahead */
> +#define PG_tail			22	/* Tail portion of a compound page */
> 
>  /* PG_owner_priv_1 users should have descriptive aliases */
>  #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
> @@ -214,6 +215,10 @@ static inline void SetPageUptodate(struc
>  #define __SetPageCompound(page)	__set_bit(PG_compound, &(page)->flags)
>  #define __ClearPageCompound(page) __clear_bit(PG_compound, &(page)->flags)
> 
> +#define PageTail(page)	test_bit(PG_tail, &(page)->flags)
> +#define __SetPageTail(page)	__set_bit(PG_tail, &(page)->flags)
> +#define __ClearPageTail(page)	__clear_bit(PG_tail, &(page)->flags)
> +
>  #ifdef CONFIG_SWAP
>  #define PageSwapCache(page)	test_bit(PG_swapcache, &(page)->flags)
>  #define SetPageSwapCache(page)	set_bit(PG_swapcache, &(page)->flags)

Wow, I was planning on adding that exact flag for the work I'm doing
with Page Cache Tails:
http://kernel.org/pub/linux/kernel/people/shaggy/OLS-2006/

I'm working on killing the page flag, but I am still using PageTail() to
test for the special-case page.  No worry.  I'll rename it to something
less ambiguous.

As far as the Page Cache Tail work, I'll try to get some patches out for
review soon.

Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
