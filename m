Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0E66B006C
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 09:12:05 -0400 (EDT)
Received: by pagv19 with SMTP id v19so50440162pag.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 06:12:05 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [203.178.142.130])
        by mx.google.com with ESMTPS id pw8si5642518pbc.60.2015.03.24.06.12.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 06:12:04 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [RFC PATCH 01/11] sysctl: make some functions unstatic to access by arch/lib
Date: Tue, 24 Mar 2015 22:10:32 +0900
Message-Id: <1427202642-1716-2-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Mathieu Lacage <mathieu.lacage@gmail.com>

libos (arch/lib) emulates a sysctl-like interface by a function call of
userspace by enumerating sysctl tree from sysctl_table_root. It requires
to be publicly accessible to this symbol and related functions.

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
---
 fs/proc/proc_sysctl.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index f92d5dd..e3de095 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -35,7 +35,7 @@ static struct ctl_table root_table[] = {
 	},
 	{ }
 };
-static struct ctl_table_root sysctl_table_root = {
+struct ctl_table_root sysctl_table_root = {
 	.default_set.dir.header = {
 		{{.count = 1,
 		  .nreg = 1,
@@ -61,7 +61,7 @@ static void sysctl_print_dir(struct ctl_dir *dir)
 	pr_cont("%s/", dir->header.ctl_table[0].procname);
 }
 
-static int namecmp(const char *name1, int len1, const char *name2, int len2)
+int namecmp(const char *name1, int len1, const char *name2, int len2)
 {
 	int minlen;
 	int cmp;
@@ -77,7 +77,7 @@ static int namecmp(const char *name1, int len1, const char *name2, int len2)
 }
 
 /* Called under sysctl_lock */
-static struct ctl_table *find_entry(struct ctl_table_header **phead,
+struct ctl_table *find_entry(struct ctl_table_header **phead,
 	struct ctl_dir *dir, const char *name, int namelen)
 {
 	struct ctl_table_header *head;
@@ -309,7 +309,7 @@ static struct ctl_table *lookup_entry(struct ctl_table_header **phead,
 	return entry;
 }
 
-static struct ctl_node *first_usable_entry(struct rb_node *node)
+struct ctl_node *first_usable_entry(struct rb_node *node)
 {
 	struct ctl_node *ctl_node;
 
@@ -321,7 +321,7 @@ static struct ctl_node *first_usable_entry(struct rb_node *node)
 	return NULL;
 }
 
-static void first_entry(struct ctl_dir *dir,
+void first_entry(struct ctl_dir *dir,
 	struct ctl_table_header **phead, struct ctl_table **pentry)
 {
 	struct ctl_table_header *head = NULL;
@@ -339,7 +339,7 @@ static void first_entry(struct ctl_dir *dir,
 	*pentry = entry;
 }
 
-static void next_entry(struct ctl_table_header **phead, struct ctl_table **pentry)
+void next_entry(struct ctl_table_header **phead, struct ctl_table **pentry)
 {
 	struct ctl_table_header *head = *phead;
 	struct ctl_table *entry = *pentry;
@@ -822,7 +822,7 @@ static const struct dentry_operations proc_sys_dentry_operations = {
 	.d_compare	= proc_sys_compare,
 };
 
-static struct ctl_dir *find_subdir(struct ctl_dir *dir,
+struct ctl_dir *find_subdir(struct ctl_dir *dir,
 				   const char *name, int namelen)
 {
 	struct ctl_table_header *head;
@@ -924,7 +924,7 @@ failed:
 	return subdir;
 }
 
-static struct ctl_dir *xlate_dir(struct ctl_table_set *set, struct ctl_dir *dir)
+struct ctl_dir *xlate_dir(struct ctl_table_set *set, struct ctl_dir *dir)
 {
 	struct ctl_dir *parent;
 	const char *procname;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
