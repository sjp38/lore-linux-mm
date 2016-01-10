Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id EC7BF828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 08:59:26 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id u188so186128712wmu.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 05:59:26 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id k206si14978201wmf.37.2016.01.10.05.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 05:59:25 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id f206so183475277wmf.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 05:59:25 -0800 (PST)
Message-ID: <569263BA.5060503@plexistor.com>
Date: Sun, 10 Jan 2016 15:59:22 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCHSET 0/2] Allow single pagefault in write access of a VM_MIXEDMAP
 mapping
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

Hi

Today any VM_MIXEDMAP or VM_PFN mapping when enabling a write access
to their mapping, will have a double pagefault for every write access.

This is because vma->vm_page_prot defines how a page/pfn is inserted into
the page table (see vma_wants_writenotify in mm/mmap.c).

Which means that it is always inserted with read-only under the
assumption that we want to be notified when write access occurs.

But this is not always true and adds an unnecessary page-fault on
every new mmap-write access

This patchset is trying to give the fault handler more choice by passing
an pgprot_t to vm_insert_mixed() via a new vm_insert_mixed_prot() API.

If the mm guys feel that the pgprot_t and its helpers and flags are private
to mm/memory.c I can easily do a new: vm_insert_mixed_rw() instead. of the
above vm_insert_mixed_prot() which enables any control not only write.

Following is a patch to DAX to optimize out the extra page-fault.

TODO: I only did 4k mapping perhaps 2M mapping can enjoy the same single
fault on write access. If interesting to anyone I can attempt a fix.

Dan Andrew who needs to pick this up please?

list of patches:
[PATCH 1/2] mm: Allow single pagefault on mmap-write with VM_MIXEDMAP
[PATCH 2/2] dax: Only fault once on mmap write access

Thank you
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
