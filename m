Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00AED6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 06:21:16 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 201so5315698itu.13
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 03:21:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w27si5275883ioe.58.2017.06.08.03.21.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 03:21:14 -0700 (PDT)
Subject: Re: 4.9.30 NULL pointer dereference in __remove_shared_vm_struct
References: <7244cb6d-ed7a-451a-1af9-885090173311@nokia.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <d61fec36-ab07-26e6-6572-5c8a58cbe393@I-love.SAKURA.ne.jp>
Date: Thu, 8 Jun 2017 19:21:02 +0900
MIME-Version: 1.0
In-Reply-To: <7244cb6d-ed7a-451a-1af9-885090173311@nokia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tommi Rantala <tommi.t.rantala@nokia.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Tommi Rantala wrote:
> I have hit this kernel bug twice with 4.9.30 while running trinity, any 
> ideas? It's not easily reproducible.

No idea. But if you can reproduce this problem, I think you can retry with
the OOM reaper disabled (like shown below), for the latter report is 10 seconds
after the OOM reaper reclaimed memory.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d..7e17242 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -560,8 +560,8 @@ static void oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
-		schedule_timeout_idle(HZ/10);
+	//while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	//	schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;

Since line 137 is atomic_inc(), file->f_inode was for some reason NULL, wasn't it?

	if (vma->vm_flags & VM_DENYWRITE)
		atomic_inc(&file_inode(file)->i_writecount);

And mmput() from exit_mm() from do_exit() is called before exit_files() is
called from do_exit(). Thus, something by error made file->f_inode == NULL,
despite quite few locations set f_inode to NULL.

# grep -nFr -- '->f_inode ' *
fs/file_table.c:168:    file->f_inode = path->dentry->d_inode;
fs/file_table.c:224:    file->f_inode = NULL;
fs/open.c:711:  f->f_inode = inode;
fs/open.c:782:  f->f_inode = NULL;
fs/overlayfs/copy_up.c:36:      if (f->f_inode == d_inode(dentry))

Maybe the OOM reaper by error reclaimed and somebody zeroed the reclaimed
page containing file->f_inode.

JFYI, 4.9.30 does not have commit 235190738aba7c5c ("oom-reaper: use
madvise_dontneed() logic to decide if unmap the VMA") backported.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
