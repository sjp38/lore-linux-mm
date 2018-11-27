Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1936B4824
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:26:54 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b17so3102446pfc.11
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:26:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f4-v6si3905781plo.111.2018.11.27.05.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Nov 2018 05:26:53 -0800 (PST)
Date: Tue, 27 Nov 2018 05:26:50 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 04/10] mm/khugepaged: collapse_shmem() stop if punched or
 truncated
Message-ID: <20181127132650.GO3065@bombadil.infradead.org>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261522040.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261522040.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:23:37PM -0800, Hugh Dickins wrote:
>  		VM_BUG_ON(index != xas.xa_index);
>  		if (!page) {
> +			/*
> +			 * Stop if extent has been truncated or hole-punched,
> +			 * and is now completely empty.
> +			 */
> +			if (index == start) {
> +				if (!xas_next_entry(&xas, end - 1)) {
> +					result = SCAN_TRUNCATED;
> +					break;
> +				}
> +				xas_set(&xas, index);
> +			}
>  			if (!shmem_charge(mapping->host, 1)) {

Reviewed-by: Matthew Wilcox <willy@infradead.org>

I'd use xas_find() directly here; I don't think it warrants the inlined
version of xas_next_entry().  But I'm happy either way.
