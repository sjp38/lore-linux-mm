Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82F036B0069
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:51:12 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r23so4789562pfg.17
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:51:12 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x33si12217152plb.147.2017.11.21.14.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 14:51:11 -0800 (PST)
Subject: [PATCH 0/2] device-dax: fix unaligned munmap handling
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 21 Nov 2017 14:42:55 -0800
Message-ID: <151130417573.4029.6745923267963684469.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, stable@vger.kernel.org, linux-nvdimm@lists.01.org

Hi Andrew,

Here is another device-dax fix that requires touching some mm code. When
device-dax is operating in huge-page mode we want it to behave like
hugetlbfs and fail attempts to split vmas into unaligned ranges. It
would be messy to teach the munmap path about device-dax alignment
constraints in the same (hstate) way that hugetlbfs communicates this
constraint. Instead, these patches introduce a new ->split() vm
operation.

---

Dan Williams (2):
      mm, hugetlbfs: introduce ->split() to vm_operations_struct
      device-dax: implement ->split() to catch invalid munmap attempts


 drivers/dax/device.c |   12 ++++++++++++
 include/linux/mm.h   |    1 +
 mm/hugetlb.c         |    8 ++++++++
 mm/mmap.c            |    8 +++++---
 4 files changed, 26 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
