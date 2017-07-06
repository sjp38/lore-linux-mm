Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDD96B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 12:17:45 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id c13so5020600ywa.13
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:17:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id k189si111016ybb.127.2017.07.06.09.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 09:17:44 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 0/1] mm/mremap: add MREMAP_MIRROR flag
Date: Thu,  6 Jul 2017 09:17:25 -0700
Message-Id: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

The mremap system call has the ability to 'mirror' parts of an existing
mapping.  To do so, it creates a new mapping that maps the same pages as
the original mapping, just at a different virtual address.  This
functionality has existed since at least the 2.6 kernel [1].  A comment
was added to the code to help preserve this feature.

The Oracle JVM team has discovered this feature and used it while
prototyping a new garbage collection model.  This new model shows promise,
and they are considering its use in a future release.  However, since
the only mention of this functionality is a single comment in the kernel,
they are concerned about its future.

I propose the addition of a new MREMAP_MIRROR flag to explicitly request
this functionality.  The flag simply provides the same functionality as
the existing undocumented 'old_size == 0' interface.  As an alternative,
we could simply document the 'old_size == 0' interface in the man page.
In either case, man page modifications would be needed.

Future Direction

After more formally adding this to the API (either new flag or documenting
existing interface), the mremap code could be enhanced to optimize this
case.  Currently, 'mirroring' only sets up the new mapping.  It does not
create page table entries for new mapping.  This could be added as an
enhancement.

The JVM today has the option of using (static) huge pages.  The mremap
system call does not fully support huge page mappings today.  You can
use mremap to shrink the size of a huge page mapping, but it can not be
used to expand or mirror a mapping.  Such support is fairly straight
forward.

[1] https://lkml.org/lkml/2004/1/12/260

Mike Kravetz (1):
  mm/mremap: add MREMAP_MIRROR flag for existing mirroring functionality

 include/uapi/linux/mman.h       |  5 +++--
 mm/mremap.c                     | 23 ++++++++++++++++-------
 tools/include/uapi/linux/mman.h |  5 +++--
 3 files changed, 22 insertions(+), 11 deletions(-)

-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
