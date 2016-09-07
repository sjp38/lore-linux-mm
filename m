Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D68846B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 18:51:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g202so71865481pfb.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 15:51:49 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r83si23157847pfb.132.2016.09.07.15.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 15:29:10 -0700 (PDT)
Subject: [PATCH v2 0/2] fix cache mode tracking for pmem + dax
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 07 Sep 2016 15:26:08 -0700
Message-ID: <147328716869.35069.16311932814998156819.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Toshi Kani <toshi.kani@hpe.com>, Matthew Wilcox <mawilcox@microsoft.com>, David Airlie <airlied@linux.ie>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Ross Zwisler <ross.zwisler@linux.intel.com>, akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

While writing an improved changelog, as prompted by Andrew, for v1 of
"mm: fix cache mode of dax pmd mappings" [1], it struck me that
vmf_insert_pfn_pmd() is implemented correctly.  Instead, it is the
memtype tree that is missing a memtype reservation for
devm_memremap_pages() ranges.

vmf_insert_pfn_pmd() is correct to validate the memtype before inserting
a mapping, but this highlights that vm_insert_mixed() is missing this
validation.

I would still like to take patch 1 through the nvdimm.git tree, with -mm
acks, along with the device-dax fixes for v4.8-rc6.  Patch 2 can go the
typical -mm route for v4.9 since it has potential to change behavior in
its DRI usages, needs soak time in -next, and there no known memtype
conflict problems it would fix.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2016-September/006781.html

---

Dan Williams (2):
      mm: fix cache mode of dax pmd mappings
      mm: fix cache mode tracking in vm_insert_mixed()


 arch/x86/mm/pat.c |   17 ++++++++++-------
 kernel/memremap.c |    9 +++++++++
 mm/memory.c       |    8 ++++++--
 3 files changed, 25 insertions(+), 9 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
