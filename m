Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2D55F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 13:05:58 -0400 (EDT)
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in
 the VM
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090407151010.E72A91D0471@basil.firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
	 <20090407151010.E72A91D0471@basil.firstfloor.org>
Content-Type: text/plain
Date: Wed, 08 Apr 2009 13:03:59 -0400
Message-Id: <1239210239.28688.15.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh@veritas.com, npiggin@suse.de, riel@redhat.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-07 at 17:10 +0200, Andi Kleen wrote:
> This patch adds the high level memory handler that poisons pages. 
> It is portable code and lives in mm/memory-failure.c

I think this is an important feature, thanks for doing all this work
Andi.

> Index: linux/mm/memory-failure.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux/mm/memory-failure.c	2009-04-07 16:39:39.000000000 +0200
> +
> +/*
> + * Clean (or cleaned) page cache page.
> + */
> +static int me_pagecache_clean(struct page *p)
> +{
> +	struct address_space *mapping;
> +
> +	if (PagePrivate(p))
> +		do_invalidatepage(p, 0);
> +	mapping = page_mapping(p);
> +	if (mapping) {
> +		if (!remove_mapping(mapping, p))
> +			return FAILED;
> +	}
> +	return RECOVERED;
> +}
> +
> +/*
> + * Dirty cache page page
> + * Issues: when the error hit a hole page the error is not properly
> + * propagated.
> + */
> +static int me_pagecache_dirty(struct page *p)
> +{
> +	struct address_space *mapping = page_mapping(p);
> +
> +	SetPageError(p);
> +	/* TBD: print more information about the file. */
> +	printk(KERN_ERR "MCE: Hardware memory corruption on dirty file page: write error\n");
> +	if (mapping) {
> +		/* CHECKME: does that report the error in all cases? */
> +		mapping_set_error(mapping, EIO);
> +	}
> +	if (PagePrivate(p)) {
> +		if (try_to_release_page(p, GFP_KERNEL)) {

So, try_to_release_page returns 1 when it works.  I know this only
because I have to read it every time to remember ;)

try_to_release_page is also very likely to fail if the page is dirty or
under writeback.  At the end of the day, we'll probably need a call into
the FS to tell it a given page isn't coming back, and to clean it at all
cost.

invalidatepage is close, but ext3/reiserfs will keep the buffer heads
and let the page->mapping go to null in an ugly data=ordered corner
case.  The buffer heads pin the page and it won't be freed until the IO
is done.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
