Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6226B004D
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 14:47:54 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id jw12so9355689veb.19
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 11:47:53 -0700 (PDT)
Received: from mail-vc0-x229.google.com (mail-vc0-x229.google.com [2607:f8b0:400c:c03::229])
        by mx.google.com with ESMTPS id g7si2264203vek.12.2014.06.04.11.47.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 11:47:53 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id la4so97824vcb.0
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 11:47:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140604182739.GA30340@kroah.com>
References: <20140604182739.GA30340@kroah.com>
Date: Wed, 4 Jun 2014 21:47:53 +0300
Message-ID: <CAKKYfmF5mavFGH1YvnyBf_kNTmMr38BJYwpUNtjhyvzPPScBbQ@mail.gmail.com>
Subject: Re: Bad rss-counter is back on 3.14-stable
From: Dennis Mungai <dmngaie@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, Brandon Philips <brandon.philips@coreos.com>

Hello Greg,

do_exit() and exec_mmap() call sync_mm_rss() before mm_release()
does put_user(clear_child_tid) which can update task->rss_stat
and thus make mm->rss_stat inconsistent. This triggers the "BUG:"
printk in check_mm().

Let's fix this bug in the safest way, and optimize/cleanup this later.

Reported-by: Greg KH <gregkh@linuxfoundation.org>
Signed-off-by: Dennis E. Mungai <dmngaie@gmail.com>
---
 fs/exec.c     |    2 +-
 kernel/exit.c |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)
diff --git a/fs/exec.c b/fs/exec.c
index a79786a..da27b91 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -819,10 +819,10 @@ static int exec_mmap(struct mm_struct *mm)
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
 	old_mm = current->mm;
-	sync_mm_rss(old_mm);
 	mm_release(tsk, old_mm);

 	if (old_mm) {
+		sync_mm_rss(old_mm);
 		/*
 		 * Make sure that if there is a core dump in progress
 		 * for the old mm, we get out and die instead of going
diff --git a/kernel/exit.c b/kernel/exit.c
index 34867cc..c0277d3 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -643,6 +643,7 @@ static void exit_mm(struct task_struct * tsk)
 	mm_release(tsk, mm);
 	if (!mm)
 		return;
+	sync_mm_rss(mm);
 	/*
 	 * Serialize with any possible pending coredump.
 	 * We must hold mmap_sem around checking core_state

Apply that patch and see how it goes.

On 4 June 2014 21:27, Greg KH <gregkh@linuxfoundation.org> wrote:
> Hi all,
>
> Dave, I saw you mention that you were seeing the "Bad rss-counter" line
> on 3.15-rc1, but I couldn't find any follow-up on this to see if anyone
> figured it out, or did it just "magically" go away?
>
> I ask as Brandon is seeing this same message a lot on a 3.14.4 kernel,
> causing system crashes and problems:
>
> [16591492.449718] BUG: Bad rss-counter state mm:ffff8801ced99880 idx:0 val:-1836508
> [16591492.449737] BUG: Bad rss-counter state mm:ffff8801ced99880 idx:1 val:1836508
>
> [20783350.461716] BUG: Bad rss-counter state mm:ffff8801d2b1dc00 idx:0 val:-52518
> [20783350.461734] BUG: Bad rss-counter state mm:ffff8801d2b1dc00 idx:1 val:52518
>
> [21393387.112302] BUG: Bad rss-counter state mm:ffff8801d0104e00 idx:0 val:-1767569
> [21393387.112321] BUG: Bad rss-counter state mm:ffff8801d0104e00 idx:1 val:1767569
>
> [21430098.512837] BUG: Bad rss-counter state mm:ffff880100036680 idx:0 val:-2946
> [21430098.512854] BUG: Bad rss-counter state mm:ffff880100036680 idx:1 val:2946
>
> Anyone have any ideas of a 3.15-rc patch I should be including in
> 3.14-stable to resolve this?
>
> thanks,
>
> greg k-h
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Please avoid sending me Word or PowerPoint attachments.

See http://www.gnu.org/philosophy/no-word-attachments.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
