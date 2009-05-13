Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9E96B00EA
	for <linux-mm@kvack.org>; Wed, 13 May 2009 15:38:59 -0400 (EDT)
Date: Wed, 13 May 2009 12:34:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/6] PM/Hibernate: Rework shrinking of memory
Message-Id: <20090513123409.302f4307.akpm@linux-foundation.org>
In-Reply-To: <200905131039.26778.rjw@sisk.pl>
References: <200905070040.08561.rjw@sisk.pl>
	<200905101548.57557.rjw@sisk.pl>
	<200905131032.53624.rjw@sisk.pl>
	<200905131039.26778.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@lists.linux-foundation.org, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, pavel@ucw.cz, nigel@tuxonice.net, rientjes@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 10:39:25 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Rework swsusp_shrink_memory() so that it calls shrink_all_memory()
> just once to make some room for the image and then allocates memory
> to apply more pressure to the memory management subsystem, if
> necessary.
> 
> Unfortunately, we don't seem to be able to drop shrink_all_memory()
> entirely just yet, because that would lead to huge performance
> regressions in some test cases.
> 

Isn't this a somewhat large problem?  The main point (I thought) was
to remove shrink_all_memory().  Instead, we're retaining it and adding
even more stuff?

> +/**
> + * compute_fraction - Compute approximate fraction x * (a/b)
> + * @x: Number to multiply.
> + * @numerator: Numerator of the fraction (a).
> + * @denominator: Denominator of the fraction (b).
>   *
> - *	Notice: all userland should be stopped before it is called, or
> - *	livelock is possible.
> + * Compute an approximate value of the expression x * (a/b), where a is less
> + * than b, all x, a, b are unsigned longs and x * a may be greater than the
> + * maximum unsigned long.
>   */
> +static unsigned long compute_fraction(
> +	unsigned long x, unsigned long numerator, unsigned long denominator)

I can't say I'm a great fan of the code layout here.

static unsigned long compute_fraction(unsigned long x, unsigned long numerator, unsigned long denominator)

or

static unsigned long compute_fraction(unsigned long x, unsigned long numerator,
					unsigned long denominator)

would be more typical.


> +{
> +	unsigned long ratio = (numerator << FRACTION_SHIFT) / denominator;
>  
> -#define SHRINK_BITE	10000
> -static inline unsigned long __shrink_memory(long tmp)
> +	x *= ratio;
> +	return x >> FRACTION_SHIFT;
> +}

Strange function.  Would it not be simpler/clearer to do it with 64-bit
scalars, multiplication and do_div()?

> +static unsigned long highmem_size(
> +	unsigned long size, unsigned long highmem, unsigned long count)
> +{
> +	return highmem > count / 2 ?
> +			compute_fraction(size, highmem, count) :
> +			size - compute_fraction(size, count - highmem, count);
> +}

This would be considerably easier to follow if we know what the three
arguments represent.  Amount of memory?  In what units?  `count' of
what?

The `count/2' thing there is quite mysterious.

<does some reverse-engineering>

OK, `count' is "the number of pageframes we can use".  (I don't think I
helped myself a lot there).  But what's up with that divde-by-two?

<considers poking at callers to work out what `size' is>

<gives up>

Is this code as clear as we can possibly make it??

> +#else
> +static inline unsigned long preallocate_image_highmem(unsigned long nr_pages)
> +{
> +	return 0;
> +}
> +
> +static inline unsigned long highmem_size(
> +	unsigned long size, unsigned long highmem, unsigned long count)
>  {
> -	if (tmp > SHRINK_BITE)
> -		tmp = SHRINK_BITE;
> -	return shrink_all_memory(tmp);
> +	return 0;
>  }
> +#endif /* CONFIG_HIGHMEM */
>  
> +/**
> + * swsusp_shrink_memory -  Make the kernel release as much memory as needed
> + *
> + * To create a hibernation image it is necessary to make a copy of every page
> + * frame in use.  We also need a number of page frames to be free during
> + * hibernation for allocations made while saving the image and for device
> + * drivers, in case they need to allocate memory from their hibernation
> + * callbacks (these two numbers are given by PAGES_FOR_IO and SPARE_PAGES,
> + * respectively, both of which are rough estimates).  To make this happen, we
> + * compute the total number of available page frames and allocate at least
> + *
> + * ([page frames total] + PAGES_FOR_IO + [metadata pages]) / 2 + 2 * SPARE_PAGES
> + *
> + * of them, which corresponds to the maximum size of a hibernation image.
> + *
> + * If image_size is set below the number following from the above formula,
> + * the preallocation of memory is continued until the total number of saveable
> + * pages in the system is below the requested image size or it is impossible to
> + * allocate more memory, whichever happens first.
> + */

OK, that helps.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
