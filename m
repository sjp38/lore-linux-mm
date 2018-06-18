Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF116B0008
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:18:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p29-v6so8449875pfi.19
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 03:18:32 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id v10-v6si13824667plo.326.2018.06.18.03.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 03:18:30 -0700 (PDT)
Date: Mon, 18 Jun 2018 13:18:28 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 10/17] x86/mm: Implement prep_encrypted_page() and
 arch_free_page()
Message-ID: <20180618101828.hxp2dw3fmfxwk2ka@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-11-kirill.shutemov@linux.intel.com>
 <36997c9c-73c0-1d9d-6251-10315a4158f0@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <36997c9c-73c0-1d9d-6251-10315a4158f0@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:26:10PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > prep_encrypted_page() also takes care about zeroing the page. We have to
> > do this after KeyID is set for the page.
> 
> This is an implementation detail that has gone unmentioned until now but
> has impacted at least half a dozen locations in previous patches.  Can
> you rectify that, please?

It was mentioned in commit message of 04/17.

> > +void prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
> > +{
> > +	int i;
> > +
> > +	/*
> > +	 * The hardware/CPU does not enforce coherency between mappings of the
> > +	 * same physical page with different KeyIDs or encrypt ion keys.
> 
> What are "encrypt ion"s? :)

:P

> > +	 * We are responsible for cache management.
> > +	 *
> > +	 * We flush cache before allocating encrypted page
> > +	 */
> > +	clflush_cache_range(page_address(page), PAGE_SIZE << order);
> > +
> > +	for (i = 0; i < (1 << order); i++) {
> > +		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
> 
> /* All pages coming out of the allocator should have KeyID 0 */
> 

Okay.

> > +		lookup_page_ext(page)->keyid = keyid;
> > +		/* Clear the page after the KeyID is set. */
> > +		if (zero)
> > +			clear_highpage(page);
> > +	}
> > +}
> 
> How expensive is this?

It just shifts cost of zeroing from page allocator here. It should not
have huge effect.

> > +void arch_free_page(struct page *page, int order)
> > +{
> > +	int i;
> > 
> 
> 	/* KeyId-0 pages were not used for MKTME and need no work */
> 
> ... or something

Okay.

> > +	if (!page_keyid(page))
> > +		return;
> 
> Is page_keyid() optimized so that all this goes away automatically when
> MKTME is compiled out or unsupported?

If MKTME is not enabled compile-time, this translation unit doesn't
compile at all.

I have not yet optimized for run-time unsupported case. I'll optimized it
based on performance measurements.

> > +	for (i = 0; i < (1 << order); i++) {
> > +		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);
> > +		lookup_page_ext(page)->keyid = 0;
> > +	}
> > +
> > +	clflush_cache_range(page_address(page), PAGE_SIZE << order);
> > +}
> 
> 
> 
> 

-- 
 Kirill A. Shutemov
