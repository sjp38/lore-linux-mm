From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH] mm/device-public-memory: Enable move_pages() to stat device memory
Date: Fri, 22 Sep 2017 15:13:56 -0500
Message-ID: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

The move_pages() syscall can be used to find the numa node where a page
currently resides. This is not working for device public memory pages,
which erroneously report -EFAULT (unmapped or zero page).

Enable by adding a FOLL_DEVICE flag for follow_page(), which
move_pages() will use. This could be done unconditionally, but adding a
flag seems like a safer change.

Cc: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 include/linux/mm.h | 1 +
 mm/gup.c           | 2 +-
 mm/migrate.c       | 2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f8c10d3..783cb57 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2368,6 +2368,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_MLOCK	0x1000	/* lock present pages */
 #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
 #define FOLL_COW	0x4000	/* internal GUP flag */
+#define FOLL_DEVICE	0x8000	/* return device pages */
 
 static inline int vm_fault_to_errno(int vm_fault, int foll_flags)
 {
diff --git a/mm/gup.c b/mm/gup.c
index b2b4d42..6fbad70 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -110,7 +110,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		return NULL;
 	}
 
-	page = vm_normal_page(vma, address, pte);
+	page = _vm_normal_page(vma, address, pte, flags & FOLL_DEVICE);
 	if (!page && pte_devmap(pte) && (flags & FOLL_GET)) {
 		/*
 		 * Only return device mapping pages in the FOLL_GET case since
diff --git a/mm/migrate.c b/mm/migrate.c
index 6954c14..dea0ceb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1690,7 +1690,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 			goto set_status;
 
 		/* FOLL_DUMP to ignore special (like zero) pages */
-		page = follow_page(vma, addr, FOLL_DUMP);
+		page = follow_page(vma, addr, FOLL_DUMP | FOLL_DEVICE);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
-- 
1.8.3.1
