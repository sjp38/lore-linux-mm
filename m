Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6F76B026A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:03:29 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i10-v6so21030510qtp.13
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:03:29 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b48-v6si15786799qtc.146.2018.07.09.11.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:03:28 -0700 (PDT)
Date: Mon, 9 Jul 2018 14:03:20 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv4 02/18] mm/ksm: Do not merge pages with different KeyIDs
Message-ID: <20180709180320.GG6873@char.US.ORACLE.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626142245.82850-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 26, 2018 at 05:22:29PM +0300, Kirill A. Shutemov wrote:
> Pages encrypted with different encryption keys are not subject to KSM

Perhaps not allowed instead of subject?
> merge. Otherwise it would cross security boundary.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mm.h | 7 +++++++
>  mm/ksm.c           | 3 +++
>  2 files changed, 10 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ebf4bd8bd0bf..406a28cadfcf 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1548,6 +1548,13 @@ static inline int vma_keyid(struct vm_area_struct *vma)
>  }
>  #endif
>  
> +#ifndef page_keyid
> +static inline int page_keyid(struct page *page)
> +{
> +	return 0;
> +}
> +#endif
> +
>  #ifdef CONFIG_SHMEM
>  /*
>   * The vma_is_shmem is not inline because it is used only by slow
> diff --git a/mm/ksm.c b/mm/ksm.c
> index a6d43cf9a982..1bd7b9710e29 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1214,6 +1214,9 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
>  	if (!PageAnon(page))
>  		goto out;
>  
> +	if (page_keyid(page) != page_keyid(kpage))
> +		goto out;
> +
>  	/*
>  	 * We need the page lock to read a stable PageSwapCache in
>  	 * write_protect_page().  We use trylock_page() instead of
> -- 
> 2.18.0
> 
