Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFD636B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:41:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id c14so186551168pgn.11
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:41:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p2si8817860pli.415.2017.07.25.08.41.28
        for <linux-mm@kvack.org>;
        Tue, 25 Jul 2017 08:41:28 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH 0/1] Clarify huge_pte_offset() semantics
Date: Tue, 25 Jul 2017 16:41:13 +0100
Message-Id: <20170725154114.24131-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Punit Agrawal <punit.agrawal@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hi,

The following patch is an attempt to make huge_pte_offset() consistent
when dealing with different levels of the page table and document the
expected semantics. Previously posting can be found at [0].

Changelog

RFC - v1
* Merge Patch 1 and 2 - preserve bisectability
* Drop RFC tag

Original cover letter follows...

The generic implementation of huge_pte_offset() has inconsistent
behaviour when looking up hugepage PUDs vs PMDs entries that are not
present (returning NULL vs pte_t*).

Similarly, it returns NULL when encountering swap entries although all
the callers have special checks to properly deal with swap entries.

Without clear semantics, it is difficult to determine if a change
breaks huge_pte_offset() without going through all the scenarios where
it is used.

I faced this recently when updating the arm64 implementation of
huge_pte_offset() to handle swap entries (related to enabling poisoned
memeory)[1]. And will come across again when I update it for
contiguous hugepage support now that core changes have been merged.

To address these issues, this following patch -

* makes huge_pte_offset() consistent between PUD and PMDs
* and, documents the expected behaviour of huge_pte_offset()

All feedback welcome.

Thanks,
Punit

[0] https://lkml.org/lkml/2017/7/24/514
[1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f02ab08afbe76ee7b0b2a34a9970e7dd200d8b01

Punit Agrawal (1):
  mm/hugetlb: Make huge_pte_offset() consistent and document behaviour

 mm/hugetlb.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
