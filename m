Date: Mon, 5 May 2003 14:01:51 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm1
Message-ID: <20030505210151.GO8978@holomorphy.com>
References: <20030504231650.75881288.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030504231650.75881288.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 04, 2003 at 11:16:50PM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm1/
> Various random fixups, cleanps and speedups.  Mainly a resync to 2.5.69.

fs/file_table.c: In function `fget_light':
fs/file_table.c:209: warning: passing arg 1 of `_raw_read_lock' from incompatible pointer type


diff -urpN mm1-2.5.69-1/fs/file_table.c mm1-2.5.69-2/fs/file_table.c
--- mm1-2.5.69-1/fs/file_table.c	2003-05-05 13:32:43.000000000 -0700
+++ mm1-2.5.69-2/fs/file_table.c	2003-05-05 13:38:39.000000000 -0700
@@ -206,13 +206,13 @@ struct file *fget_light(unsigned int fd,
 	if (likely((atomic_read(&files->count) == 1))) {
 		file = fcheck(fd);
 	} else {
-		read_lock(&files->file_lock);
+		spin_lock(&files->file_lock);
 		file = fcheck(fd);
 		if (file) {
 			get_file(file);
 			*fput_needed = 1;
 		}
-		read_unlock(&files->file_lock);
+		spin_unlock(&files->file_lock);
 	}
 	return file;
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
