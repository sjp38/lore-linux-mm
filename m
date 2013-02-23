Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id AB1916B0008
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 17:58:05 -0500 (EST)
From: Phillip Susi <psusi@ubuntu.com>
Subject: [PATCH 2/2] mm: fadvise: implement POSIX_FADV_NOREUSE
Date: Sat, 23 Feb 2013 17:58:01 -0500
Message-Id: <1361660281-22165-3-git-send-email-psusi@ubuntu.com>
In-Reply-To: <1361660281-22165-1-git-send-email-psusi@ubuntu.com>
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com>
In-Reply-To: <5127E8B7.9080202@ubuntu.com>
References: <5127E8B7.9080202@ubuntu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This hint was a nop, now it causes the read/write path to deactivate pages
after reading/writing them, so they will be reclaimed sooner.
---
 include/linux/fs.h |  3 +++
 mm/fadvise.c       |  1 +
 mm/filemap.c       | 11 ++++++++---
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2abd193..de26ee3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -121,6 +121,9 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 /* File is opened with O_PATH; almost nothing can be done with it */
 #define FMODE_PATH		((__force fmode_t)0x4000)
 
+/* POSIX_FADV_NOREUSE has been set */
+#define FMODE_NOREUSE		((__force fmode_t)0x8000)
+
 /* File was opened by fanotify and shouldn't generate fanotify events */
 #define FMODE_NONOTIFY		((__force fmode_t)0x1000000)
 
diff --git a/mm/fadvise.c b/mm/fadvise.c
index fbd58b0..b42bf5b 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -110,6 +110,7 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 					   nrpages);
 		break;
 	case POSIX_FADV_NOREUSE:
+		f.file->f_mode |= FMODE_NOREUSE;
 		break;
 	case POSIX_FADV_DONTNEED:
 		/* First and last FULL page! */
diff --git a/mm/filemap.c b/mm/filemap.c
index bcdcdbf..cba2f41 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1215,8 +1215,11 @@ page_ok:
 		 * When a sequential read accesses a page several times,
 		 * only mark it as accessed the first time.
 		 */
-		if (prev_index != index || offset != prev_offset)
-			mark_page_accessed(page);
+		if (prev_index != index || offset != prev_offset) {
+			if (filp->f_mode & FMODE_NOREUSE)
+				deactivate_page(page);
+			else mark_page_accessed(page);
+		}
 		prev_index = index;
 
 		/*
@@ -2378,7 +2381,9 @@ again:
 		pagefault_enable();
 		flush_dcache_page(page);
 
-		mark_page_accessed(page);
+		if (file->f_mode & FMODE_NOREUSE)
+			deactivate_page(page);
+		else mark_page_accessed(page);
 		status = a_ops->write_end(file, mapping, pos, bytes, copied,
 						page, fsdata);
 		if (unlikely(status < 0))
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
