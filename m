Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE548D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:57:25 -0400 (EDT)
Received: by mail-pv0-f169.google.com with SMTP id 4so777017pvg.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:57:24 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 6/6] nommu: fix a compile warning in do_mmap_pgoff()
Date: Mon, 28 Mar 2011 22:56:47 +0900
Message-Id: <1301320607-7259-7-git-send-email-namhyung@gmail.com>
In-Reply-To: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
References: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Greg Ungerer <gerg@snapgear.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Because 'ret' is declared as int, not unsigned long, no need to cast the
error contants into unsigned long. If you compile this code on a 64-bit
machine somehow, you'll see following warning:

  CC      mm/nommu.o
mm/nommu.c: In function a??do_mmap_pgoffa??:
mm/nommu.c:1411: warning: overflow in implicit constant conversion

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/nommu.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 662fd46449a6..c7af249076ac 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1400,15 +1400,15 @@ unsigned long do_mmap_pgoff(struct file *file,
 		if (capabilities & BDI_CAP_MAP_DIRECT) {
 			addr = file->f_op->get_unmapped_area(file, addr, len,
 							     pgoff, flags);
-			if (IS_ERR((void *) addr)) {
+			if (IS_ERR_VALUE(addr)) {
 				ret = addr;
-				if (ret != (unsigned long) -ENOSYS)
+				if (ret != -ENOSYS)
 					goto error_just_free;
 
 				/* the driver refused to tell us where to site
 				 * the mapping so we'll have to attempt to copy
 				 * it */
-				ret = (unsigned long) -ENODEV;
+				ret = -ENODEV;
 				if (!(capabilities & BDI_CAP_MAP_COPY))
 					goto error_just_free;
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
