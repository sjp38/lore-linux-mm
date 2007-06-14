Subject: Re: [patch 0/3] no MAX_ARG_PAGES -v2
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <65dd6fd50706132323i9c760f4m6e23687914d0c46e@mail.gmail.com>
References: <20070613100334.635756997@chello.nl>
	 <617E1C2C70743745A92448908E030B2A01AF860A@scsmsx411.amr.corp.intel.com>
	 <65dd6fd50706132323i9c760f4m6e23687914d0c46e@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 14 Jun 2007 10:38:39 +0200
Message-Id: <1181810319.7348.345.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-13 at 23:23 -0700, Ollie Wild wrote:
> On 6/13/07, Luck, Tony <tony.luck@intel.com> wrote:
> > Above 5Mbytes, I started seeing problems.  The line/word/char
> > counts from "wc" started being "0 0 0".  Not sure if this is
> > a problem in "wc" dealing with a single line >5MBytes, or some
> > other problem (possibly I was exceeding the per-process stack
> > limit which is only 8MB on that machine).
> 
> Interesting.  If you're exceeding your stack ulimit, you should be
> seeing either an "argument list too long" message or getting a
> SIGSEGV.  Have you tried bypassing wc and piping the output straight
> to a file?

I think it sends SIGKILL on failure paths.

I've been thinking of moving this large stack alloc in
create_elf_tables() before the point of no return.

something like this, it should do the largest part of the alloc
beforehand. Just have to see if all binfmts need this much, and if not,
what the ramifications are of overgrowing the stack (perhaps we need to
shrink it again to wherever bprm->p ends up?)


Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-06-14 10:29:22.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-06-14 10:28:45.000000000 +0200
@@ -272,6 +272,17 @@ static bool valid_arg_len(struct linux_b
 	return len <= MAX_ARG_STRLEN;
 }
 
+static int expand_arg_vma(struct linux_binprm *bprm)
+{
+	long size = (bprm->argc + bprm->envc + 2) * sizeof(void *);
+
+#ifdef CONFIG_STACK_GROWSUP
+#error I broke it
+#else
+	return expand_stack(bprm->vma, bprm->p - size);
+#endif
+}
+
 #else
 
 static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
@@ -326,6 +337,11 @@ static bool valid_arg_len(struct linux_b
 	return len <= bprm->p;
 }
 
+static int expand_arg_vma(struct linux_binprm *bprm)
+{
+	return 0;
+}
+
 #endif /* CONFIG_MMU */
 
 /*
@@ -1385,6 +1401,10 @@ int do_execve(char * filename,
 		goto out;
 	bprm->argv_len = env_p - bprm->p;
 
+	retval = expand_arg_vma(bprm);
+	if (retval < 0)
+		goto out;
+
 	retval = search_binary_handler(bprm,regs);
 	if (retval >= 0) {
 		/* execve success */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
