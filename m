Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B123E6B0037
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 08:32:59 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so10252019pab.5
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:32:58 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id rf4si8876098pdb.84.2014.07.28.05.32.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 05:32:58 -0700 (PDT)
Message-ID: <53D642E5.2010305@huawei.com>
Date: Mon, 28 Jul 2014 20:32:37 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] memory hotplug: update the variables after memory removed
References: <1406550617-19556-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1406550617-19556-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shaohui.zheng@intel.com, mgorman@suse.de, mingo@redhat.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: wangnan0@huawei.com, akpm@linux-foundation.org

Commit ea0854170c95245a258b386c7a9314399c949fe0 added a fuction
update_end_of_memory_vars() to update high_memory, max_pfn and
max_low_pfn.

Here modified the function(added an argument to show add or remove).
And call it in arch_remove_memory() to update these variables too.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 arch/x86/mm/init_64.c | 29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index df1a992..2557091 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -673,14 +673,24 @@ void __init paging_init(void)
  * After memory hotplug the variables max_pfn, max_low_pfn and high_memory need
  * updating.
  */
-static void  update_end_of_memory_vars(u64 start, u64 size)
+static void  update_end_of_memory_vars(u64 start, u64 size, bool flag)
 {
-	unsigned long end_pfn = PFN_UP(start + size);
-
-	if (end_pfn > max_pfn) {
-		max_pfn = end_pfn;
-		max_low_pfn = end_pfn;
-		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
+	unsigned long end_pfn;
+
+	if (flag) {
+		end_pfn = PFN_UP(start + size);
+		if (end_pfn > max_pfn) {
+			max_pfn = end_pfn;
+			max_low_pfn = end_pfn;
+			high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
+		}
+	} else {
+		end_pfn = PFN_UP(start);
+		if (end_pfn < max_pfn) {
+			max_pfn = end_pfn;
+			max_low_pfn = end_pfn;
+			high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
+		}
 	}
 }

@@ -702,7 +712,7 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	WARN_ON_ONCE(ret);

 	/* update max_pfn, max_low_pfn and high_memory */
-	update_end_of_memory_vars(start, size);
+	update_end_of_memory_vars(start, size, true);

 	return ret;
 }
@@ -1025,6 +1035,9 @@ int __ref arch_remove_memory(u64 start, u64 size)
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);

+	/* update max_pfn, max_low_pfn and high_memory */
+	update_end_of_memory_vars(start, size, false);
+
 	return ret;
 }
 #endif
-- 
1.8.1.2


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
