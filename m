Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5459E6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 17:39:51 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id h3so5209332qgf.11
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:39:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si2713853qgi.19.2015.02.11.14.39.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 14:39:50 -0800 (PST)
Date: Wed, 11 Feb 2015 23:16:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge pages
Message-ID: <20150211221600.GN11755@redhat.com>
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com

On Wed, Feb 11, 2015 at 11:03:55PM +0200, Ebru Akagunduz wrote:
> Changes in v2:
>  - Check zero pfn in release_pte_pages() (Andrea Arcangeli)

.. and in:

> @@ -2237,7 +2237,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
>  		pte_t pteval = *_pte;
>  		struct page *src_page;
>  
> -		if (pte_none(pteval)) {
> +		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
>  			clear_user_highpage(page, address);
>  			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
>  		} else {

__collapse_huge_page_copy, both were needed as far as I can tell.

I haven't tested it but it's looking good.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
