Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5B136B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:07:18 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e126so10203155pfh.4
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:07:18 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e13-v6si8599138pln.204.2018.03.05.11.07.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:07:17 -0800 (PST)
Subject: Re: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a692b2ff-b590-b731-ad14-18238f471a1c@intel.com>
Date: Mon, 5 Mar 2018 11:07:16 -0800
MIME-Version: 1.0
In-Reply-To: <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> +void free_encrypt_page(struct page *page, int keyid, unsigned int order)
> +{
> +	int i;
> +	void *v;
> +
> +	for (i = 0; i < (1 << order); i++) {
> +		v = kmap_atomic_keyid(page, keyid + i);
> +		/* See comment in prep_encrypt_page() */
> +		clflush_cache_range(v, PAGE_SIZE);
> +		kunmap_atomic(v);
> +	}
> +}

Have you measured how slow this is?

It's an optimization, but can we find a way to only do this dance when
we *actually* change the keyid?  Right now, we're doing mapping at alloc
and free, clflushing at free and zeroing at alloc.  Let's say somebody does:

	ptr = malloc(PAGE_SIZE);
	*ptr = foo;
	free(ptr);

	ptr = malloc(PAGE_SIZE);
	*ptr = bar;
	free(ptr);

And let's say ptr is in encrypted memory and that we actually munmap()
at free().  We can theoretically skip the clflush, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
