Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D14D36B0007
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:02 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q15so12351995qkj.3
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:02 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n4si5550973qkb.276.2018.04.04.12.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:01 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 05/79] mm/swap: add an helper to get address_space from swap_entry_t
Date: Wed,  4 Apr 2018 15:17:52 -0400
Message-Id: <20180404191831.5378-3-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Each swap entry is associated to a file and thus an address_space.
That address_space is use for reading/writing to swap storage. This
patch add an helper to get the address_space from swap_entry_t.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/swap.h | 1 +
 mm/swapfile.c        | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index a1a3f4ed94ce..e2155df84d77 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -475,6 +475,7 @@ extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
 extern struct swap_info_struct *swp_swap_info(swp_entry_t entry);
+struct address_space *swap_entry_to_address_space(swp_entry_t swap);
 extern bool reuse_swap_page(struct page *, int *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index c7a33717d079..a913d4b45866 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3467,6 +3467,13 @@ struct swap_info_struct *swp_swap_info(swp_entry_t entry)
 	return swap_info[swp_type(entry)];
 }
 
+struct address_space *swap_entry_to_address_space(swp_entry_t swap)
+{
+	struct swap_info_struct *sis = swp_swap_info(swap);
+
+	return sis->swap_file->f_mapping;
+}
+
 struct swap_info_struct *page_swap_info(struct page *page)
 {
 	swp_entry_t entry = { .val = page_private(page) };
-- 
2.14.3
