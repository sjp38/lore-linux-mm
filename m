Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC944403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 10:34:05 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id r129so31879204wmr.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 07:34:05 -0800 (PST)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id pp7si24838840wjc.122.2016.02.05.07.34.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 07:34:04 -0800 (PST)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 5 Feb 2016 15:34:03 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id DFF6517D8063
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 15:34:14 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u15FY2Gh8716740
	for <linux-mm@kvack.org>; Fri, 5 Feb 2016 15:34:02 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u15FY0ft015936
	for <linux-mm@kvack.org>; Fri, 5 Feb 2016 08:34:01 -0700
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH RFC 0/1] numa: fix /proc/<pid>/numa_maps for THP
Date: Fri,  5 Feb 2016 16:33:59 +0100
Message-Id: <1454686440-31218-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>

In gather_pte_stats() a THP pmd is cast into a pte, which is wrong because the
layouts may differ depending on the architecture. On s390 this will lead to
inaccurate numap_maps accounting in /proc because of misguided pte_present()
and pte_dirty() checks on the fake pte.

On other architectures pte_present() and pte_dirty() may work by chance, but
there will be an issue with direct-access (dax) mappings w/o underlying struct
pages when HAVE_PTE_SPECIAL is set and THP is available. In vm_normal_page()
the fake pte will be checked with pte_special() and because there is no
"special" bit in a pmd, this will always return false and the VM_PFNMAP |
VM_MIXEDMAP checking will be skipped. On dax mappings w/o struct pages, an
invalid struct page pointer will then be returned that can crash the kernel.

This crash may be a theoretical issue so far, the RAM block device driver
seems to be safe as there should be struct pages present. Not sure about the
axonram or nvdimm (putting Maintainers on cc), but the dcssblk on s390 is safe
until there will be large page support in z/VM.

This patch fixes the numa_maps THP handling by introducing new "_pmd" variants
of the can_gather_numa_stats() and vm_normal_page() functions.

Any thoughts?

Gerald Schaefer (1):
  numa: fix /proc/<pid>/numa_maps for THP

 fs/proc/task_mmu.c | 29 ++++++++++++++++++++++++++---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 3 deletions(-)

-- 
2.3.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
