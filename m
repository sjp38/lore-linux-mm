Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A3BD96B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 05:18:46 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id f206so21583301wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 02:18:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si136770265wja.161.2016.01.05.02.18.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 02:18:45 -0800 (PST)
Subject: Re: [PATCH 3/4] mm: stop __munlock_pagevec_fill() if THP enounted
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-4-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568B9884.30206@suse.cz>
Date: Tue, 5 Jan 2016 11:18:44 +0100
MIME-Version: 1.0
In-Reply-To: <1450957883-96356-4-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On 12/24/2015 12:51 PM, Kirill A. Shutemov wrote:
> THP is properly handled in munlock_vma_pages_range().
>
> It fixes crashes like this:
>   http://lkml.kernel.org/r/565C5C38.3040705@oracle.com
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Ack.

> ---
>   mm/mlock.c | 7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/mm/mlock.c b/mm/mlock.c
> index af421d8bd6da..9197b6721a1e 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -393,6 +393,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>   		if (!page || page_zone_id(page) != zoneid)
>   			break;
>
> +		/*
> +		 * Do not use pagevec for PTE-mapped THP,
> +		 * munlock_vma_pages_range() will handle them.
> +		 */
> +		if (PageTransCompound(page))
> +			break;
> +
>   		get_page(page);
>   		/*
>   		 * Increase the address that will be returned *before* the
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
