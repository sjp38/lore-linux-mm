Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id BC5996B0073
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 09:05:30 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so14670839wib.10
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 06:05:29 -0800 (PST)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id 8si2214449wjx.166.2014.12.11.06.05.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Dec 2014 06:05:29 -0800 (PST)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 11 Dec 2014 14:05:28 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id B9A3D17D8042
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 14:05:48 +0000 (GMT)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sBBE5Q8n51118278
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 14:05:26 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sBBE5NwM010358
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 07:05:25 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCHv5 0/8]  ACCESS_ONCE and non-scalar accesses
Date: Thu, 11 Dec 2014 15:05:03 +0100
Message-Id: <1418306712-17245-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org, George Spelvin <linux@horizon.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org

As discussed on LKML http://marc.info/?i=54611D86.4040306%40de.ibm.com
ACCESS_ONCE might fail with specific compilers for non-scalar accesses.

Here is a set of patches to tackle that problem.

The first patch introduce READ_ONCE and ASSIGN_ONCE. If the data structure
is larger than the machine word size memcpy is used and a warning is emitted.
The next patches fix up all in-tree users of ACCESS_ONCE on non-scalar types.

Due to all the trouble when dealing with linux-next, I will defer the patch
that forces ACCESS_ONCE to work only on scalar types after rc1 to give it
a full spin in linux-next.

If nobody complains I will ask Linus to pull this for 3.19 next week.
The tree can be found at 

git://git.kernel.org/pub/scm/linux/kernel/git/borntraeger/linux.git linux-next

Changelog:
v4->v5:
1. READ_ONCE/ASSIGN_ONCE use x instead of p
2. linux/types.h --> uapi/linux/types.h u??-->__u?? to avoid header
   inclusion fun and compile errors
3. Actually provide data_access_exceeds_word_size.
4. also move handle_pte_fault to a barrier as there is ppc44x which has
   64bit ptes and 32bit word size. Some sanity check from a VM person
   would be good.

Cc: linux-mm@kvack.org

Christian Borntraeger (8):
  kernel: Provide READ_ONCE and ASSIGN_ONCE
  mm: replace ACCESS_ONCE with READ_ONCE or barriers
  x86/spinlock: Replace ACCESS_ONCE with READ_ONCE
  x86/gup: Replace ACCESS_ONCE with READ_ONCE
  mips/gup: Replace ACCESS_ONCE with READ_ONCE
  arm64/spinlock: Replace ACCESS_ONCE READ_ONCE
  arm/spinlock: Replace ACCESS_ONCE with READ_ONCE
  s390/kvm: REPLACE barrier fixup with READ_ONCE

 arch/arm/include/asm/spinlock.h   |  4 +--
 arch/arm64/include/asm/spinlock.h |  4 +--
 arch/mips/mm/gup.c                |  2 +-
 arch/s390/kvm/gaccess.c           | 18 ++++------
 arch/x86/include/asm/spinlock.h   |  8 ++---
 arch/x86/mm/gup.c                 |  2 +-
 include/linux/compiler.h          | 70 +++++++++++++++++++++++++++++++++++++++
 lib/Makefile                      |  2 +-
 lib/access.c                      |  8 +++++
 mm/gup.c                          |  2 +-
 mm/memory.c                       | 11 +++++-
 mm/rmap.c                         |  3 +-
 12 files changed, 108 insertions(+), 26 deletions(-)
 create mode 100644 lib/access.c

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
