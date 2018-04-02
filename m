Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 134386B0023
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 22:35:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id h131so9827868qke.7
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 19:35:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s67si15220716qke.363.2018.04.01.19.35.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Apr 2018 19:35:15 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/migrate: properly preserve write attribute in special migrate entry
Date: Sun,  1 Apr 2018 22:35:06 -0400
Message-Id: <20180402023506.12180-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Ralph Campbell <rcampbell@nvidia.com>

Use of pte_write(pte) is only valid for present pte, the common code
which set the migration entry can be reach for both valid present
pte and special swap entry (for device memory). Fix the code to use
the mpfn value which properly handle both cases.

On x86 this did not have any bad side effect because pte write bit
is below PAGE_BIT_GLOBAL and thus special swap entry have it set to
0 which in turn means we were always creating read only special
migration entry.

So once migration did finish we always write protected the CPU page
table entry (moreover this is only an issue when migrating from device
memory to system memory). End effect is that CPU write access would
fault again and restore write permission.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/migrate.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 5d0dc7b85f90..a5c559d8e0e7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2269,7 +2269,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			ptep_get_and_clear(mm, addr, ptep);
 
 			/* Setup special migration page table entry */
-			entry = make_migration_entry(page, pte_write(pte));
+			entry = make_migration_entry(page, mpfn &
+						     MIGRATE_PFN_WRITE);
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pte))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
-- 
2.14.3
