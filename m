Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 289F06B0387
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:28:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o3so1394834qto.15
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:28:54 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s66si378685qka.224.2017.07.17.15.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 15:28:53 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Date: Mon, 17 Jul 2017 15:27:58 -0700
Message-Id: <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <20170328175408.GD7838@bombadil.infradead.org>
References: <20170328175408.GD7838@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>

I hate to resurrect this thread, but I would like to add hugetlb support
to memfd_create.  This is for JVM garbage collection as discussed in
this thread [1].

Adding hugetlb support to memfd_create, means that memfd_create will take
a flag something like MFD_HUGETLB.  And, if a user wants hugetlb pages
they may want a huge page size different than the system default.  So, it
make sense to use the same type of encoding used by mmap and shmget.
However, I would hate to copy/paste the same values used by mmap and shmget
and just give them different names.  So, how about something like the
following:

1) Put all the log2 encoded huge page size definitions in a common header
   file.
2) Arch specific code can use these values, or overwrite as needed.
3) All system calls using this encoding (mmap, shmget and memfd_create in
   the future) will use these common values.

I have also put the shm user space definitions in the uapi file as
previously suggested by Matthew Wilcox.  I did not (yet) move the
shm definitions to arch specific files as suggested by Aneesh Kumar.

[1] https://lkml.org/lkml/2017/7/6/564

Mike Kravetz (3):
  mm:hugetlb:  Define system call hugetlb size encodings in single file
  mm: arch: Use new hugetlb size encoding definitions
  mm: shm: Use new hugetlb size encoding definitions

 arch/alpha/include/uapi/asm/mman.h        | 14 ++++++--------
 arch/mips/include/uapi/asm/mman.h         | 14 ++++++--------
 arch/parisc/include/uapi/asm/mman.h       | 14 ++++++--------
 arch/powerpc/include/uapi/asm/mman.h      | 23 ++++++++++-------------
 arch/x86/include/uapi/asm/mman.h          | 10 ++++++++--
 arch/xtensa/include/uapi/asm/mman.h       | 14 ++++++--------
 include/linux/shm.h                       | 17 -----------------
 include/uapi/asm-generic/hugetlb_encode.h | 30 ++++++++++++++++++++++++++++++
 include/uapi/asm-generic/mman-common.h    |  6 ++++--
 include/uapi/linux/shm.h                  | 23 +++++++++++++++++++++--
 10 files changed, 97 insertions(+), 68 deletions(-)
 create mode 100644 include/uapi/asm-generic/hugetlb_encode.h

-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
