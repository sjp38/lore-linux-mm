Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9DF9A6B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 05:04:23 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id ro2so7825016pbb.39
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 02:04:22 -0800 (PST)
Date: Wed, 2 Jan 2013 02:04:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/2] mempolicy: remove arg from mpol_parse_str, mpol_to_str
In-Reply-To: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1301020201510.18049@eggly.anvils>
References: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Remove the unused argument (formerly no_context) from mpol_parse_str()
and from mpol_to_str().

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 fs/proc/task_mmu.c        |    2 +-
 include/linux/mempolicy.h |   11 ++++-------
 mm/mempolicy.c            |    6 ++----
 mm/shmem.c                |    4 ++--
 4 files changed, 9 insertions(+), 14 deletions(-)

--- 3.8-rc1+/fs/proc/task_mmu.c	2012-12-22 09:43:26.916015565 -0800
+++ linux/fs/proc/task_mmu.c	2013-01-01 23:26:30.174992261 -0800
@@ -1278,7 +1278,7 @@ static int show_numa_map(struct seq_file
 	walk.mm = mm;
 
 	pol = get_vma_policy(task, vma, vma->vm_start);
-	mpol_to_str(buffer, sizeof(buffer), pol, 0);
+	mpol_to_str(buffer, sizeof(buffer), pol);
 	mpol_cond_put(pol);
 
 	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
--- 3.8-rc1+/include/linux/mempolicy.h	2012-12-22 09:43:27.172015571 -0800
+++ linux/include/linux/mempolicy.h	2013-01-01 23:26:30.174992261 -0800
@@ -165,11 +165,10 @@ int do_migrate_pages(struct mm_struct *m
 
 
 #ifdef CONFIG_TMPFS
-extern int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context);
+extern int mpol_parse_str(char *str, struct mempolicy **mpol);
 #endif
 
-extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
-			int no_context);
+extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
 
 /* Check if a vma is migratable */
 static inline int vma_migratable(struct vm_area_struct *vma)
@@ -296,15 +295,13 @@ static inline void check_highest_zone(in
 }
 
 #ifdef CONFIG_TMPFS
-static inline int mpol_parse_str(char *str, struct mempolicy **mpol,
-				int no_context)
+static inline int mpol_parse_str(char *str, struct mempolicy **mpol)
 {
 	return 1;	/* error */
 }
 #endif
 
-static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
-				int no_context)
+static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 {
 	return 0;
 }
--- 3.8-rc1+/mm/mempolicy.c	2013-01-01 23:44:10.715017466 -0800
+++ linux/mm/mempolicy.c	2013-01-01 23:47:34.223022303 -0800
@@ -2612,14 +2612,13 @@ static const char * const policy_modes[]
  * mpol_parse_str - parse string to mempolicy, for tmpfs mpol mount option.
  * @str:  string containing mempolicy to parse
  * @mpol:  pointer to struct mempolicy pointer, returned on success.
- * @unused:  redundant argument, to be removed later.
  *
  * Format of input:
  *	<mode>[=<flags>][:<nodelist>]
  *
  * On success, returns 0, else 1
  */
-int mpol_parse_str(char *str, struct mempolicy **mpol, int unused)
+int mpol_parse_str(char *str, struct mempolicy **mpol)
 {
 	struct mempolicy *new = NULL;
 	unsigned short mode;
@@ -2747,13 +2746,12 @@ out:
  * @buffer:  to contain formatted mempolicy string
  * @maxlen:  length of @buffer
  * @pol:  pointer to mempolicy to be formatted
- * @unused:  redundant argument, to be removed later.
  *
  * Convert a mempolicy into a string.
  * Returns the number of characters in buffer (if positive)
  * or an error (negative)
  */
-int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int unused)
+int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 {
 	char *p = buffer;
 	int l;
--- 3.8-rc1+/mm/shmem.c	2012-12-22 09:43:27.660015583 -0800
+++ linux/mm/shmem.c	2013-01-01 23:26:30.174992261 -0800
@@ -889,7 +889,7 @@ static void shmem_show_mpol(struct seq_f
 	if (!mpol || mpol->mode == MPOL_DEFAULT)
 		return;		/* show nothing */
 
-	mpol_to_str(buffer, sizeof(buffer), mpol, 1);
+	mpol_to_str(buffer, sizeof(buffer), mpol);
 
 	seq_printf(seq, ",mpol=%s", buffer);
 }
@@ -2463,7 +2463,7 @@ static int shmem_parse_options(char *opt
 			if (!gid_valid(sbinfo->gid))
 				goto bad_val;
 		} else if (!strcmp(this_char,"mpol")) {
-			if (mpol_parse_str(value, &sbinfo->mpol, 1))
+			if (mpol_parse_str(value, &sbinfo->mpol))
 				goto bad_val;
 		} else {
 			printk(KERN_ERR "tmpfs: Bad mount option %s\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
