Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1546B00AD
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 14:46:33 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so5808804eek.37
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 11:46:31 -0700 (PDT)
Received: from xavier.telenet-ops.be (xavier.telenet-ops.be. [195.130.132.52])
        by mx.google.com with ESMTP id u49si18229609eef.52.2014.04.13.11.46.30
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 11:46:30 -0700 (PDT)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 2/2] mm: Initialize error in shmem_file_aio_read()
Date: Sun, 13 Apr 2014 20:46:22 +0200
Message-Id: <1397414783-28098-2-git-send-email-geert@linux-m68k.org>
In-Reply-To: <1397414783-28098-1-git-send-email-geert@linux-m68k.org>
References: <1397414783-28098-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

mm/shmem.c: In function a??shmem_file_aio_reada??:
mm/shmem.c:1414: warning: a??errora?? may be used uninitialized in this function

If the loop is aborted during the first iteration by one of the two first
break statements, error will be uninitialized.

Introduced by commit 6e58e79db8a16222b31fc8da1ca2ac2dccfc4237
("introduce copy_page_to_iter, kill loop over iovec in
generic_file_aio_read()").

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
The code is too complex to see if this is an obvious false positive.

 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8f1a95406bae..9f70e02111c6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1411,7 +1411,7 @@ static ssize_t shmem_file_aio_read(struct kiocb *iocb,
 	pgoff_t index;
 	unsigned long offset;
 	enum sgp_type sgp = SGP_READ;
-	int error;
+	int error = 0;
 	ssize_t retval;
 	size_t count;
 	loff_t *ppos = &iocb->ki_pos;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
