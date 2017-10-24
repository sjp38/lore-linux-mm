Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8C36B027E
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:26:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u98so5764781wrb.4
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:26:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si364767wre.468.2017.10.24.08.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:25:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and MAP_SYNC
Date: Tue, 24 Oct 2017 17:24:15 +0200
Message-Id: <20171024152415.22864-19-jack@suse.cz>
In-Reply-To: <20171024152415.22864-1-jack@suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Signed-off-by: Jan Kara <jack@suse.cz>
---
 man2/mmap.2 | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 47c3148653be..598ff0c64f7f 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -125,6 +125,21 @@ are carried through to the underlying file.
 to the underlying file requires the use of
 .BR msync (2).)
 .TP
+.B MAP_SHARED_VALIDATE
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
@@ -352,6 +367,21 @@ option.
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
