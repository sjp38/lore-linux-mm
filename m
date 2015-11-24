Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DCBBC6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 23:28:43 -0500 (EST)
Received: by pacej9 with SMTP id ej9so8085495pac.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 20:28:43 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id fy6si202740pbd.163.2015.11.23.20.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 20:28:43 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so8034528pac.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 20:28:43 -0800 (PST)
Date: Tue, 24 Nov 2015 13:29:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -mm v2] mm: add page_check_address_transhuge helper
Message-ID: <20151124042941.GE705@swordfish>
References: <1448011913-12121-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448011913-12121-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

Hello,

On (11/20/15 12:31), Vladimir Davydov wrote:
[..]
> -	if (ptep_clear_flush_young_notify(vma, address, pte)) {
> -		/*
> -		 * Don't treat a reference through a sequentially read
> -		 * mapping as such.  If the page has been used in
> -		 * another mapping, we will catch it; if this other
> -		 * mapping is already gone, the unmap path will have
> -		 * set PG_referenced or activated the page.
> -		 */
> -		if (likely(!(vma->vm_flags & VM_SEQ_READ)))
> +	if (pte) {
> +		if (ptep_clear_flush_young_notify(vma, address, pte)) {
> +			/*
> +			 * Don't treat a reference through a sequentially read
> +			 * mapping as such.  If the page has been used in
> +			 * another mapping, we will catch it; if this other
> +			 * mapping is already gone, the unmap path will have
> +			 * set PG_referenced or activated the page.
> +			 */
> +			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
> +				referenced++;
> +		}
> +		pte_unmap(pte);
> +	} else {
> +		if (pmdp_clear_flush_young_notify(vma, address, pmd))
>  			referenced++;
>  	}

# CONFIG_TRANSPARENT_HUGEPAGE is not set

x86_64, 4.4.0-rc2-mm1


mm/built-in.o: In function `page_referenced_one':
rmap.c:(.text+0x32070): undefined reference to `pmdp_clear_flush_young'


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
