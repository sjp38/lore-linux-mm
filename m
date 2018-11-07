Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 549C06B04DF
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 05:18:46 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id t17-v6so12769713wmh.2
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 02:18:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b77-v6sor399933wme.9.2018.11.07.02.18.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 02:18:44 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/5] mm: print more information about mapping in __dump_page
Date: Wed,  7 Nov 2018 11:18:26 +0100
Message-Id: <20181107101830.17405-2-mhocko@kernel.org>
In-Reply-To: <20181107101830.17405-1-mhocko@kernel.org>
References: <20181107101830.17405-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__dump_page prints the mapping pointer but that is quite unhelpful
for many reports because the pointer itself only helps to distinguish
anon/ksm mappings from other ones (because of lowest bits
set). Sometimes it would be much more helpful to know what kind of
mapping that is actually and if we know this is a file mapping then also
try to resolve the dentry name.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/debug.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/debug.c b/mm/debug.c
index cdacba12e09a..a33177bfc856 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -44,6 +44,7 @@ const struct trace_print_flags vmaflag_names[] = {
 
 void __dump_page(struct page *page, const char *reason)
 {
+	struct address_space *mapping = page_mapping(page);
 	bool page_poisoned = PagePoisoned(page);
 	int mapcount;
 
@@ -70,6 +71,18 @@ void __dump_page(struct page *page, const char *reason)
 	if (PageCompound(page))
 		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
 	pr_cont("\n");
+	if (PageAnon(page))
+		pr_emerg("anon ");
+	else if (PageKsm(page))
+		pr_emerg("ksm ");
+	else if (mapping) {
+		pr_emerg("%ps ", mapping->a_ops);
+		if (mapping->host->i_dentry.first) {
+			struct dentry *dentry;
+			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
+			pr_emerg("name:\"%*s\" ", dentry->d_name.len, dentry->d_name.name);
+		}
+	}
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
 
 	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
-- 
2.19.1
