Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D7CA26B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 04:59:52 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id r20so480171wiv.11
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 01:59:49 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
        by mx.google.com with ESMTPS id oq3si5943162wjc.21.2014.08.28.01.59.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Aug 2014 01:59:48 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id r20so480114wiv.11
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 01:59:47 -0700 (PDT)
Date: Thu, 28 Aug 2014 09:59:40 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATH V2 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20140828085939.GA15409@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-2-git-send-email-steve.capper@linaro.org>
 <20140827150139.GZ30401@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827150139.GZ30401@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de

On Wed, Aug 27, 2014 at 04:01:39PM +0100, Russell King - ARM Linux wrote:

Hi Russell,

> On Thu, Aug 21, 2014 at 04:43:27PM +0100, Steve Capper wrote:
> > +int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> > +			struct page **pages)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	int nr, ret;
> > +
> > +	start &= PAGE_MASK;
> > +	nr = __get_user_pages_fast(start, nr_pages, write, pages);
> > +	ret = nr;
> > +
> > +	if (nr < nr_pages) {
> > +		/* Try to get the remaining pages with get_user_pages */
> > +		start += nr << PAGE_SHIFT;
> > +		pages += nr;
> 
> When I read this, my first reaction was... what if nr is negative?  In
> that case, if nr_pages is positive, we fall through into this if, and
> start to wind things backwards - which isn't what we want.
> 
> It looks like that can't happen... right?  __get_user_pages_fast() only
> returns greater-or-equal to zero right now, but what about the future?

__get_user_pages_fast is a strict fast path, it will grab as many page
references as it can and if something gets in its way it backs off. As
it can't take locks, it can't inspect the VMA, thus it really isn't in
a position to know if there's an error. It may be possible for the
slow path to take a write fault for a read only pte, for instance.
(we could in theory return an error on pte_special and save a fallback
to the slowpath but I don't believe it's worth doing as special ptes
should be encountered very rarely by the fast_gup).

I think it's safe to assume that __get_use_pages_fast has non-negative
return values; also it is logically contained in the same area as
get_user_pages_fast, so if this does change we can apply changes below
it too.

get_user_pages_fast attempts the fast path but is allowed to fallback
to the slowpath, so is in a position to return an error code thus can
return negative values.

> 
> > +
> > +		down_read(&mm->mmap_sem);
> > +		ret = get_user_pages(current, mm, start,
> > +				     nr_pages - nr, write, 0, pages, NULL);
> > +		up_read(&mm->mmap_sem);
> > +
> > +		/* Have to be a bit careful with return values */
> > +		if (nr > 0) {
> 
> This kind'a makes it look like nr could be negative.

I read it as "did the fast path get at least one page?".

> 
> Other than that, I don't see anything obviously wrong with it.

Thank you for giving this a going over.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
