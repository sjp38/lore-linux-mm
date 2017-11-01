Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32D75280253
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:37:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i196so2846609pgd.2
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:37:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6si1267022pgt.798.2017.11.01.08.37.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:37:03 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and MAP_SYNC
Date: Wed,  1 Nov 2017 16:36:48 +0100
Message-Id: <20171101153648.30166-20-jack@suse.cz>
In-Reply-To: <20171101153648.30166-1-jack@suse.cz>
References: <20171101153648.30166-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 man2/mmap.2 | 35 ++++++++++++++++++++++++++++++++++-
 1 file changed, 34 insertions(+), 1 deletion(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 47c3148653be..b38ee6809327 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -125,6 +125,21 @@ are carried through to the underlying file.
 to the underlying file requires the use of
 .BR msync (2).)
 .TP
+.BR MAP_SHARED_VALIDATE " (since Linux 4.15)"
+The same as
+.B MAP_SHARED
+except that
+.B MAP_SHARED
+mappings ignore unknown flags in
+.IR flags .
+In contrast when creating mapping of
+.B MAP_SHARED_VALIDATE
+mapping type, the kernel verifies all passed flags are known and fails the
+mapping with
+.BR EOPNOTSUPP
+otherwise. This mapping type is also required to be able to use some mapping
+flags.
+.TP
 .B MAP_PRIVATE
 Create a private copy-on-write mapping.
 Updates to the mapping are not visible to other processes
@@ -134,7 +149,10 @@ It is unspecified whether changes made to the file after the
 .BR mmap ()
 call are visible in the mapped region.
 .PP
-Both of these flags are described in POSIX.1-2001 and POSIX.1-2008.
+.B MAP_SHARED
+and
+.B MAP_PRIVATE
+are described in POSIX.1-2001 and POSIX.1-2008.
 .PP
 In addition, zero or more of the following values can be ORed in
 .IR flags :
@@ -352,6 +370,21 @@ option.
 Because of the security implications,
 that option is normally enabled only on embedded devices
 (i.e., devices where one has complete control of the contents of user memory).
+.TP
+.BR MAP_SYNC " (since Linux 4.15)"
+This flags is available only with
+.B MAP_SHARED_VALIDATE
+mapping type. Mappings of
+.B MAP_SHARED
+type will silently ignore this flag.
+This flag is supported only for files supporting DAX (direct mapping of persistent
+memory). For other files, creating mapping with this flag results in
+.B EOPNOTSUPP
+error. Shared file mappings with this flag provide the guarantee that while
+some memory is writeably mapped in the address space of the process, it will
+be visible in the same file at the same offset even after the system crashes or
+is rebooted. This allows users of such mappings to make data modifications
+persistent in a more efficient way using appropriate CPU instructions.
 .PP
 Of the above flags, only
 .B MAP_FIXED
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
