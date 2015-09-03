Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 93D716B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:17:16 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so48188552pac.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:17:16 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id xc1si18603081pbc.23.2015.09.03.07.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:17:15 -0700 (PDT)
Received: by padfa1 with SMTP id fa1so5851502pad.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:17:15 -0700 (PDT)
From: Hajime Tazaki <thehajime@gmail.com>
Subject: [PATCH v6 01/10] sysctl: make some functions unstatic to access by arch/lib
Date: Thu,  3 Sep 2015 23:16:23 +0900
Message-Id: <1441289792-64064-2-git-send-email-thehajime@gmail.com>
In-Reply-To: <1441289792-64064-1-git-send-email-thehajime@gmail.com>
References: <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1441289792-64064-1-git-send-email-thehajime@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <thehajime@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

libos (arch/lib) emulates a sysctl-like interface by a function call of
userspace by enumerating sysctl tree from sysctl_table_root. It requires
to be publicly accessible to this symbol and related functions.

Signed-off-by: Hajime Tazaki <thehajime@gmail.com>
---
 fs/proc/proc_sysctl.c | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index fdda62e6115e..e1003cf51d22 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -57,7 +57,7 @@ static struct ctl_table root_table[] = {
 	},
 	{ }
 };
-static struct ctl_table_root sysctl_table_root = {
+struct ctl_table_root sysctl_table_root = {
 	.default_set.dir.header = {
 		{{.count = 1,
 		  .nreg = 1,
@@ -99,8 +99,9 @@ static int namecmp(const char *name1, int len1, const char *name2, int len2)
 }
 
 /* Called under sysctl_lock */
-static struct ctl_table *find_entry(struct ctl_table_header **phead,
-	struct ctl_dir *dir, const char *name, int namelen)
+struct ctl_table *ctl_table_find_entry(struct ctl_table_header **phead,
+				       struct ctl_dir *dir, const char *name,
+				       int namelen)
 {
 	struct ctl_table_header *head;
 	struct ctl_table *entry;
@@ -335,7 +336,7 @@ static struct ctl_table *lookup_entry(struct ctl_table_header **phead,
 	struct ctl_table *entry;
 
 	spin_lock(&sysctl_lock);
-	entry = find_entry(&head, dir, name, namelen);
+	entry = ctl_table_find_entry(&head, dir, name, namelen);
 	if (entry && use_table(head))
 		*phead = head;
 	else
@@ -356,7 +357,7 @@ static struct ctl_node *first_usable_entry(struct rb_node *node)
 	return NULL;
 }
 
-static void first_entry(struct ctl_dir *dir,
+void ctl_table_first_entry(struct ctl_dir *dir,
 	struct ctl_table_header **phead, struct ctl_table **pentry)
 {
 	struct ctl_table_header *head = NULL;
@@ -374,7 +375,7 @@ static void first_entry(struct ctl_dir *dir,
 	*pentry = entry;
 }
 
-static void next_entry(struct ctl_table_header **phead, struct ctl_table **pentry)
+void ctl_table_next_entry(struct ctl_table_header **phead, struct ctl_table **pentry)
 {
 	struct ctl_table_header *head = *phead;
 	struct ctl_table *entry = *pentry;
@@ -707,7 +708,8 @@ static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
 
 	pos = 2;
 
-	for (first_entry(ctl_dir, &h, &entry); h; next_entry(&h, &entry)) {
+	for (ctl_table_first_entry(ctl_dir, &h, &entry); h;
+	     ctl_table_next_entry(&h, &entry)) {
 		if (!scan(h, entry, &pos, file, ctx)) {
 			sysctl_head_finish(h);
 			break;
@@ -865,7 +867,7 @@ static struct ctl_dir *find_subdir(struct ctl_dir *dir,
 	struct ctl_table_header *head;
 	struct ctl_table *entry;
 
-	entry = find_entry(&head, dir, name, namelen);
+	entry = ctl_table_find_entry(&head, dir, name, namelen);
 	if (!entry)
 		return ERR_PTR(-ENOENT);
 	if (!S_ISDIR(entry->mode))
@@ -961,13 +963,13 @@ failed:
 	return subdir;
 }
 
-static struct ctl_dir *xlate_dir(struct ctl_table_set *set, struct ctl_dir *dir)
+struct ctl_dir *ctl_table_xlate_dir(struct ctl_table_set *set, struct ctl_dir *dir)
 {
 	struct ctl_dir *parent;
 	const char *procname;
 	if (!dir->header.parent)
 		return &set->dir;
-	parent = xlate_dir(set, dir->header.parent);
+	parent = ctl_table_xlate_dir(set, dir->header.parent);
 	if (IS_ERR(parent))
 		return parent;
 	procname = dir->header.ctl_table[0].procname;
@@ -988,13 +990,13 @@ static int sysctl_follow_link(struct ctl_table_header **phead,
 	spin_lock(&sysctl_lock);
 	root = (*pentry)->data;
 	set = lookup_header_set(root, namespaces);
-	dir = xlate_dir(set, (*phead)->parent);
+	dir = ctl_table_xlate_dir(set, (*phead)->parent);
 	if (IS_ERR(dir))
 		ret = PTR_ERR(dir);
 	else {
 		const char *procname = (*pentry)->procname;
 		head = NULL;
-		entry = find_entry(&head, dir, procname, strlen(procname));
+		entry = ctl_table_find_entry(&head, dir, procname, strlen(procname));
 		ret = -ENOENT;
 		if (entry && use_table(head)) {
 			unuse_table(*phead);
@@ -1106,7 +1108,7 @@ static bool get_links(struct ctl_dir *dir,
 	/* Are there links available for every entry in table? */
 	for (entry = table; entry->procname; entry++) {
 		const char *procname = entry->procname;
-		link = find_entry(&head, dir, procname, strlen(procname));
+		link = ctl_table_find_entry(&head, dir, procname, strlen(procname));
 		if (!link)
 			return false;
 		if (S_ISDIR(link->mode) && S_ISDIR(entry->mode))
@@ -1119,7 +1121,7 @@ static bool get_links(struct ctl_dir *dir,
 	/* The checks passed.  Increase the registration count on the links */
 	for (entry = table; entry->procname; entry++) {
 		const char *procname = entry->procname;
-		link = find_entry(&head, dir, procname, strlen(procname));
+		link = ctl_table_find_entry(&head, dir, procname, strlen(procname));
 		head->nreg++;
 	}
 	return true;
@@ -1135,7 +1137,7 @@ static int insert_links(struct ctl_table_header *head)
 	if (head->set == root_set)
 		return 0;
 
-	core_parent = xlate_dir(root_set, head->parent);
+	core_parent = ctl_table_xlate_dir(root_set, head->parent);
 	if (IS_ERR(core_parent))
 		return 0;
 
@@ -1516,7 +1518,7 @@ static void put_links(struct ctl_table_header *header)
 	if (header->set == root_set)
 		return;
 
-	core_parent = xlate_dir(root_set, parent);
+	core_parent = ctl_table_xlate_dir(root_set, parent);
 	if (IS_ERR(core_parent))
 		return;
 
@@ -1525,7 +1527,7 @@ static void put_links(struct ctl_table_header *header)
 		struct ctl_table *link;
 		const char *name = entry->procname;
 
-		link = find_entry(&link_head, core_parent, name, strlen(name));
+		link = ctl_table_find_entry(&link_head, core_parent, name, strlen(name));
 		if (link &&
 		    ((S_ISDIR(link->mode) && S_ISDIR(entry->mode)) ||
 		     (S_ISLNK(link->mode) && (link->data == root)))) {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
