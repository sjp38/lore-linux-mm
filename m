Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8CCE16B0260
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e64so15582962wmi.0
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 10:45:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f8si4135086edb.27.2017.09.27.10.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 10:45:12 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8RHi0pr126163
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:10 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d8fpmknb3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:10 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 27 Sep 2017 18:45:08 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH 2/3] tests/lsmem: update lsmem test with ZONES column
Date: Wed, 27 Sep 2017 19:44:45 +0200
In-Reply-To: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
References: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
Message-Id: <20170927174446.20459-3-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: util-linux@vger.kernel.org, Karel Zak <kzak@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andre Wild <wild@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

The existing s390 and x86_64 dumps already contain the valid_zones sysfs
attribute, so just add a new "lsmem -o +ZONES" test command and update
the expected results.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 tests/expected/lsmem/lsmem-s390-zvm-6g | 21 ++++++++++++++++++
 tests/expected/lsmem/lsmem-x86_64-16g  | 39 ++++++++++++++++++++++++++++++++++
 tests/ts/lsmem/lsmem                   |  1 +
 3 files changed, 61 insertions(+)

diff --git a/tests/expected/lsmem/lsmem-s390-zvm-6g b/tests/expected/lsmem/lsmem-s390-zvm-6g
index 05af40d4df9f..9f4c805ad0a6 100644
--- a/tests/expected/lsmem/lsmem-s390-zvm-6g
+++ b/tests/expected/lsmem/lsmem-s390-zvm-6g
@@ -106,3 +106,24 @@ $ lsmem --json --output RANGE,SIZE,STATE,REMOVABLE,BLOCK,NODE
       {"range": "0x0000000140000000-0x000000017fffffff", "size": "1G", "state": "offline", "removable": "-", "block": "20-23", "node": "0"}
    ]
 }
+
+---
+
+$ lsmem -o +ZONES
+RANGE                                  SIZE   STATE REMOVABLE BLOCK          ZONES
+0x0000000000000000-0x000000006fffffff  1.8G  online       yes   0-6            DMA
+0x0000000070000000-0x000000007fffffff  256M  online        no     7     DMA/Normal
+0x0000000080000000-0x000000009fffffff  512M  online       yes   8-9         Normal
+0x00000000a0000000-0x00000000bfffffff  512M  online        no 10-11         Normal
+0x00000000c0000000-0x00000000dfffffff  512M  online       yes 12-13         Normal
+0x00000000e0000000-0x00000000efffffff  256M offline         -    14         Normal
+0x00000000f0000000-0x00000000ffffffff  256M  online       yes    15         Normal
+0x0000000100000000-0x000000010fffffff  256M  online        no    16         Normal
+0x0000000110000000-0x000000011fffffff  256M  online        no    17 Normal/Movable
+0x0000000120000000-0x000000012fffffff  256M  online       yes    18 Movable/Normal
+0x0000000130000000-0x000000013fffffff  256M  online       yes    19        Movable
+0x0000000140000000-0x000000017fffffff    1G offline         - 20-23        Movable
+
+Memory block size:       256M
+Total online memory:     4.8G
+Total offline memory:    1.3G
diff --git a/tests/expected/lsmem/lsmem-x86_64-16g b/tests/expected/lsmem/lsmem-x86_64-16g
index 14d7d84f65ca..40316a584518 100644
--- a/tests/expected/lsmem/lsmem-x86_64-16g
+++ b/tests/expected/lsmem/lsmem-x86_64-16g
@@ -269,3 +269,42 @@ $ lsmem --json --output RANGE,SIZE,STATE,REMOVABLE,BLOCK,NODE
       {"range": "0x0000000438000000-0x000000043fffffff", "size": "128M", "state": "online", "removable": "no", "block": "135", "node": "0"}
    ]
 }
+
+---
+
+$ lsmem -o +ZONES
+RANGE                                  SIZE  STATE REMOVABLE   BLOCK  ZONES
+0x0000000000000000-0x0000000007ffffff  128M online        no       0   None
+0x0000000008000000-0x0000000037ffffff  768M online       yes     1-6  DMA32
+0x0000000038000000-0x000000003fffffff  128M online        no       7  DMA32
+0x0000000040000000-0x0000000077ffffff  896M online       yes    8-14  DMA32
+0x0000000078000000-0x000000007fffffff  128M online        no      15  DMA32
+0x0000000080000000-0x00000000afffffff  768M online       yes   16-21  DMA32
+0x00000000b0000000-0x00000000bfffffff  256M online        no   22-23  DMA32
+0x0000000100000000-0x00000001a7ffffff  2.6G online        no   32-52 Normal
+0x00000001a8000000-0x00000001afffffff  128M online       yes      53 Normal
+0x00000001b0000000-0x00000001bfffffff  256M online        no   54-55 Normal
+0x00000001c0000000-0x00000001ffffffff    1G online       yes   56-63 Normal
+0x0000000200000000-0x0000000207ffffff  128M online        no      64 Normal
+0x0000000208000000-0x000000021fffffff  384M online       yes   65-67 Normal
+0x0000000220000000-0x0000000237ffffff  384M online        no   68-70 Normal
+0x0000000238000000-0x0000000277ffffff    1G online       yes   71-78 Normal
+0x0000000278000000-0x000000028fffffff  384M online        no   79-81 Normal
+0x0000000290000000-0x0000000297ffffff  128M online       yes      82 Normal
+0x0000000298000000-0x00000002a7ffffff  256M online        no   83-84 Normal
+0x00000002a8000000-0x00000002c7ffffff  512M online       yes   85-88 Normal
+0x00000002c8000000-0x00000002dfffffff  384M online        no   89-91 Normal
+0x00000002e0000000-0x00000002efffffff  256M online       yes   92-93 Normal
+0x00000002f0000000-0x000000034fffffff  1.5G online        no  94-105 Normal
+0x0000000350000000-0x0000000357ffffff  128M online       yes     106 Normal
+0x0000000358000000-0x000000036fffffff  384M online        no 107-109 Normal
+0x0000000370000000-0x0000000377ffffff  128M online       yes     110 Normal
+0x0000000378000000-0x00000003c7ffffff  1.3G online        no 111-120 Normal
+0x00000003c8000000-0x00000003e7ffffff  512M online       yes 121-124 Normal
+0x00000003e8000000-0x000000042fffffff  1.1G online        no 125-133 Normal
+0x0000000430000000-0x0000000437ffffff  128M online       yes     134 Normal
+0x0000000438000000-0x000000043fffffff  128M online        no     135   None
+
+Memory block size:       128M
+Total online memory:      16G
+Total offline memory:      0B
diff --git a/tests/ts/lsmem/lsmem b/tests/ts/lsmem/lsmem
index 79c0523b96a3..b1313773e212 100755
--- a/tests/ts/lsmem/lsmem
+++ b/tests/ts/lsmem/lsmem
@@ -49,6 +49,7 @@ for dump in $(ls $TS_SELF/dumps/*.tar.bz2 | sort); do
 	do_lsmem --all --output $LSCOLUMNS
 	do_lsmem --raw --output $LSCOLUMNS
 	do_lsmem --json --output $LSCOLUMNS
+	do_lsmem -o +ZONES
 
 	ts_finalize_subtest
 done
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
