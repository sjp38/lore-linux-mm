Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC63C6B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:03:57 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id f3-v6so8444154plf.18
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:03:57 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l6si8769480pgs.288.2018.03.05.11.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:03:56 -0800 (PST)
Subject: Re: [RFC, PATCH 18/22] x86/mm: Handle allocation of encrypted pages
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-19-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e2fed2a7-88db-96f0-56f5-b20b624eb665@intel.com>
Date: Mon, 5 Mar 2018 11:03:55 -0800
MIME-Version: 1.0
In-Reply-To: <20180305162610.37510-19-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> -#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
> -	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
>  #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
> +#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr)			\
> +({										\
> +	struct page *page;							\
> +	gfp_t gfp = movableflags | GFP_HIGHUSER;				\
> +	if (vma_is_encrypted(vma))						\
> +		page = __alloc_zeroed_encrypted_user_highpage(gfp, vma, vaddr);	\
> +	else									\
> +		page = alloc_page_vma(gfp | __GFP_ZERO, vma, vaddr);		\
> +	page;									\
> +})

This is pretty darn ugly and also adds a big old branch into the hottest
path in the page allocator.

It's also really odd that you strip __GFP_ZERO and then go ahead and
zero the encrypted page unconditionally.  It really makes me wonder if
this is the right spot to be doing this.

Can we not, for instance do it inside alloc_page_vma()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
