From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH RESEND v10 09/10] mm: Allow arch code to override copy_highpage()
Date: Thu, 16 Nov 2017 07:38:32 -0700
Message-ID: <6bf7a449fb35d9235b539bb452df23c453b23401.1510768775.git.khalid.aziz__28649.0244012841$1510843182$gmane$org@oracle.com>
References: <cover.1510768775.git.khalid.aziz@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <cover.1510768775.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1510768775.git.khalid.aziz@oracle.com>
References: <cover.1510768775.git.khalid.aziz@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
To: akpm@linux-foundation.org, davem@davemloft.net
Cc: Khalid Aziz <khalid.aziz@oracle.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>
List-Id: linux-mm.kvack.org

Some architectures can support metadata for memory pages and when a
page is copied, its metadata must also be copied. Sparc processors
from M7 onwards support metadata for memory pages. This metadata
provides tag based protection for access to memory pages. To maintain
this protection, the tag data must be copied to the new page when a
page is migrated across NUMA nodes. This patch allows arch specific
code to override default copy_highpage() and copy metadata along
with page data upon migration.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
v9:
	- new patch

 include/linux/highmem.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 776f90f3a1cd..0690679832d4 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -237,6 +237,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
 
 #endif
 
+#ifndef __HAVE_ARCH_COPY_HIGHPAGE
+
 static inline void copy_highpage(struct page *to, struct page *from)
 {
 	char *vfrom, *vto;
@@ -248,4 +250,6 @@ static inline void copy_highpage(struct page *to, struct page *from)
 	kunmap_atomic(vfrom);
 }
 
+#endif
+
 #endif /* _LINUX_HIGHMEM_H */
-- 
2.11.0

