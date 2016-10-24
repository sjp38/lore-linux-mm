Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48B1E6B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:25:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d199so34718960wmd.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:25:24 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id az9si16582527wjb.294.2016.10.24.08.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 08:25:22 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] shmem: avoid maybe-uninitialized warning
Date: Mon, 24 Oct 2016 17:25:03 +0200
Message-Id: <20161024152511.2597880-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andreas Gruenbacher <agruenba@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

After enabling -Wmaybe-uninitialized warnings, we get a false-postive
warning for shmem:

mm/shmem.c: In function a??shmem_getpage_gfpa??:
include/linux/spinlock.h:332:21: error: a??infoa?? may be used uninitialized in this function [-Werror=maybe-uninitialized]

This can be easily avoided, since the correct 'info' pointer is known
at the time we first enter the function, so we can simply move the
initialization up. Moving it before the first label avoids the
warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/shmem.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index ad7813d73ea7..69e6777096a3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1537,7 +1537,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct mm_struct *fault_mm, int *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
-	struct shmem_inode_info *info;
+	struct shmem_inode_info *info = SHMEM_I(inode);
 	struct shmem_sb_info *sbinfo;
 	struct mm_struct *charge_mm;
 	struct mem_cgroup *memcg;
@@ -1587,7 +1587,6 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	 * Fast cache lookup did not find it:
 	 * bring it back from swap or allocate.
 	 */
-	info = SHMEM_I(inode);
 	sbinfo = SHMEM_SB(inode->i_sb);
 	charge_mm = fault_mm ? : current->mm;
 
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
