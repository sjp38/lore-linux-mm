Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 090E56B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 19:56:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p5so30401562pgn.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 16:56:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e64si113133pfm.545.2017.09.27.16.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 16:56:03 -0700 (PDT)
Subject: [PATCH 0/3] dax: require 'struct page' and other fixups
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 27 Sep 2017 16:49:38 -0700
Message-ID: <150655617774.700.5326522538400299973.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Prompted by a recent change to add more protection around setting up
'vm_flags' for a dax vma [1], rework the implementation to remove the
requirement to set VM_MIXEDMAP and VM_HUGEPAGE.

VM_MIXEDMAP is used by dax to direct mm paths like vm_normal_page() that
the memory page it is dealing with is not typical memory from the linear
map. The get_user_pages_fast() path, since it does not resolve the vma,
is already using {pte,pmd}_devmap() as a stand-in for VM_MIXEDMAP, so we
use that as a VM_MIXEDMAP replacement in some locations. In the cases
where there is no pte to consult we fallback to using vma_is_dax() to
detect the VM_MIXEDMAP special case.

This patch series passes a run of the ndctl unit test suite and the
'mmap.sh' [2] test in particular. 'mmap.sh' tries to catch dependencies
on VM_MIXEDMAP and {pte,pmd}_devmap().

[1]: https://lkml.org/lkml/2017/9/25/638
[2]: https://github.com/pmem/ndctl/blob/master/test/mmap.sh

---

Dan Williams (3):
      dax: disable filesystem dax on devices that do not map pages
      dax: stop using VM_MIXEDMAP for dax
      dax: stop using VM_HUGEPAGE for dax


 drivers/dax/device.c |    1 -
 drivers/dax/super.c  |    7 +++++++
 fs/ext2/file.c       |    1 -
 fs/ext4/file.c       |    1 -
 fs/xfs/xfs_file.c    |    2 --
 mm/huge_memory.c     |    8 ++++----
 mm/ksm.c             |    3 +++
 mm/madvise.c         |    2 +-
 mm/memory.c          |   20 ++++++++++++++++++--
 mm/migrate.c         |    3 ++-
 mm/mlock.c           |    3 ++-
 mm/mmap.c            |    5 +++--
 12 files changed, 40 insertions(+), 16 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
