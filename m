Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD636B0266
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:16:46 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m6so10228775qtc.6
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 23:16:46 -0700 (PDT)
Received: from sasl.smtp.pobox.com (pb-smtp2.pobox.com. [64.147.108.71])
        by mx.google.com with ESMTPS id 125si2072599qkl.402.2017.10.11.23.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 23:16:44 -0700 (PDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v6 4/4] cramfs: rehabilitate it
Date: Thu, 12 Oct 2017 02:16:13 -0400
Message-Id: <20171012061613.28705-5-nicolas.pitre@linaro.org>
In-Reply-To: <20171012061613.28705-1-nicolas.pitre@linaro.org>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org>
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
index 4006298f67..8e19a53d64 100644
--- a/Documentation/filesystems/cramfs.txt
+++ b/Documentation/filesystems/cramfs.txt
@@ -45,6 +45,48 @@ you can just change the #define in mkcramfs.c, so long as you don't
 mind the filesystem becoming unreadable to future kernels.
 
 
+Memory Mapped cramfs image
+--------------------------
+
+The CRAMFS_MTD Kconfig option adds support for loading data directly from
+a physical linear memory range (usually non volatile memory like Flash)
+instead of going through the block device layer. This saves some memory
+since no intermediate buffering is necessary to hold the data before
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
+The location of the cramfs image in memory is system dependent. You must
+know the proper physical address where the cramfs image is located and
+configure an MTD device for it. Also, that MTD device must be supported
+by a map driver that implements the "point" method. Examples of such
+MTD drivers are cfi_cmdset_0001 (Intel/Sharp CFI flash) or physmap
+(Flash device in physical memory map). MTD partitions based on such devices
+are fine too. Then that device should be specified with the "mtd:" prefix
+as the mount device argument. For example, to mount the MTD device named
+"fs_partition" on the /mnt directory:
+
+$ mount -t cramfs mtd:fs_partition /mnt
+
+To boot a kernel with this as root filesystem, suffice to specify
+something like "root=mtd:fs_partition" on the kernel command line.
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
index 65b0c88d5e..cd621c5f52 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3676,8 +3676,8 @@ F:	drivers/cpuidle/*
 F:	include/linux/cpuidle.h
 
 CRAMFS FILESYSTEM
-W:	http://sourceforge.net/projects/cramfs/
-S:	Orphan / Obsolete
+M:	Nicolas Pitre <nico@linaro.org>
+S:	Maintained
 F:	Documentation/filesystems/cramfs.txt
 F:	fs/cramfs/
 
diff --git a/fs/cramfs/Kconfig b/fs/cramfs/Kconfig
index ef86b06bc0..f937082f32 100644
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
+	  for small embedded systems. If you have ample RAM to spare, you may
+	  consider a more capable compressed filesystem such as SquashFS
+	  which is much better in terms of performance and features.
 
 	  If unsure, say N.
 
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
