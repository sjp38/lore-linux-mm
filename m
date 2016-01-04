Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9006B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 10:01:11 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id b14so188602029wmb.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 07:01:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b8si145748895wjx.62.2016.01.04.07.01.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 07:01:08 -0800 (PST)
Subject: Re: [PATCH] mm/vmstat: fix overflow in mod_zone_page_state()
References: <1451390874-29639-1-git-send-email-heiko.carstens@de.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568A8932.2020801@suse.cz>
Date: Mon, 4 Jan 2016 16:01:06 +0100
MIME-Version: 1.0
In-Reply-To: <1451390874-29639-1-git-send-email-heiko.carstens@de.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/29/2015 01:07 PM, Heiko Carstens wrote:
> mod_zone_page_state() takes a "delta" integer argument. delta contains
> the number of pages that should be added or subtracted from a struct
> zone's vm_stat field.
>
> If a zone is larger than 8TB this will cause overflows. E.g. for a
> zone with a size slightly larger than 8TB the line
>
> 	mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
>
> in mm/page_alloc.c:free_area_init_core() will result in a negative
> result for the NR_ALLOC_BATCH entry within the zone's vm_stat, since
> 8TB contain 0x8xxxxxxx pages which will be sign extended to a negative
> value.
>
> Fix this by changing the delta argument to long type.
>
> This could fix an early boot problem seen on s390, where we have a 9TB
> system with only one node. ZONE_DMA contains 2GB and ZONE_NORMAL the
> rest. The system is trying to allocate a GFP_DMA page but ZONE_DMA is
> completely empty, so it tries to reclaim pages in an endless loop.
>
> This was seen on a heavily patched 3.10 kernel. One possible
> explaination seem to be the overflows caused by mod_zone_page_state().
> Unfortunately I did not have the chance to verify that this patch
> actually fixes the problem, since I don't have access to the system
> right now. However the overflow problem does exist anyway.
>
> Given the description that a system with slightly less than 8TB does
> work, this seems to be a candidate for the observed problem.
>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
