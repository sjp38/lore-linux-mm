Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3296B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 21:56:45 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id l6so6160312pfl.3
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 18:56:45 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id iv8si7992264pac.104.2016.02.29.18.56.44
        for <linux-mm@kvack.org>;
        Mon, 29 Feb 2016 18:56:44 -0800 (PST)
Subject: [PATCH 0/2] devm_memremap_pages vs section-misaligned pmem
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 29 Feb 2016 18:56:20 -0800
Message-ID: <20160301025620.12812.87268.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Recent testing uncovered two bugs around the handling of section-misaligned
pmem regions:

1/ If the pmem section overlaps "System RAM" we need to fail the
   devm_memremap_pages() request.  Previously we would mis-detect a
   memory map like the following:

	100000000-37bffffff : System RAM
	37c000000-837ffffff : Persistent Memory

2/ If the pmem section is misaligned, but otherwise does not overlap
   memory from another zone, the altmap needs to be fixed up to add the
   alignment padding to the 'reserved ' pfns of the altmap.

---

Dan Williams (2):
      libnvdimm, pmem: fix 'pfn' support for section-misaligned namespaces
      mm: fix mixed zone detection in devm_memremap_pages


 drivers/nvdimm/pmem.c |   29 +++++++++++++++++++++++++++--
 kernel/memremap.c     |    9 ++++-----
 2 files changed, 31 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
