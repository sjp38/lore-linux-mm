Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id F1DDD6B0072
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:30:49 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id em10so628321wid.13
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 01:30:49 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id ba6si1021674wib.32.2014.10.22.01.30.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 01:30:48 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 09:30:48 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id E116E17D8024
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 09:30:44 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9M8Uiun19398996
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:30:44 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9M8Ueno023800
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 02:30:44 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH v2 0/4] mm: new function to forbid zeropage mappings for a process
Date: Wed, 22 Oct 2014 10:30:20 +0200
Message-Id: <1413966624-12447-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paolo Bonzini <pbonzini@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>

s390 has the special notion of storage keys which are some sort of page flags
associated with physical pages and live outside of direct addressable memory.
These storage keys can be queried and changed with a special set of instructions.
The mentioned instructions behave quite nicely under virtualization, if there is: 
- an invalid pte, then the instructions will work on memory in the host page table
- a valid pte, then the instructions will work with the real storage key

Thanks to Martin with his software reference and dirty bit tracking,
the kernel does not issue any storage key instructions as now a 
software based approach will be taken, on the other hand distributions 
in the wild are currently using them.

However, for virtualized guests we still have a problem with guest pages 
mapped to zero pages and the kernel same page merging.  
With each one multiple guest pages will point to the same physical page
and share the same storage key.

Let's fix this by introducing a new function which s390 will define to
forbid new zero page mappings.  If the guest issues a storage key related 
instruction we flag the mm_struct, drop existing zero page mappings
and unmerge the guest memory.

v1 -> v2: 
 - Following Dave and Paolo suggestion removing the vma flag

Dominik Dingel (4):
  s390/mm: recfactor global pgste updates
  mm: introduce mm_forbids_zeropage function
  s390/mm: prevent and break zero page mappings in case of storage keys
  s390/mm: disable KSM for storage key enabled pages

 arch/s390/include/asm/mmu.h     |   2 +
 arch/s390/include/asm/pgalloc.h |   2 -
 arch/s390/include/asm/pgtable.h |  17 +++-
 arch/s390/kvm/kvm-s390.c        |   2 +-
 arch/s390/kvm/priv.c            |  17 ++--
 arch/s390/mm/pgtable.c          | 180 ++++++++++++++++++----------------------
 include/linux/mm.h              |   4 +
 mm/huge_memory.c                |   2 +-
 mm/memory.c                     |   2 +-
 9 files changed, 117 insertions(+), 111 deletions(-)

-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
