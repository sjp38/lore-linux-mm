Subject: [PATCH] mm: reorder struct bio to remove padding on 64bit
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain
Date: Thu, 27 Nov 2008 12:03:17 +0000
Message-Id: <1227787397.3120.7.camel@castor.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: neilb@suse.de
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

remove 8 bytes of padding from struct bio which also removes 16 bytes
from struct bio_pair to make it 248 bytes. bio_pair then fits into one
fewer cache lines & into a smaller slab.

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
---
Hi Neil,
This compiles but hasn't had any testing, as I don't have a raid to test
it on. 
patch against 2.6.28-rc6.
regards
Richard



diff --git a/include/linux/bio.h b/include/linux/bio.h
index 6a64209..e6789b2 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -90,10 +90,11 @@ struct bio {
 
 	unsigned int		bi_comp_cpu;	/* completion CPU */
 
+	atomic_t		bi_cnt;		/* pin count */
+
 	struct bio_vec		*bi_io_vec;	/* the actual vec list */
 
 	bio_end_io_t		*bi_end_io;
-	atomic_t		bi_cnt;		/* pin count */
 
 	void			*bi_private;
 #if defined(CONFIG_BLK_DEV_INTEGRITY)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
