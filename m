Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0B16B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 19:27:29 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so58887003pfx.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 16:27:29 -0800 (PST)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id pp10si27866417pac.225.2016.11.07.15.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:03 -0800 (PST)
Received: by mail-pg0-x232.google.com with SMTP id f188so9081269pgc.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:03 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 00/12] mm: page migration enhancement for thp
Date: Tue,  8 Nov 2016 08:31:45 +0900
Message-Id: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hi everyone,

I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
with feedbacks for ver.1.

General description (no change since ver.1)
===========================================

This patchset enhances page migration functionality to handle thp migration
for various page migration's callers:
 - mbind(2)
 - move_pages(2)
 - migrate_pages(2)
 - cgroup/cpuset migration
 - memory hotremove
 - soft offline

The main benefit is that we can avoid unnecessary thp splits, which helps us
avoid performance decrease when your applications handles NUMA optimization on
their own.

The implementation is similar to that of normal page migration, the key point
is that we modify a pmd to a pmd migration entry in swap-entry like format.

Changes / Notes
===============

- pmd_present() in x86 checks _PAGE_PRESENT, _PAGE_PROTNONE and _PAGE_PSE
  bits together, which makes implementing thp migration a bit hard because
  _PAGE_PSE bit is currently used by soft-dirty in swap-entry format.
  I was advised to dropping _PAGE_PSE in pmd_present(), but I don't think
  of the justification, so I keep it in this version. Instead, my approach
  is to move _PAGE_SWP_SOFT_DIRTY to bit 6 (unused) and reserve bit 7 for
  pmd non-present cases.

- this patchset still covers only x86_64. Zi Yan posted a patch for ppc64
  and I think it's favorably received so that's fine. But there's unsolved
  minor suggestion by Aneesh, so I don't include it in this set, expecting
  that it will be updated/reposted.

- pte-mapped thp and doubly-mapped thp were not supported in ver.1, but
  this version should work for such kinds of thp.

- thp page cache is not tested yet, and it's at the head of my todo list
  for future version.

Any comments or advices are welcomed.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
