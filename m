Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id ABE856B006C
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 10:10:10 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hi2so1356610wib.14
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 07:10:10 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id fb15si2022094wid.76.2014.10.17.07.10.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Oct 2014 07:10:09 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 17 Oct 2014 15:10:08 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7F3E717D8043
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 15:12:23 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9HEA6pg54591508
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 14:10:06 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9HEA4B0015001
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 08:10:05 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 0/4] mm: new flag to forbid zero page mappings for a vma
Date: Fri, 17 Oct 2014 16:09:46 +0200
Message-Id: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>

s390 has the special notion of storage keys which are some sort of page flags
associated with physical pages and live outside of direct addressable memory.
These storage keys can be queried and changed with a special set of instructions.
The mentioned instructions behave quite nicely under virtualization, if there is: 
- an invalid pte, then the instructions will work on some memory reserved in the host page table
- a valid pte, then the instructions will work with the real storage key

Thanks to Martin with his software reference and dirty bit tracking, the kernel does not issue any 
storage key instructions as now a software based approach will be taken, on the other hand 
distributions in the wild are currently using them.

However, for virtualized guests we still have a problem with guest pages mapped to zero pages
and the kernel same page merging.  WIth each one multiple guest pages will point to the same 
physical page and share the same storage key.

Let's fix this by introducing a new flag which will forbid new zero page mappings.
If the guest issues a storage key related instruction we flag all vmas and drop existing 
zero page mappings and unmerge the guest memory.

Dominik Dingel (4):
  s390/mm: recfactor global pgste updates
  mm: introduce new VM_NOZEROPAGE flag
  s390/mm: prevent and break zero page mappings in case of storage keys
  s390/mm: disable KSM for storage key enabled pages

 arch/s390/Kconfig               |   3 +
 arch/s390/include/asm/pgalloc.h |   2 -
 arch/s390/include/asm/pgtable.h |   3 +-
 arch/s390/kvm/kvm-s390.c        |   2 +-
 arch/s390/kvm/priv.c            |  17 ++--
 arch/s390/mm/pgtable.c          | 181 ++++++++++++++++++----------------------
 include/linux/mm.h              |  13 ++-
 mm/huge_memory.c                |   2 +-
 mm/memory.c                     |   2 +-
 9 files changed, 112 insertions(+), 113 deletions(-)

-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
