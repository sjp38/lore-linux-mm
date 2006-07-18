Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I48eOk002586
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 18 Jul 2006 00:08:40 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I48dd1269998
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:40 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I48dd5010587
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:39 -0600
Date: Mon, 17 Jul 2006 22:08:38 -0600
From: Dave Kleikamp <shaggy@austin.ibm.com>
Message-Id: <20060718040836.11926.34664.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
References: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 004/008] Wrap i_size_write
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Dave McCracken <dmccr@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Wrap i_size_write

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
---
diff -Nurp linux003/include/linux/fs.h linux004/include/linux/fs.h
--- linux003/include/linux/fs.h	2006-07-17 23:04:37.000000000 -0500
+++ linux004/include/linux/fs.h	2006-07-17 23:04:38.000000000 -0500
@@ -578,8 +578,13 @@ static inline loff_t i_size_read(struct 
 #endif
 }
 
+#ifdef CONFIG_FILE_TAILS
+extern void i_size_write(struct inode *, loff_t); /* defined in file_tail.c */
 
+static inline void _i_size_write(struct inode *inode, loff_t i_size)
+#else
 static inline void i_size_write(struct inode *inode, loff_t i_size)
+#endif
 {
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	write_seqcount_begin(&inode->i_size_seqcount);

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
