Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7CED36B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:02:42 -0500 (EST)
Date: Tue, 30 Nov 2010 20:55:34 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/2] exec: make argv/envp memory visible to oom-killer
Message-ID: <20101130195534.GB11905@redhat.com>
References: <20101125140253.GA29371@redhat.com> <20101125193659.GA14510@redhat.com> <20101129093803.829F.A69D9226@jp.fujitsu.com> <20101129113357.GA30657@redhat.com> <20101129182332.GA21470@redhat.com> <20101130195456.GA11905@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101130195456.GA11905@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Brad Spengler published a local memory-allocation DoS that
evades the OOM-killer (though not the virtual memory RLIMIT):
http://www.grsecurity.net/~spender/64bit_dos.c

execve()->copy_strings() can allocate a lot of memory, but
this is not visible to oom-killer, nobody can see the nascent
bprm->mm and take it into account.

With this patch get_arg_page() increments current's MM_ANONPAGES
counter every time we allocate the new page for argv/envp. When
do_execve() succeds or fails, we change this counter back.

Technically this is not 100% correct, we can't know if the new
page is swapped out and turn MM_ANONPAGES into MM_SWAPENTS, but
I don't think this really matters and everything becomes correct
once exec changes ->mm or fails.

Reported-by: Brad Spengler <spender@grsecurity.net>
By-discussion-with: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 include/linux/binfmts.h |    1 +
 fs/exec.c               |   32 ++++++++++++++++++++++++++++++--
 2 files changed, 31 insertions(+), 2 deletions(-)

--- K/include/linux/binfmts.h~acct_exec_mem	2010-11-30 18:27:15.000000000 +0100
+++ K/include/linux/binfmts.h	2010-11-30 18:28:54.000000000 +0100
@@ -29,6 +29,7 @@ struct linux_binprm{
 	char buf[BINPRM_BUF_SIZE];
 #ifdef CONFIG_MMU
 	struct vm_area_struct *vma;
+	unsigned long vma_pages;
 #else
 # define MAX_ARG_PAGES	32
 	struct page *page[MAX_ARG_PAGES];
--- K/fs/exec.c~acct_exec_mem	2010-11-30 18:27:15.000000000 +0100
+++ K/fs/exec.c	2010-11-30 18:28:54.000000000 +0100
@@ -164,6 +164,25 @@ out:
 
 #ifdef CONFIG_MMU
 
+static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
+{
+	struct mm_struct *mm = current->mm;
+	long diff = (long)(pages - bprm->vma_pages);
+
+	if (!mm || !diff)
+		return;
+
+	bprm->vma_pages = pages;
+
+#ifdef SPLIT_RSS_COUNTING
+	add_mm_counter(mm, MM_ANONPAGES, diff);
+#else
+	spin_lock(&mm->page_table_lock);
+	add_mm_counter(mm, MM_ANONPAGES, diff);
+	spin_unlock(&mm->page_table_lock);
+#endif
+}
+
 static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		int write)
 {
@@ -186,6 +205,8 @@ static struct page *get_arg_page(struct 
 		unsigned long size = bprm->vma->vm_end - bprm->vma->vm_start;
 		struct rlimit *rlim;
 
+		acct_arg_size(bprm, size / PAGE_SIZE);
+
 		/*
 		 * We've historically supported up to 32 pages (ARG_MAX)
 		 * of argument strings even with small stacks
@@ -276,6 +297,10 @@ static bool valid_arg_len(struct linux_b
 
 #else
 
+static inline void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
+{
+}
+
 static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		int write)
 {
@@ -1003,6 +1028,7 @@ int flush_old_exec(struct linux_binprm *
 	/*
 	 * Release all of the old mmap stuff
 	 */
+	acct_arg_size(bprm, 0);
 	retval = exec_mmap(bprm->mm);
 	if (retval)
 		goto out;
@@ -1426,8 +1452,10 @@ int do_execve(const char * filename,
 	return retval;
 
 out:
-	if (bprm->mm)
-		mmput (bprm->mm);
+	if (bprm->mm) {
+		acct_arg_size(bprm, 0);
+		mmput(bprm->mm);
+	}
 
 out_file:
 	if (bprm->file) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
