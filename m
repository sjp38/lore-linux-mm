Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9FF36B0253
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 22:45:42 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id r18so16814788qkh.4
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 19:45:42 -0700 (PDT)
Received: from sasl.smtp.pobox.com (pb-smtp1.pobox.com. [64.147.108.70])
        by mx.google.com with ESMTPS id g206si403623qkb.542.2017.10.05.19.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 19:45:39 -0700 (PDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v5 5/5] cramfs: rehabilitate it
Date: Thu,  5 Oct 2017 22:45:31 -0400
Message-Id: <20171006024531.8885-6-nicolas.pitre@linaro.org>
In-Reply-To: <20171006024531.8885-1-nicolas.pitre@linaro.org>
References: <20171006024531.8885-1-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

Update documentation, pointer to latest tools, appoint myself as
maintainer. Given it's been unloved for so long, I don't expect anyone
will protest.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Tested-by: Chris Brandt <chris.brandt@renesas.com>
---
 Documentation/filesystems/cramfs.txt | 42 ++++++++++++++++++++++++++++++++++++
 MAINTAINERS                          |  4 ++--
 fs/cramfs/Kconfig                    |  9 +++++---
 3 files changed, 50 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/cramfs.txt b/Documentation/filesystems/cramfs.txt
index 4006298f67..8875d306bc 100644
--- a/Documentation/filesystems/cramfs.txt
+++ b/Documentation/filesystems/cramfs.txt
@@ -45,6 +45,48 @@ you can just change the #define in mkcramfs.c, so long as you don't
 mind the filesystem becoming unreadable to future kernels.
 
 
+Memory Mapped cramfs image
+--------------------------
+
+The CRAMFS_PHYSMEM Kconfig option adds support for loading data directly
+from a physical linear memory range (usually non volatile memory like Flash)
+to cramfs instead of going through the block device layer. This saves some
+memory since no intermediate buffering is necessary to hold the data before
+decompressing.
+
+And when data blocks are kept uncompressed and properly aligned, they will
+automatically be mapped directly into user space whenever possible providing
+eXecute-In-Place (XIP) from ROM of read-only segments. Data segments mapped
+read-write (hence they have to be copied to RAM) may still be compressed in
+the cramfs image in the same file along with non compressed read-only
+segments. Both MMU and no-MMU systems are supported. This is particularly
+handy for tiny embedded systems with very tight memory constraints.
+
+The filesystem type for this feature is "cramfs_physmem" to distinguish it
+from the block device (or MTD) based access. The location of the cramfs
+image in memory is system dependent. You must know the proper physical
+address where the cramfs image is located and specify it using the
+physaddr=0x******** mount option (for example, if the physical address
+of the cramfs image is 0x80100000, the following command would mount it
+on /mnt:
+
+$ mount -t cramfs_physmem -o physaddr=0x80100000 none /mnt
+
+To boot such an image as the root filesystem, the following kernel
+commandline parameters must be provided:
+
+	"rootfstype=cramfs_physmem rootflags=physaddr=0x80100000"
+
+
+Tools
+-----
+
+A version of mkcramfs that can take advantage of the latest capabilities
+described above can be found here:
+
+https://github.com/npitre/cramfs-tools
+
+
 For /usr/share/magic
 --------------------
 
diff --git a/MAINTAINERS b/MAINTAINERS
index 1c3feffb1c..f00aec6a66 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3612,8 +3612,8 @@ F:	drivers/cpuidle/*
 F:	include/linux/cpuidle.h
 
 CRAMFS FILESYSTEM
-W:	http://sourceforge.net/projects/cramfs/
-S:	Orphan / Obsolete
+M:	Nicolas Pitre <nico@linaro.org>
+S:	Maintained
 F:	Documentation/filesystems/cramfs.txt
 F:	fs/cramfs/
 
diff --git a/fs/cramfs/Kconfig b/fs/cramfs/Kconfig
index 5b4e0b7e13..ae1fe6c795 100644
--- a/fs/cramfs/Kconfig
+++ b/fs/cramfs/Kconfig
@@ -1,5 +1,5 @@
 config CRAMFS
-	tristate "Compressed ROM file system support (cramfs) (OBSOLETE)"
+	tristate "Compressed ROM file system support (cramfs)"
 	select ZLIB_INFLATE
 	help
 	  Saying Y here includes support for CramFs (Compressed ROM File
@@ -15,8 +15,11 @@ config CRAMFS
 	  cramfs.  Note that the root file system (the one containing the
 	  directory /) cannot be compiled as a module.
 
-	  This filesystem is obsoleted by SquashFS, which is much better
-	  in terms of performance and features.
+	  This filesystem is limited in capabilities and performance on
+	  purpose to remain small and low on RAM usage. It is most suitable
+	  for small embedded systems. For a more capable compressed filesystem
+	  you should look at SquashFS which is much better in terms of
+	  performance and features.
 
 	  If unsure, say N.
 
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
