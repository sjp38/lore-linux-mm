Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1916B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 20:31:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so301488636pfe.3
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 17:31:36 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id 25si1653285pfh.120.2016.04.17.17.31.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 17:31:35 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hb4so14714310pac.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 17:31:35 -0700 (PDT)
Date: Mon, 18 Apr 2016 09:33:05 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 10/16] zsmalloc: factor page chain functionality out
Message-ID: <20160418003305.GA5882@swordfish>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-11-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459321935-3655-11-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hello,

On (03/30/16 16:12), Minchan Kim wrote:
> @@ -1421,7 +1434,6 @@ static unsigned long obj_malloc(struct size_class *class,
>  	unsigned long m_offset;
>  	void *vaddr;
>  
> -	handle |= OBJ_ALLOCATED_TAG;

a nitpick, why did you replace this ALLOCATED_TAG assignment
with 2 'handle | OBJ_ALLOCATED_TAG'?

	-ss

>  	obj = get_freeobj(first_page);
>  	objidx_to_page_and_offset(class, first_page, obj,
>  				&m_page, &m_offset);
> @@ -1431,10 +1443,10 @@ static unsigned long obj_malloc(struct size_class *class,
>  	set_freeobj(first_page, link->next >> OBJ_ALLOCATED_TAG);
>  	if (!class->huge)
>  		/* record handle in the header of allocated chunk */
> -		link->handle = handle;
> +		link->handle = handle | OBJ_ALLOCATED_TAG;
>  	else
>  		/* record handle in first_page->private */
> -		set_page_private(first_page, handle);
> +		set_page_private(first_page, handle | OBJ_ALLOCATED_TAG);
>  	kunmap_atomic(vaddr);
>  	mod_zspage_inuse(first_page, 1);
>  	zs_stat_inc(class, OBJ_USED, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
