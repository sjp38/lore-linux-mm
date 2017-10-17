Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6BE16B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 19:05:25 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l18so1481259wrc.23
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 16:05:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y12si8726615wrg.369.2017.10.17.16.05.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 16:05:24 -0700 (PDT)
Date: Tue, 17 Oct 2017 16:05:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/7] mm: Batch radix tree operations when truncating
 pages
Message-Id: <20171017160521.33ca85c45431c355833daa63@linux-foundation.org>
In-Reply-To: <20171010151937.26984-8-jack@suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
	<20171010151937.26984-8-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Tue, 10 Oct 2017 17:19:37 +0200 Jan Kara <jack@suse.cz> wrote:

> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -294,6 +294,14 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
>  			min(end - index, (pgoff_t)PAGEVEC_SIZE),
>  			indices)) {
> +		/*
> +		 * Pagevec array has exceptional entries and we may also fail
> +		 * to lock some pages. So we store pages that can be deleted
> +		 * in an extra array.
> +		 */
> +		struct page *pages[PAGEVEC_SIZE];
> +		int batch_count = 0;

OK, but we could still use a new pagevec here.  Then
delete_from_page_cache_batch() and page_cache_tree_delete_batch() would
take one less argument.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
