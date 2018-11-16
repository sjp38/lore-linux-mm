Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 775E36B0880
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:30:37 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id n32-v6so11288091edc.17
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:30:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10-v6sor15273680edd.23.2018.11.16.00.30.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 00:30:35 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/5] mm: lower the printk loglevel for __dump_page messages
Date: Fri, 16 Nov 2018 09:30:17 +0100
Message-Id: <20181116083020.20260-3-mhocko@kernel.org>
In-Reply-To: <20181116083020.20260-1-mhocko@kernel.org>
References: <20181116083020.20260-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__dump_page messages use KERN_EMERG resp. KERN_ALERT loglevel (this is
the case since 2004). Most callers of this function are really detecting
a critical page state and BUG right after. On the other hand the
function is called also from contexts which just want to inform about
the page state and those would rather not disrupt logs that much (e.g.
some systems route these messages to the normal console).

Reduce the loglevel to KERN_WARNING to make dump_page easier to reuse
for other contexts while those messages will still make it to the kernel
log in most setups. Even if the loglevel setup filters warnings away
those paths that are really critical already print the more targeted
error or panic and that should make it to the kernel log.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/debug.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index a33177bfc856..d18c5cea3320 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -54,7 +54,7 @@ void __dump_page(struct page *page, const char *reason)
 	 * dump_page() when detected.
 	 */
 	if (page_poisoned) {
-		pr_emerg("page:%px is uninitialized and poisoned", page);
+		pr_warn("page:%px is uninitialized and poisoned", page);
 		goto hex_only;
 	}
 
@@ -65,27 +65,27 @@ void __dump_page(struct page *page, const char *reason)
 	 */
 	mapcount = PageSlab(page) ? 0 : page_mapcount(page);
 
-	pr_emerg("page:%px count:%d mapcount:%d mapping:%px index:%#lx",
+	pr_warn("page:%px count:%d mapcount:%d mapping:%px index:%#lx",
 		  page, page_ref_count(page), mapcount,
 		  page->mapping, page_to_pgoff(page));
 	if (PageCompound(page))
 		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
 	pr_cont("\n");
 	if (PageAnon(page))
-		pr_emerg("anon ");
+		pr_warn("anon ");
 	else if (PageKsm(page))
-		pr_emerg("ksm ");
+		pr_warn("ksm ");
 	else if (mapping) {
-		pr_emerg("%ps ", mapping->a_ops);
+		pr_warn("%ps ", mapping->a_ops);
 		if (mapping->host->i_dentry.first) {
 			struct dentry *dentry;
 			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
-			pr_emerg("name:\"%*s\" ", dentry->d_name.len, dentry->d_name.name);
+			pr_warn("name:\"%*s\" ", dentry->d_name.len, dentry->d_name.name);
 		}
 	}
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
 
-	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
+	pr_warn("flags: %#lx(%pGp)\n", page->flags, &page->flags);
 
 hex_only:
 	print_hex_dump(KERN_ALERT, "raw: ", DUMP_PREFIX_NONE, 32,
@@ -93,11 +93,11 @@ void __dump_page(struct page *page, const char *reason)
 			sizeof(struct page), false);
 
 	if (reason)
-		pr_alert("page dumped because: %s\n", reason);
+		pr_warn("page dumped because: %s\n", reason);
 
 #ifdef CONFIG_MEMCG
 	if (!page_poisoned && page->mem_cgroup)
-		pr_alert("page->mem_cgroup:%px\n", page->mem_cgroup);
+		pr_warn("page->mem_cgroup:%px\n", page->mem_cgroup);
 #endif
 }
 
-- 
2.19.1
