Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 20A976B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 17:39:08 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id e16so5311561qcx.28
        for <linux-mm@kvack.org>; Fri, 09 May 2014 14:39:07 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTP id e88si2674987qgf.147.2014.05.09.14.39.07
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 14:39:07 -0700 (PDT)
Date: Fri, 9 May 2014 15:39:07 -0600
From: Jens Axboe <axboe@fb.com>
Subject: [PATCH] Avoid always dirtying mapping->flags on O_DIRECT
Message-ID: <20140509213907.GA20698@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

Hi,

In some testing I ran today, we end up spending 40% of the time in
filemap_check_errors(). That smells fishy. Looking further, this is
basically what happens:

blkdev_aio_read()
    generic_file_aio_read()
        filemap_write_and_wait_range()
            if (!mapping->nr_pages)
                filemap_check_errors()

and filemap_check_errors() always attempts two test_and_clear_bit() on
the mapping flags, thus dirtying it for every single invocation. The
patch below tests each of these bits before clearing them, avoiding this
issue. In my test case (4-socket box), performance went from 1.7M IOPS
to 4.0M IOPS.

Signed-off-by: Jens Axboe <axboe@fb.com>

diff --git a/mm/filemap.c b/mm/filemap.c
index 000a220..088358c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -257,9 +257,11 @@ static int filemap_check_errors(struct address_space *mapping)
 {
 	int ret = 0;
 	/* Check for outstanding write errors */
-	if (test_and_clear_bit(AS_ENOSPC, &mapping->flags))
+	if (test_bit(AS_ENOSPC, &mapping->flags) &&
+	    test_and_clear_bit(AS_ENOSPC, &mapping->flags))
 		ret = -ENOSPC;
-	if (test_and_clear_bit(AS_EIO, &mapping->flags))
+	if (test_bit(AS_EIO, &mapping->flags) &&
+	    test_and_clear_bit(AS_EIO, &mapping->flags))
 		ret = -EIO;
 	return ret;
 }


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
