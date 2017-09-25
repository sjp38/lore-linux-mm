From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [RFC v1 2/2] VS1544 KSM s390-specific memory comparison functions
Date: Mon, 25 Sep 2017 10:46:14 +0200
Message-ID: <1506329174-19265-3-git-send-email-imbrenda@linux.vnet.ibm.com>
References: <1506329174-19265-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1506329174-19265-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: kvm-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: borntraeger@de.ibm.com, kvm@vger.kernel.org, linux-mm@kvack.org, nefelim4ag@gmail.com, akpm@linux-foundation.org, aarcange@redhat.com, mingo@kernel.org, zhongjiang@huawei.com, kirill.shutemov@linux.intel.com, arvind.yadav.cs@gmail.com, solee@os.korea.ac.kr, ak@linux.intel.com
List-Id: linux-mm.kvack.org

Introduce s390 specific page comparison and checksumming functions:

The s390-specific functions use the CKSM instruction to quickly
calculate the checksum of a page.

This provides a measurable reduction on CPU load when KSM is active.

Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
---
 arch/s390/include/asm/Kbuild        |  1 -
 arch/s390/include/asm/page_memops.h | 18 ++++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)
 create mode 100644 arch/s390/include/asm/page_memops.h

diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index e68b429..b3c8847 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -14,7 +14,6 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
-generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
diff --git a/arch/s390/include/asm/page_memops.h b/arch/s390/include/asm/page_memops.h
new file mode 100644
index 0000000..48b829b
--- /dev/null
+++ b/arch/s390/include/asm/page_memops.h
@@ -0,0 +1,18 @@
+#ifndef _ASM_S390_PAGE_MEMOPS_H
+#define _ASM_S390_PAGE_MEMOPS_H
+
+#include <linux/mm_types.h>
+#include <linux/highmem.h>
+#include <asm/checksum.h>
+
+static inline u32 calc_page_checksum(struct page *page)
+{
+	return csum_partial(page_address(page), PAGE_SIZE, 0);
+}
+
+static inline int memcmp_pages(struct page *page1, struct page *page2)
+{
+	return memcmp(page_address(page1), page_address(page2), PAGE_SIZE);
+}
+
+#endif
-- 
2.7.4
