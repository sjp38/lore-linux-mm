Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE3126B000D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 17:47:32 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a40-v6so15449302pla.5
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 14:47:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o12-v6si31538235plg.154.2018.11.01.14.47.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 14:47:31 -0700 (PDT)
Date: Thu, 1 Nov 2018 14:47:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm/page_owner: clamp read count to PAGE_SIZE
Message-Id: <20181101144723.3ddc1fa1ab7f81184bc2fdb8@linux-foundation.org>
In-Reply-To: <1541091607-27402-1-git-send-email-miles.chen@mediatek.com>
References: <1541091607-27402-1-git-send-email-miles.chen@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miles.chen@mediatek.com
Cc: Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com, Michal Hocko <mhocko@kernel.org>

On Fri, 2 Nov 2018 01:00:07 +0800 <miles.chen@mediatek.com> wrote:

> From: Miles Chen <miles.chen@mediatek.com>
> 
> The page owner read might allocate a large size of memory with
> a large read count. Allocation fails can easily occur when doing
> high order allocations.
> 
> Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation
> and avoid allocation fails due to high order allocation.
> 
> ...
>
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -351,6 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  		.skip = 0
>  	};
>  
> +	count = count > PAGE_SIZE ? PAGE_SIZE : count;
>  	kbuf = kmalloc(count, GFP_KERNEL);
>  	if (!kbuf)
>  		return -ENOMEM;

A bit tidier:

--- a/mm/page_owner.c~mm-page_owner-clamp-read-count-to-page_size-fix
+++ a/mm/page_owner.c
@@ -351,7 +351,7 @@ print_page_owner(char __user *buf, size_
 		.skip = 0
 	};
 
-	count = count > PAGE_SIZE ? PAGE_SIZE : count;
+	count = min_t(size_t, count, PAGE_SIZE);
 	kbuf = kmalloc(count, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
