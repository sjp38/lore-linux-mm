Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56C6E6B087F
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:30:36 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so2675216edc.9
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:30:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4-v6sor7102259eja.14.2018.11.16.00.30.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 00:30:34 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/5] mm: print more information about mapping in __dump_page
Date: Fri, 16 Nov 2018 09:30:16 +0100
Message-Id: <20181116083020.20260-2-mhocko@kernel.org>
In-Reply-To: <20181116083020.20260-1-mhocko@kernel.org>
References: <20181116083020.20260-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
