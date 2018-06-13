Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9BBB6B0269
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:26:12 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id i1-v6so1874857pld.11
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:26:12 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 38-v6si3540167plc.446.2018.06.13.11.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:26:11 -0700 (PDT)
Subject: Re: [PATCHv3 10/17] x86/mm: Implement prep_encrypted_page() and
 arch_free_page()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-11-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <36997c9c-73c0-1d9d-6251-10315a4158f0@intel.com>
Date: Wed, 13 Jun 2018 11:26:10 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-11-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> prep_encrypted_page() also takes care about zeroing the page. We have to
> do this after KeyID is set for the page.

This is an implementation detail that has gone unmentioned until now but
has impacted at least half a dozen locations in previous patches.  Can
you rectify that, please?


> +void prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
> +{
> +	int i;
> +
> +	/*
> +	 * The hardware/CPU does not enforce coherency between mappings of the
> +	 * same physical page with different KeyIDs or encrypt ion keys.

What are "encrypt ion"s? :)

> +	 * We are responsible for cache management.
> +	 *
> +	 * We flush cache before allocating encrypted page
> +	 */
> +	clflush_cache_range(page_address(page), PAGE_SIZE << order);
> +
> +	for (i = 0; i < (1 << order); i++) {
> +		WARN_ON_ONCE(lookup_page_ext(page)->keyid);

/* All pages coming out of the allocator should have KeyID 0 */

> +		lookup_page_ext(page)->keyid = keyid;
> +		/* Clear the page after the KeyID is set. */
> +		if (zero)
> +			clear_highpage(page);
> +	}
> +}

How expensive is this?

> +void arch_free_page(struct page *page, int order)
> +{
> +	int i;
> 

	/* KeyId-0 pages were not used for MKTME and need no work */

... or something

> +	if (!page_keyid(page))
> +		return;

Is page_keyid() optimized so that all this goes away automatically when
MKTME is compiled out or unsupported?

> +	for (i = 0; i < (1 << order); i++) {
> +		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);
> +		lookup_page_ext(page)->keyid = 0;
> +	}
> +
> +	clflush_cache_range(page_address(page), PAGE_SIZE << order);
> +}
