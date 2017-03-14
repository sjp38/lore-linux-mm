Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5726B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 22:56:45 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a189so256603491qkc.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 19:56:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y88si2012714qtd.8.2017.03.13.19.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 19:56:44 -0700 (PDT)
Date: Tue, 14 Mar 2017 10:56:42 +0800
From: Xiong Zhou <xzhou@redhat.com>
Subject: fsx tests on DAX started to fail with msync failure on 0307 -next
 tree
Message-ID: <20170314025642.nwpf7zxbc6655gum@XZHOUW.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@ml01.01.org
Cc: linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

xfstests cases:
generic/075 generic/112 generic/127 generic/231 generic/263

fail with DAX, pass without it. Both xfs and ext4.

It was okay on 0306 -next tree.

+ ./check generic/075
FSTYP         -- xfs (non-debug)
PLATFORM      -- Linux/x86_64 hp-dl360g9-12 4.11.0-rc1-linux-next-5be4921-next-20170310
MKFS_OPTIONS  -- -f -bsize=4096 /dev/pmem0p2
MOUNT_OPTIONS -- -o dax -o context=system_u:object_r:nfs_t:s0 /dev/pmem0p2 /daxsch

generic/075 4s ... [failed, exit status 1] - output mismatch (see /root/xfstests/results//generic/075.out.bad)
    --- tests/generic/075.out	2016-12-13 14:38:25.984557426 +0800
    +++ /root/xfstests/results//generic/075.out.bad	2017-03-14 10:40:23.083052839 +0800
    @@ -4,15 +4,4 @@
     -----------------------------------------------
     fsx.0 : -d -N numops -S 0
     -----------------------------------------------
    -
    ------------------------------------------------
    -fsx.1 : -d -N numops -S 0 -x
    ------------------------------------------------
    ...
    (Run 'diff -u tests/generic/075.out /root/xfstests/results//generic/075.out.bad'  to see the entire diff)
..

$ diff -u xfstests/tests/generic/075.out /root/xfstests/results//generic/075.out.bad
--- xfstests/tests/generic/075.out	2016-12-13 14:38:25.984557426 +0800
+++ /root/xfstests/results//generic/075.out.bad	2017-03-14 10:40:23.083052839 +0800
@@ -4,15 +4,4 @@
 -----------------------------------------------
 fsx.0 : -d -N numops -S 0
 -----------------------------------------------
-
------------------------------------------------
-fsx.1 : -d -N numops -S 0 -x
------------------------------------------------
-
------------------------------------------------
-fsx.2 : -d -N numops -l filelen -S 0
------------------------------------------------
-
------------------------------------------------
-fsx.3 : -d -N numops -l filelen -S 0 -x
------------------------------------------------
+    fsx (-d -N 1000 -S 0) failed, 0 - compare /root/xfstests/results//generic/075.0.{good,bad,fsxlog}

$ diff -u /root/xfstests/results//generic/075.0.{good,fsxlog} | tail -20
-03cb30 f903 da03 1103 7503 5403 8903 9f03 6b03
-03cb40 bb03 fb03 5603 7e03 c503 ca03 0103 9603
-03cb50 7f03 7c03 0c03 5103 ed03 dc03 a403 5c03
-03cb60 5403 b903 4403 3c03 4b03 a903 2303 1a03
-03cb70 2b03 5f03 fd03 ee03 1303 9703 2903 d303
-03cb80 4e03 9903 f903 8003 b803 2503 2203 c903
-03cb90 6803 7a03 0f03 6303 de03 ba03 6e03 6503
-03cba0 db03
-03cba2
+skipping zero size read
+skipping insert range behind EOF
+3 mapwrite	0x2e836 thru	0x3cba1	(0xe36c bytes)
+domapwrite: msync: Invalid argument
+LOG DUMP (3 total operations):
+1(  1 mod 256): SKIPPED (no operation)
+2(  2 mod 256): SKIPPED (no operation)
+3(  3 mod 256): MAPWRITE 0x2e836 thru 0x3cba1	(0xe36c bytes)
+Log of operations saved to "075.0.fsxops"; replay with --replay-ops
+Correct content saved for comparison
+(maybe hexdump "075.0" vs "075.0.fsxgood")

https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git/tree/tests/generic/075
https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git/tree/ltp/fsx.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
