Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85EDE6B0038
	for <linux-mm@kvack.org>; Sat, 25 Feb 2017 12:13:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so76580489pfb.3
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 09:13:40 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b1si10572869pfa.254.2017.02.25.09.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Feb 2017 09:13:39 -0800 (PST)
Subject: [PATCH 0/2] fix for direct-I/O to DAX mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 25 Feb 2017 09:08:28 -0800
Message-ID: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: x86@kernel.org, Xiong Zhou <xzhou@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, torvalds@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>

Hi Andrew,

While Ross was doing a review of a new mmap+DAX direct-I/O test case for
xfstests, from Xiong, he noticed occasions where it failed to trigger a
page dirty event.  Dave then spotted the problem fixed by patch1. The
pte_devmap() check is precluding pte_allows_gup(), i.e. bypassing
permission checks and dirty tracking.

Patch2 is a cleanup and clarifies that pte_unmap() only needs to be done
once per page-worth of ptes. It unifies the exit paths similar to the
generic gup_pte_range() in the __HAVE_ARCH_PTE_SPECIAL case.

I'm sending this through the -mm tree for a double-check from memory
management folks. It has a build success notification from the kbuild
robot.

---

Dan Williams (2):
      x86, mm: fix gup_pte_range() vs DAX mappings
      x86, mm: unify exit paths in gup_pte_range()


 arch/x86/mm/gup.c |   37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
