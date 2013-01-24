Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 23D816B0002
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 18:05:27 -0500 (EST)
Received: by mail-ia0-f172.google.com with SMTP id u8so5698088iag.31
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 15:05:26 -0800 (PST)
Date: Thu, 24 Jan 2013 15:05:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] memory-hotplug: export the function try_offline_node()
 fix
In-Reply-To: <1358855156-6126-3-git-send-email-tangchen@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1301241501430.30690@chino.kir.corp.google.com>
References: <1358855156-6126-1-git-send-email-tangchen@cn.fujitsu.com> <1358855156-6126-3-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"memory-hotplug: export the function try_offline_node()" declares 
try_offline_node() for CONFIG_MEMORY_HOTPLUG, but this function is only 
defined for CONFIG_MEMORY_HOTREMOVE:

ERROR: "try_offline_node" [drivers/acpi/processor.ko] undefined!

Fix the build by definining it appropriately.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 extensively trimmed the cc list of the email to only the maintainers
 from scripts/get_maintainer.pl.

 include/linux/memory_hotplug.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -193,7 +193,6 @@ extern void get_page_bootmem(unsigned long ingo, struct page *page,
 
 void lock_memory_hotplug(void);
 void unlock_memory_hotplug(void);
-extern void try_offline_node(int nid);
 
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
@@ -228,13 +227,13 @@ static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
 
 static inline void lock_memory_hotplug(void) {}
 static inline void unlock_memory_hotplug(void) {}
-static inline void try_offline_node(int nid) {}
 
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 
 extern int is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
+extern void try_offline_node(int nid);
 
 #else
 static inline int is_mem_section_removable(unsigned long pfn,
@@ -242,6 +241,8 @@ static inline int is_mem_section_removable(unsigned long pfn,
 {
 	return 0;
 }
+
+static inline void try_offline_node(int nid) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern int mem_online_node(int nid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
