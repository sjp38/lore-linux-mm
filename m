Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C655D6B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 17:51:51 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so36754213pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 14:51:51 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id kg9si15493574pab.53.2015.12.09.14.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 14:51:50 -0800 (PST)
Received: by pfbg73 with SMTP id g73so37808808pfb.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 14:51:50 -0800 (PST)
Date: Wed, 9 Dec 2015 14:51:48 -0800
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v5] fs: clear file privilege bits when mmap writing
Message-ID: <20151209225148.GA14794@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Normally, when a user can modify a file that has setuid or setgid bits,
those bits are cleared when they are not the file owner or a member
of the group. This is enforced when using write and truncate but not
when writing to a shared mmap on the file. This could allow the file
writer to gain privileges by changing a binary without losing the
setuid/setgid/caps bits.

Changing the bits requires holding inode->i_mutex, so it cannot be done
during the page fault (due to mmap_sem being held during the fault). We
could do this during vm_mmap_pgoff, but that would need coverage in
mprotect as well, but to check for MAP_SHARED, we'd need to hold mmap_sem
again. We could clear at open() time, but it's possible things are
accidentally opening with O_RDWR and only reading. Better to clear on
close and error failures (i.e. an improvement over now, which is not
clearing at all).

Instead, detect the need to clear the bits during the page fault, and
actually remove the bits during final fput. Since the file was open for
writing, it wouldn't have been possible to execute it yet.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
I think this is the best we can do; everything else is blocked by mmap_sem.
---
 fs/file_table.c    | 11 +++++++++++
 include/linux/fs.h |  1 +
 mm/memory.c        |  1 +
 3 files changed, 13 insertions(+)

diff --git a/fs/file_table.c b/fs/file_table.c
index ad17e05ebf95..3a7eee76ea90 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -191,6 +191,17 @@ static void __fput(struct file *file)
 
 	might_sleep();
 
+	/*
+	 * XXX: While avoiding mmap_sem, we've already been written to.
+	 * We must ignore the return value, since we can't reject the
+	 * write.
+	 */
+	if (unlikely(file->f_remove_privs)) {
+		mutex_lock(&inode->i_mutex);
+		file_remove_privs(file);
+		mutex_unlock(&inode->i_mutex);
+	}
+
 	fsnotify_close(file);
 	/*
 	 * The function eventpoll_release() should be the first called
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3aa514254161..409bd7047e7e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -872,6 +872,7 @@ struct file {
 	struct list_head	f_tfile_llink;
 #endif /* #ifdef CONFIG_EPOLL */
 	struct address_space	*f_mapping;
+	bool			f_remove_privs;
 } __attribute__((aligned(4)));	/* lest something weird decides that 2 is OK */
 
 struct file_handle {
diff --git a/mm/memory.c b/mm/memory.c
index c387430f06c3..08a77e0cf65f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 
 		if (!page_mkwrite)
 			file_update_time(vma->vm_file);
+		vma->vm_file->f_remove_privs = true;
 	}
 
 	return VM_FAULT_WRITE;
-- 
1.9.1


-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
