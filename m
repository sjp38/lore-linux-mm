Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 826496B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 16:57:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d199so39277085wmd.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:57:41 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id az9si18243406wjb.294.2016.10.24.13.57.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 13:57:40 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] shmem: avoid maybe-uninitialized warning
Date: Mon, 24 Oct 2016 22:57:09 +0200
Message-Id: <20161024205725.786455-1-arnd@arndb.de>
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
warning and lets us remove two later initializations.

Note that the function is so hard to read that it not only confuses
the compiler, but also most readers and without this patch it could\
easily break if one of the 'goto's changed.

Link: https://www.spinics.net/lists/kernel/msg2368133.html
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/shmem.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index ad7813d73ea7..95c4bb690f98 100644
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
 
@@ -1835,7 +1834,6 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
 		put_page(page);
 	}
 	if (error == -ENOSPC && !once++) {
-		info = SHMEM_I(inode);
 		spin_lock_irq(&info->lock);
 		shmem_recalc_inode(inode);
 		spin_unlock_irq(&info->lock);
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
