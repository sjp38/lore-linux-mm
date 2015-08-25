Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 134F76B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 22:16:56 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so61423217pdr.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 19:16:55 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id cm6si30477658pad.228.2015.08.24.19.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 19:16:55 -0700 (PDT)
Received: by pdrh1 with SMTP id h1so61423083pdr.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 19:16:55 -0700 (PDT)
Date: Tue, 25 Aug 2015 11:17:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv2 2/4] zsmalloc: use page->private instead of
 page->first_page
Message-ID: <20150825021735.GA412@swordfish>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439824145-25397-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439824145-25397-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (08/17/15 18:09), Kirill A. Shutemov wrote:
[..]
> @@ -980,7 +979,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
>  		if (i == 1)
>  			set_page_private(first_page, (unsigned long)page);
>  		if (i >= 1)
> -			page->first_page = first_page;
> +			set_page_private(first_page, (unsigned long)first_page);

This patch breaks zram/zsmalloc.

Shouldn't it be `page->private = first_page' instead of
`first_page->private = first_page'? IOW:

-	set_page_private(first_page, (unsigned long)first_page);
+	set_page_private(page, (unsigned long)first_page);

?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
