Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52F996B029F
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:57:58 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j92so262100470ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:57:58 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id z11si41661536ioi.26.2016.11.28.11.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 29/33] tpm: Use idr_find(), not idr_find_slowpath()
Date: Mon, 28 Nov 2016 13:51:07 -0800
Message-Id: <1480369871-5271-64-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

idr_find_slowpath() is not intended to be part of the public API, it's
an implementation detail.  There's no reason to skip straight to the
slowpath here.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/char/tpm/tpm-chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/char/tpm/tpm-chip.c b/drivers/char/tpm/tpm-chip.c
index 7a48691..a77262d 100644
--- a/drivers/char/tpm/tpm-chip.c
+++ b/drivers/char/tpm/tpm-chip.c
@@ -84,7 +84,7 @@ EXPORT_SYMBOL_GPL(tpm_put_ops);
  *
  * The return'd chip has been tpm_try_get_ops'd and must be released via
  * tpm_put_ops
-  */
+ */
 struct tpm_chip *tpm_chip_find_get(int chip_num)
 {
 	struct tpm_chip *chip, *res = NULL;
@@ -103,7 +103,7 @@ struct tpm_chip *tpm_chip_find_get(int chip_num)
 			}
 		} while (chip_prev != chip_num);
 	} else {
-		chip = idr_find_slowpath(&dev_nums_idr, chip_num);
+		chip = idr_find(&dev_nums_idr, chip_num);
 		if (chip && !tpm_try_get_ops(chip))
 			res = chip;
 	}
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
