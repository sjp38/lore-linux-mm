Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 275696B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 06:25:37 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e2so31884822qta.13
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 03:25:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r130si2712864qke.417.2017.08.17.03.25.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 03:25:36 -0700 (PDT)
Date: Thu, 17 Aug 2017 13:25:14 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] shmem: prepare huge= mount option and sysfs knob
Message-ID: <20170817102514.7rhgjjuawxr4gubp@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org

Hello Kirill A. Shutemov,

The patch 5a6e75f8110c: "shmem: prepare huge= mount option and sysfs
knob" from Jul 26, 2016, leads to the following static checker
warning:

	mm/shmem.c:4013 shmem_init()
	warn: assigning (-2) to unsigned variable 'SHMEM_SB(shm_mnt->mnt_sb)->huge'

mm/shmem.c
  4012  #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
  4013          if (has_transparent_hugepage() && shmem_huge < SHMEM_HUGE_DENY)
  4014                  SHMEM_SB(shm_mnt->mnt_sb)->huge = shmem_huge;


SHMEM_HUGE_DENY is -1 so the value less than that is SHMEM_HUGE_FORCE (-2).

  4015          else
  4016                  shmem_huge = 0; /* just in case it was patched */
  4017  #endif
  4018          return 0;

Btw, if shmem_parse_huge() returns SHMEM_HUGE_FORCE, then both callers
treat that as an error.  The handling for SHMEM_HUGE_FORCE is confusing
for my tiny brain.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
