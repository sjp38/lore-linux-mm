Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 586E56B0036
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 06:17:00 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so2650058pbc.40
        for <linux-mm@kvack.org>; Sat, 14 Jun 2014 03:16:59 -0700 (PDT)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id au10si4907052pbd.14.2014.06.14.03.16.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Jun 2014 03:16:59 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 14 Jun 2014 20:16:56 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 003163578047
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 20:16:52 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5EA0gsD38731896
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 20:00:43 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5EAGoVm008342
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 20:16:51 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 06/10] CMA: generalize CMA reserved area management functionality
In-Reply-To: <1402543307-29800-7-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <1402543307-29800-7-git-send-email-iamjoonsoo.kim@lge.com>
Date: Sat, 14 Jun 2014 15:46:44 +0530
Message-ID: <87a99fg5ir.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Currently, there are two users on CMA functionality, one is the DMA
> subsystem and the other is the kvm on powerpc. They have their own code
> to manage CMA reserved area even if they looks really similar.
> From my guess, it is caused by some needs on bitmap management. Kvm side
> wants to maintain bitmap not for 1 page, but for more size. Eventually it
> use bitmap where one bit represents 64 pages.
>
> When I implement CMA related patches, I should change those two places
> to apply my change and it seem to be painful to me. I want to change
> this situation and reduce future code management overhead through
> this patch.
>
> This change could also help developer who want to use CMA in their
> new feature development, since they can use CMA easily without
> copying & pasting this reserved area management code.
>
> In previous patches, we have prepared some features to generalize
> CMA reserved area management and now it's time to do it. This patch
> moves core functions to mm/cma.c and change DMA APIs to use
> these functions.
>
> There is no functional change in DMA APIs.
>
> v2: There is no big change from v1 in mm/cma.c. Mostly renaming.
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

.....

> +
> +	mask = cma_bitmap_aligned_mask(cma, align);
> +	bitmap_maxno = cma_bitmap_maxno(cma);
> +	nr_bits = cma_bitmap_pages_to_bits(cma, count);
> +
> +	for (;;) {
> +		mutex_lock(&cma->lock);
> +		bitmapno = bitmap_find_next_zero_area(cma->bitmap,
> +					bitmap_maxno, start, nr_bits, mask);
> +		if (bitmapno >= bitmap_maxno) {
> +			mutex_unlock(&cma->lock);
> +			break;
> +		}
> +		bitmap_set(cma->bitmap, bitmapno, nr_bits);
> +		/*
> +		 * It's safe to drop the lock here. We've marked this region for
> +		 * our exclusive use. If the migration fails we will take the
> +		 * lock again and unmark it.
> +		 */
> +		mutex_unlock(&cma->lock);
> +
> +		pfn = cma->base_pfn + (bitmapno << cma->order_per_bit);
> +		mutex_lock(&cma_mutex);
> +		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
> +		mutex_unlock(&cma_mutex);
> +		if (ret == 0) {
> +			page = pfn_to_page(pfn);
> +			break;
> +		} else if (ret != -EBUSY) {
> +			clear_cma_bitmap(cma, pfn, count);
> +			break;
> +		}
> +		


For setting bit map we do
		bitmap_set(cma->bitmap, bitmapno, nr_bits);
                alloc_contig()..
                if (error)
                        clear_cma_bitmap(cma, pfn, count);

Why ?

why not bitmap_clear() ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
