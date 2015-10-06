Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 115BB6B0038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 09:54:44 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so221831849ioi.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 06:54:43 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id 85si22748761iot.140.2015.10.06.06.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 06:54:43 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so211602478pac.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 06:54:43 -0700 (PDT)
Date: Tue, 6 Oct 2015 22:54:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: fix obj_to_head use page_private(page) as
 value but not pointer
Message-ID: <20151006135303.GA31853@blaptop>
References: <1444033381-5726-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444033381-5726-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

On Mon, Oct 05, 2015 at 04:23:01PM +0800, Hui Zhu wrote:
> In function obj_malloc:
> 	if (!class->huge)
> 		/* record handle in the header of allocated chunk */
> 		link->handle = handle;
> 	else
> 		/* record handle in first_page->private */
> 		set_page_private(first_page, handle);
> The huge's page save handle to private directly.
> 
> But in obj_to_head:
> 	if (class->huge) {
> 		VM_BUG_ON(!is_first_page(page));
> 		return page_private(page);

Typo.
 		return *(unsigned long*)page_private(page);

Please fix the description.

> 	} else
> 		return *(unsigned long *)obj;
> It is used as a pointer.
> 
> So change obj_to_head use page_private(page) as value but not pointer
> in obj_to_head.

The reason why there is no problem until now is huge-class page is
born with ZS_FULL so it couldn't be migrated.
Therefore, it shouldn't be real bug in practice.
However, we need this patch for future-work "VM-aware zsmalloced
page migration" to reduce external fragmentation.

> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>

With fixing the comment,

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks for the fix, Hui.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
