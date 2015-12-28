Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6555D6B0289
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 18:22:37 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id do7so3660822pab.2
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 15:22:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e7si21558106pas.227.2015.12.28.15.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 15:22:36 -0800 (PST)
Date: Mon, 28 Dec 2015 15:22:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm: stop __munlock_pagevec_fill() if THP enounted
Message-Id: <20151228152235.e756a78f4553ce38ca0e0b4d@linux-foundation.org>
In-Reply-To: <1450957883-96356-4-git-send-email-kirill.shutemov@linux.intel.com>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1450957883-96356-4-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Thu, 24 Dec 2015 14:51:22 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> THP is properly handled in munlock_vma_pages_range().
> 
> It fixes crashes like this:
>  http://lkml.kernel.org/r/565C5C38.3040705@oracle.com
> 
> ...
>
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -393,6 +393,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>  		if (!page || page_zone_id(page) != zoneid)
>  			break;
>  
> +		/*
> +		 * Do not use pagevec for PTE-mapped THP,
> +		 * munlock_vma_pages_range() will handle them.
> +		 */
> +		if (PageTransCompound(page))
> +			break;
> +
>  		get_page(page);
>  		/*
>  		 * Increase the address that will be returned *before* the

I'm trying to work out approximately which patch this patch fixes, and
it ain't easy.  Help?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
