Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2AA36B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 14:11:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so161626256pfb.6
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:11:27 -0800 (PST)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id c21si4883626pfd.231.2017.02.07.11.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 11:11:27 -0800 (PST)
Received: by mail-pg0-x229.google.com with SMTP id v184so41035197pgv.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:11:27 -0800 (PST)
Date: Tue, 7 Feb 2017 11:11:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix KPF_SWAPCACHE
Message-ID: <alpine.LSU.2.11.1702071105360.11828@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nicholas Piggin <npiggin@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

4.10-rc1 commit 6326fec1122c ("mm: Use owner_priv bit for PageSwapCache,
valid when PageSwapBacked") aliased PG_swapcache to PG_owner_priv_1:
so /proc/kpageflags' KPF_SWAPCACHE should now be synthesized, instead
of being shown on unrelated pages which have PG_owner_priv_1 set.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 fs/proc/page.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- 4.10-rc7/fs/proc/page.c	2016-12-25 18:40:50.618454962 -0800
+++ linux/fs/proc/page.c	2017-02-07 10:28:51.019640392 -0800
@@ -173,7 +173,8 @@ u64 stable_page_flags(struct page *page)
 	u |= kpf_copy_bit(k, KPF_ACTIVE,	PG_active);
 	u |= kpf_copy_bit(k, KPF_RECLAIM,	PG_reclaim);
 
-	u |= kpf_copy_bit(k, KPF_SWAPCACHE,	PG_swapcache);
+	if (PageSwapCache(page))
+		u |= 1 << KPF_SWAPCACHE;
 	u |= kpf_copy_bit(k, KPF_SWAPBACKED,	PG_swapbacked);
 
 	u |= kpf_copy_bit(k, KPF_UNEVICTABLE,	PG_unevictable);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
