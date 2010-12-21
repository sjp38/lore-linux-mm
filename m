Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F17056B0089
	for <linux-mm@kvack.org>; Tue, 21 Dec 2010 01:26:36 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id oBL6QZ3l021757
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 22:26:35 -0800
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz13.hot.corp.google.com with ESMTP id oBL6QXUG000446
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 22:26:34 -0800
Received: by pvg7 with SMTP id 7so1211771pvg.22
        for <linux-mm@kvack.org>; Mon, 20 Dec 2010 22:26:33 -0800 (PST)
Date: Mon, 20 Dec 2010 22:26:29 -0800
From: Michel Lespinasse <walken@google.com>
Subject: Re: mmotm 2010-12-16 - breaks mlockall() call
Message-ID: <20101221062629.GA17066@google.com>
References: <201012162329.oBGNTdPY006808@imap1.linux-foundation.org>
 <131961.1292667059@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <131961.1292667059@localhost>
Sender: owner-linux-mm@kvack.org
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 18, 2010 at 05:10:59AM -0500, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 16 Dec 2010 14:56:39 PST, akpm@linux-foundation.org said:
> > The mm-of-the-moment snapshot 2010-12-16-14-56 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> 
> The patch mlock-only-hold-mmap_sem-in-shared-mode-when-faulting-in-pages.patch
> causes this chunk of code from cryptsetup-luks to fail during the initramfs:
> 
> 	if (mlockall(MCL_CURRENT | MCL_FUTURE)) {
>                         log_err(ctx, _("WARNING!!! Possibly insecure memory. Are you root?\n"));
>                         _memlock_count--;
>                         return 0;
>                 }
> 
> Bisection fingered this patch, which was added after -rc4-mmotm1202, which
> boots without tripping this log_err() call.  I haven't tried building a
> -rc6-mmotm1216 with this patch reverted, because reverting it causes apply
> errors for subsequent patches.
> 
> Ideas?

So I traced this down using valdis's initramfs image. This is actually
an interesting corner case:

Some VMA has the VM_MAY_(READ/WRITE/EXEC) flags, but is currently protected
with PROT_NONE permissions (VM_READ/WRITE_EXEC flags are all cleared).

When mlockall() is called, the old code would see mlock_fixup() return
an error for that VMA, which would be ignored by do_mlockall(). The new
code did not ignore errors from do_mlock_pages(), which broke backwards
compatibility.

So the trivial fix to make mlockall behave identically as before could be
as follows:

Signed-off-by: Michel Lespinasse <walken@google.com>

diff --git a/mm/mlock.c b/mm/mlock.c
index db0ed84..168b750 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -424,7 +424,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
-static int do_mlock_pages(unsigned long start, size_t len)
+static int do_mlock_pages(unsigned long start, size_t len, int ignore_errors)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long end, nstart, nend;
@@ -465,6 +465,10 @@ static int do_mlock_pages(unsigned long start, size_t len)
 		 */
 		ret = __mlock_vma_pages_range(vma, nstart, nend, &locked);
 		if (ret < 0) {
+			if (ignore_errors) {
+				ret = 0;
+				continue;	/* continue at next VMA */
+			}
 			ret = __mlock_posix_error_return(ret);
 			break;
 		}
@@ -502,7 +506,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 		error = do_mlock(start, len, 1);
 	up_write(&current->mm->mmap_sem);
 	if (!error)
-		error = do_mlock_pages(start, len);
+		error = do_mlock_pages(start, len, 0);
 	return error;
 }
 
@@ -567,8 +571,10 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	    capable(CAP_IPC_LOCK))
 		ret = do_mlockall(flags);
 	up_write(&current->mm->mmap_sem);
-	if (!ret && (flags & MCL_CURRENT))
-		ret = do_mlock_pages(0, TASK_SIZE);
+	if (!ret && (flags & MCL_CURRENT)) {
+		/* Ignore errors */
+		do_mlock_pages(0, TASK_SIZE, 1);
+	}
 out:
 	return ret;
 }

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
