Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E52936B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 11:01:58 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so330133wgh.14
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 08:01:56 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id az10si2121553wib.11.2014.08.27.08.01.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 08:01:55 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:01:39 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATH V2 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20140827150139.GZ30401@n2100.arm.linux.org.uk>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org> <1408635812-31584-2-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1408635812-31584-2-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de

On Thu, Aug 21, 2014 at 04:43:27PM +0100, Steve Capper wrote:
> +int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> +			struct page **pages)
> +{
> +	struct mm_struct *mm = current->mm;
> +	int nr, ret;
> +
> +	start &= PAGE_MASK;
> +	nr = __get_user_pages_fast(start, nr_pages, write, pages);
> +	ret = nr;
> +
> +	if (nr < nr_pages) {
> +		/* Try to get the remaining pages with get_user_pages */
> +		start += nr << PAGE_SHIFT;
> +		pages += nr;

When I read this, my first reaction was... what if nr is negative?  In
that case, if nr_pages is positive, we fall through into this if, and
start to wind things backwards - which isn't what we want.

It looks like that can't happen... right?  __get_user_pages_fast() only
returns greater-or-equal to zero right now, but what about the future?

> +
> +		down_read(&mm->mmap_sem);
> +		ret = get_user_pages(current, mm, start,
> +				     nr_pages - nr, write, 0, pages, NULL);
> +		up_read(&mm->mmap_sem);
> +
> +		/* Have to be a bit careful with return values */
> +		if (nr > 0) {

This kind'a makes it look like nr could be negative.

Other than that, I don't see anything obviously wrong with it.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
