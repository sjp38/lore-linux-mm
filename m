Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DF1BF6B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:41:11 -0500 (EST)
Date: Tue, 23 Nov 2010 15:34:27 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
Message-ID: <20101123143427.GA30941@redhat.com>
References: <20101025122538.9167.A69D9226@jp.fujitsu.com> <20101025122914.9173.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025122914.9173.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 10/25, KOSAKI Motohiro wrote:
>
> Because execve() makes new mm struct and setup stack and
> copy argv. It mean the task have two mm while execve() temporary.
> Unfortunately this nascent mm is not pointed any tasks, then
> OOM-killer can't detect this memory usage. therefore OOM-killer
> may kill incorrect task.
>
> Thus, this patch added signal->in_exec_mm member and track
> nascent mm usage.

Stupid question.

Can't we just account these allocations in the old -mm temporary?

IOW. Please look at the "patch" below. It is of course incomplete
and wrong (to the point inc_mm_counter() is not safe without
SPLIT_RSS_COUNTING), and copy_strings/flush_old_exec are not the
best places to play with mm-counters, just to explain what I mean.

It is very simple. copy_strings() increments MM_ANONPAGES every
time we add a new page into bprm->vma. This makes this memory
visible to select_bad_process().

When exec changes ->mm (or if it fails), we change MM_ANONPAGES
counter back.

Most probably I missed something, but what do you think?

Oleg.

--- x/include/linux/binfmts.h
+++ x/include/linux/binfmts.h
@@ -29,6 +29,7 @@ struct linux_binprm{
 	char buf[BINPRM_BUF_SIZE];
 #ifdef CONFIG_MMU
 	struct vm_area_struct *vma;
+	unsigned long mm_anonpages;
 #else
 # define MAX_ARG_PAGES	32
 	struct page *page[MAX_ARG_PAGES];
--- x/fs/exec.c
+++ x/fs/exec.c
@@ -457,6 +457,9 @@ static int copy_strings(int argc, const 
 					goto out;
 				}
 
+				bmrp->mm_anonpages--;
+				inc_mm_counter(current->mm, MM_ANONPAGES);
+
 				if (kmapped_page) {
 					flush_kernel_dcache_page(kmapped_page);
 					kunmap(kmapped_page);
@@ -1003,6 +1006,7 @@ int flush_old_exec(struct linux_binprm *
 	/*
 	 * Release all of the old mmap stuff
 	 */
+	add_mm_counter(current->mm, bprm->mm_anonpages);
 	retval = exec_mmap(bprm->mm);
 	if (retval)
 		goto out;
@@ -1426,8 +1430,10 @@ int do_execve(const char * filename,
 	return retval;
 
 out:
-	if (bprm->mm)
-		mmput (bprm->mm);
+	if (bprm->mm) {
+		add_mm_counter(current->mm, bprm->mm_anonpages);
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
