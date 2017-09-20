Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7186B02E5
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 19:46:46 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 11so8067344pge.4
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:46 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b34si94534plc.58.2017.09.20.16.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 16:46:44 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
 <20170911145020.fat456njvyagcomu@docker>
 <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
 <431e2567-7600-3186-1489-93b855c395bd@huawei.com>
 <20170912143636.avc3ponnervs43kj@docker>
 <20170912181303.aqjj5ri3mhscw63t@docker>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <91923595-7f02-3be0-9c59-9c1fd20c82a8@intel.com>
Date: Wed, 20 Sep 2017 16:46:41 -0700
MIME-Version: 1.0
In-Reply-To: <20170912181303.aqjj5ri3mhscw63t@docker>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, Yisheng Xie <xieyisheng1@huawei.com>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, x86@kernel.org

On 09/12/2017 11:13 AM, Tycho Andersen wrote:
> -void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
> +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map)
>  {
>  	int i, flush_tlb = 0;
>  	struct xpfo *xpfo;
> @@ -116,8 +116,14 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
>  			 * Tag the page as a user page and flush the TLB if it
>  			 * was previously allocated to the kernel.
>  			 */
> -			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
> +			bool was_user = !test_and_set_bit(XPFO_PAGE_USER,
> +							  &xpfo->flags);
> +
> +			if (was_user || !will_map) {
> +				set_kpte(page_address(page + i), page + i,
> +					 __pgprot(0));
>  				flush_tlb = 1;
> +			}

Shouldn't the "was_user" be "was_kernel"?

Also, the way this now works, let's say we have a nice, 2MB pmd_t (page
table entry) mapping a nice, 2MB page in the allocator.  Then it gets
allocated to userspace.  We do

	for (i = 0; i < (1 << order); i++)  {
		...
		set_kpte(page_address(page + i), page+i, __pgprot(0));
	}

The set_kpte() will take the nice, 2MB mapping and break it down into
512 4k mappings, all pointing to a non-present PTE, in a newly-allocated
PTE page.  So, you get the same result and waste 4k of memory in the
process, *AND* make it slower because we added a level to the page tables.

I think you actually want to make a single set_kpte() call at the end of
the function.  That's faster and preserves the large page in the direct
mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
