Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Li RongQing <lirongqing@baidu.com>
Subject: [PATCH] mm: introduce kvvirt_to_page() helper
Date: Thu, 16 Aug 2018 17:17:37 +0800
Message-Id: <1534411057-26276-1-git-send-email-lirongqing@baidu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Souptick Joarder <jrdr.linux@gmail.com>
List-ID: <linux-mm.kvack.org>

The new helper returns address mapping page, which has several users
in individual subsystem, like mem_to_page in xfs_buf.c and pgv_to_page
in af_packet.c, after this, they can be unified

Signed-off-by: Zhang Yu <zhangyu31@baidu.com>
Signed-off-by: Li RongQing <lirongqing@baidu.com>
---
 include/linux/mm.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 68a5121694ef..bb34a3c71df5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -599,6 +599,14 @@ static inline void *kvcalloc(size_t n, size_t size, gfp_t flags)
 	return kvmalloc_array(n, size, flags | __GFP_ZERO);
 }
 
+static inline struct page *kvvirt_to_page(const void *addr)
+{
+	if (!is_vmalloc_addr(addr))
+		return virt_to_page(addr);
+	else
+		return vmalloc_to_page(addr);
+}
+
 extern void kvfree(const void *addr);
 
 static inline atomic_t *compound_mapcount_ptr(struct page *page)
-- 
2.16.2
