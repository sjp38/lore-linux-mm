Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2F246B744F
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:29:59 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so20586561qtd.20
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:29:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i21si11088199qtp.305.2018.12.05.04.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 04:29:58 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 1/7] agp: efficeon: no need to set PG_reserved on GATT tables
Date: Wed,  5 Dec 2018 13:28:45 +0100
Message-Id: <20181205122851.5891-2-david@redhat.com>
In-Reply-To: <20181205122851.5891-1-david@redhat.com>
References: <20181205122851.5891-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, David Hildenbrand <david@redhat.com>, David Airlie <airlied@linux.ie>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>

The l1 GATT page table is kept in a special on-chip page with 64 entries.
We allocate the l2 page table pages via get_zeroed_page() and enter them
into the table. These l2 pages are modified accordingly when
inserting/removing memory via efficeon_insert_memory and
efficeon_remove_memory.

Apart from that, these pages are not exposed or ioremap'ed. We can stop
setting them reserved (propably copied from generic code).

Cc: David Airlie <airlied@linux.ie>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/char/agp/efficeon-agp.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/char/agp/efficeon-agp.c b/drivers/char/agp/efficeon-agp.c
index 7f88490b5479..c53f0f9ef5b0 100644
--- a/drivers/char/agp/efficeon-agp.c
+++ b/drivers/char/agp/efficeon-agp.c
@@ -163,7 +163,6 @@ static int efficeon_free_gatt_table(struct agp_bridge_data *bridge)
 		unsigned long page = efficeon_private.l1_table[index];
 		if (page) {
 			efficeon_private.l1_table[index] = 0;
-			ClearPageReserved(virt_to_page((char *)page));
 			free_page(page);
 			freed++;
 		}
@@ -219,7 +218,6 @@ static int efficeon_create_gatt_table(struct agp_bridge_data *bridge)
 			efficeon_free_gatt_table(agp_bridge);
 			return -ENOMEM;
 		}
-		SetPageReserved(virt_to_page((char *)page));
 
 		for (offset = 0; offset < PAGE_SIZE; offset += clflush_chunk)
 			clflush((char *)page+offset);
-- 
2.17.2
