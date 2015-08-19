Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 595546B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 19:50:32 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so5131865pac.2
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 16:50:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ad1si4123366pbc.245.2015.08.19.16.50.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 16:50:31 -0700 (PDT)
Date: Wed, 19 Aug 2015 16:50:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Memory hot added,The memory can not been added to
 movable zone
Message-Id: <20150819165029.665b89d7ab3228185460172c@linux-foundation.org>
In-Reply-To: <1439972306-50845-1-git-send-email-liuchangsheng@inspur.com>
References: <1439972306-50845-1-git-send-email-liuchangsheng@inspur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>
Cc: isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

On Wed, 19 Aug 2015 04:18:26 -0400 Changsheng Liu <liuchangsheng@inspur.com> wrote:

> From: Changsheng Liu <liuchangcheng@inspur.com>
> 
> When memory hot added, the function should_add_memory_movable
> always return 0,because the movable zone is empty,
> so the memory that hot added will add to normal zone even if
> we want to remove the memory.
> So we change the function should_add_memory_movable,if the user
> config CONFIG_MOVABLE_NODE it will return 1 when
> movable zone is empty

I cleaned this up a bit:

: Subject: mm: memory hot-add: memory can not been added to movable zone
: 
: When memory is hot added, should_add_memory_movable() always returns 0
: because the movable zone is empty, so the memory that was hot added will
: add to the normal zone even if we want to remove the memory.
: 
: So we change should_add_memory_movable(): if the user config
: CONFIG_MOVABLE_NODE it will return 1 when the movable zone is empty.

But I don't understand the "even if we want to remove the memory". 
This is hot-add, not hot-remove.  What do you mean here?

> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1198,9 +1198,13 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>  
> -	if (zone_is_empty(movable_zone))
> +	if (zone_is_empty(movable_zone)) {
> +	#ifdef CONFIG_MOVABLE_NODE
> +		return 1;
> +	#else
>  		return 0;
> -
> +	#endif
> +	}
>  	if (movable_zone->zone_start_pfn <= start_pfn)
>  		return 1;

Cleaner:

--- a/mm/memory_hotplug.c~memory-hot-addedthe-memory-can-not-been-added-to-movable-zone-fix
+++ a/mm/memory_hotplug.c
@@ -1181,13 +1181,9 @@ static int should_add_memory_movable(int
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
 
-	if (zone_is_empty(movable_zone)) {
-	#ifdef CONFIG_MOVABLE_NODE
-		return 1;
-	#else
-		return 0;
-	#endif
-	}
+	if (zone_is_empty(movable_zone))
+		return IS_ENABLED(CONFIG_MOVABLE_NODE);
+
 	if (movable_zone->zone_start_pfn <= start_pfn)
 		return 1;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
