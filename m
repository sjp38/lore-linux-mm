Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3291428024D
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:37:39 -0400 (EDT)
Received: by lagx9 with SMTP id x9so8421930lag.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:37:38 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id t18si1228949laz.137.2015.07.14.08.37.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 08:37:37 -0700 (PDT)
Subject: [PATCHSET v4 0/5] pagemap: make useable for non-privilege users
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 14 Jul 2015 18:37:34 +0300
Message-ID: <20150714152516.29844.69929.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

This patchset makes pagemap useable again in the safe way (after row hammer
bug it was made CAP_SYS_ADMIN-only). This patchset restores access for
non-privileged users but hides PFNs from them.

Also it adds bit 'map-exlusive' which is set if page is mapped only here:
it helps in estimation of working set without exposing pfns and allows to
distinguish CoWed and non-CoWed private anonymous pages.

Second patch removes page-shift bits and completes migration to the new
pagemap format: flags soft-dirty and mmap-exlusive are available only
in the new format.

Changes since v3:
* patches reordered: cleanup now in second patch
* update pagemap for hugetlb, add missing 'FILE' bit
* fix PM_PFRAME_BITS: its 55 not 54 as was in previous versions

---

Konstantin Khlebnikov (5):
      pagemap: check permissions and capabilities at open time
      pagemap: switch to the new format and do some cleanup
      pagemap: rework hugetlb and thp report
      pagemap: hide physical addresses from non-privileged users
      pagemap: add mmap-exclusive bit for marking pages mapped only here


 Documentation/vm/pagemap.txt |    3 
 fs/proc/task_mmu.c           |  267 ++++++++++++++++++------------------------
 tools/vm/page-types.c        |   35 +++---
 3 files changed, 137 insertions(+), 168 deletions(-)

--
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
