Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E62B6B0271
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:40 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id b76-v6so7749931ywb.11
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:40 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r7-v6si25689731ywd.74.2018.11.05.08.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:39 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 10/13] mm: enlarge type of offset argument in mem_map_offset and mem_map_next
Date: Mon,  5 Nov 2018 11:55:55 -0500
Message-Id: <20181105165558.11698-11-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Changes the type of 'offset' from int to unsigned long in both
mem_map_offset and mem_map_next.

This facilitates ktask's use of mem_map_next with its unsigned long
types to avoid silent truncation when these unsigned longs are passed as
ints.

It also fixes the preexisting truncation of 'offset' from unsigned long
to int by the sole caller of mem_map_offset, follow_hugetlb_page.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/internal.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 3b1ec1412fd2..cc90de4d4e01 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -367,7 +367,8 @@ static inline void mlock_migrate_page(struct page *new, struct page *old) { }
  * the maximally aligned gigantic page 'base'.  Handle any discontiguity
  * in the mem_map at MAX_ORDER_NR_PAGES boundaries.
  */
-static inline struct page *mem_map_offset(struct page *base, int offset)
+static inline struct page *mem_map_offset(struct page *base,
+					  unsigned long offset)
 {
 	if (unlikely(offset >= MAX_ORDER_NR_PAGES))
 		return nth_page(base, offset);
@@ -378,8 +379,8 @@ static inline struct page *mem_map_offset(struct page *base, int offset)
  * Iterator over all subpages within the maximally aligned gigantic
  * page 'base'.  Handle any discontiguity in the mem_map.
  */
-static inline struct page *mem_map_next(struct page *iter,
-						struct page *base, int offset)
+static inline struct page *mem_map_next(struct page *iter, struct page *base,
+					unsigned long offset)
 {
 	if (unlikely((offset & (MAX_ORDER_NR_PAGES - 1)) == 0)) {
 		unsigned long pfn = page_to_pfn(base) + offset;
-- 
2.19.1
