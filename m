Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA2382F82
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 02:06:44 -0500 (EST)
Received: by pfu207 with SMTP id 207so43399365pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 23:06:44 -0800 (PST)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id lf12si18400821pab.22.2015.12.09.23.06.41
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 23:06:42 -0800 (PST)
Date: Thu, 10 Dec 2015 08:06:35 +0100
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
Message-ID: <20151210070635.GC31922@1wt.eu>
References: <20151209225148.GA14794@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209225148.GA14794@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kees,

Why not add a new file flag instead ?

Something like this (editing your patch by hand to illustrate) :

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
+	if (unlikely(file->f_flags & FL_DROP_PRIVS)) {
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
@@ -913,3 +913,4 @@
 #define FL_OFDLCK       1024    /* lock is "owned" by struct file */
 #define FL_LAYOUT       2048    /* outstanding pNFS layout */
+#define FL_DROP_PRIVS   4096    /* lest something weird decides that 2 is OK */
 
diff --git a/mm/memory.c b/mm/memory.c
index c387430f06c3..08a77e0cf65f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 
 		if (!page_mkwrite)
 			file_update_time(vma->vm_file);
+		vma->vm_file->f_flags |= FL_DROP_PRIVS;
 	}
 
 	return VM_FAULT_WRITE;

Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
