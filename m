Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] mm/memory.c: Mark wp_huge_pmd() inline to prevent build failure
Date: Sun,  3 Dec 2017 22:11:40 +0100
Message-Id: <1512335500-10889-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

With gcc 4.1.2:

    mm/memory.o: In function `wp_huge_pmd':
    memory.c:(.text+0x9b4): undefined reference to `do_huge_pmd_wp_page'

Interestingly, wp_huge_pmd() is emitted in the assembler output, but
never called.

Apparently replacing the call to pmd_write() in __handle_mm_fault() by a
call to the more complex pmd_access_permitted() reduced the ability of
the compiler to remove unused code.

Fix this by marking wp_huge_pmd() inline, like was done in commit
91a90140f9987101 ("mm/memory.c: mark create_huge_pmd() inline to prevent
build failure") for a similar problem.

Fixes: c7da82b894e9eef6 ("mm: replace pmd_write with pmd_access_permitted in fault + gup paths")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5eb3d2524bdc2823..f4d52847ca07a414 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3831,7 +3831,7 @@ static inline int create_huge_pmd(struct vm_fault *vmf)
 	return VM_FAULT_FALLBACK;
 }
 
-static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
+static inline int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
-- 
2.7.4
