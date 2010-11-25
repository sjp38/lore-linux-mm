Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4CD2D8D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 14:43:46 -0500 (EST)
Date: Thu, 25 Nov 2010 20:36:59 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
Message-ID: <20101125193659.GA14510@redhat.com>
References: <20101124085022.7BDF.A69D9226@jp.fujitsu.com> <20101124110915.GA20452@redhat.com> <20101125092237.F43A.A69D9226@jp.fujitsu.com> <20101125140253.GA29371@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101125140253.GA29371@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 11/25, Oleg Nesterov wrote:
>
> Great! I'll send the patch tomorrow.
>
> Even if you prefer another fix for 2.6.37/stable, I'd like to see
> your review to know if it is correct or not (for backporting).

OK, what do you think about the patch below?

Seems to work, with this patch the test-case doesn't kill the
system (sysctl_oom_kill_allocating_task == 0).

I didn't dare to change !CONFIG_MMU case, I do not know how to
test it.

The patch is not complete, compat_copy_strings() needs changes.
But, shouldn't it use get_arg_page() too? Otherwise, where do
we check RLIMIT_STACK?

The patch asks for the cleanups. In particular, I think exec_mmap()
should accept bprm, not mm. But I'd prefer to do this later.

Oleg.

 include/linux/binfmts.h |    1 +
 fs/exec.c               |   28 ++++++++++++++++++++++++++--
 2 files changed, 27 insertions(+), 2 deletions(-)

--- K/include/linux/binfmts.h~acct_exec_mem	2010-08-19 11:35:00.000000000 +0200
+++ K/include/linux/binfmts.h	2010-11-25 20:19:33.000000000 +0100
@@ -33,6 +33,7 @@ struct linux_binprm{
 # define MAX_ARG_PAGES	32
 	struct page *page[MAX_ARG_PAGES];
 #endif
+	unsigned long vma_pages;
 	struct mm_struct *mm;
 	unsigned long p; /* current top of mem */
 	unsigned int
--- K/fs/exec.c~acct_exec_mem	2010-11-25 15:16:56.000000000 +0100
+++ K/fs/exec.c	2010-11-25 20:20:49.000000000 +0100
@@ -162,6 +162,25 @@ out:
   	return error;
 }
 
+static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
+{
+	struct mm_struct *mm = current->mm;
+	long diff = pages - bprm->vma_pages;
+
+	if (!mm || !diff)
+		return;
+
+	bprm->vma_pages += diff;
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
 #ifdef CONFIG_MMU
 
 static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
@@ -186,6 +205,8 @@ static struct page *get_arg_page(struct 
 		unsigned long size = bprm->vma->vm_end - bprm->vma->vm_start;
 		struct rlimit *rlim;
 
+		acct_arg_size(bprm, size / PAGE_SIZE);
+
 		/*
 		 * We've historically supported up to 32 pages (ARG_MAX)
 		 * of argument strings even with small stacks
@@ -1003,6 +1024,7 @@ int flush_old_exec(struct linux_binprm *
 	/*
 	 * Release all of the old mmap stuff
 	 */
+	acct_arg_size(bprm, 0);
 	retval = exec_mmap(bprm->mm);
 	if (retval)
 		goto out;
@@ -1426,8 +1448,10 @@ int do_execve(const char * filename,
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
