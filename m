Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5B848E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 19:51:24 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f125so5222066pgc.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 16:51:24 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n3si18316322pld.36.2019.01.09.16.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 16:51:23 -0800 (PST)
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [PATCH] mm/mmu_notifier: mm/rmap.c: Fix a mmu_notifier range bug in try_to_unmap_one
Date: Wed,  9 Jan 2019 16:51:17 -0800
Message-Id: <20190110005117.18282-1-sean.j.christopherson@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, leozinho29_eu@hotmail.com, Mike Galbraith <efault@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

The conversion to use a structure for mmu_notifier_invalidate_range_*()
unintentionally changed the usage in try_to_unmap_one() to init the
'struct mmu_notifier_range' with vma->vm_start instead of @address,
i.e. it invalidates the wrong address range.  Revert to the correct
address range.

Manifests as KVM use-after-free WARNINGs and subsequent "BUG: Bad page
state in process X" errors when reclaiming from a KVM guest due to KVM
removing the wrong pages from its own mappings.

Reported-by: leozinho29_eu@hotmail.com
Reported-by: Mike Galbraith <efault@gmx.de>
Reported-by: Adam Borowski <kilobyte@angband.pl>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Felix Kuehling <felix.kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
---

FWIW, I looked through all other calls to mmu_notifier_range_init() in
the patch and didn't spot any other unintentional functional changes.

 mm/rmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 68a1a5b869a5..0454ecc29537 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1371,8 +1371,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 * Note that the page can not be free in this function as call of
 	 * try_to_unmap() must hold a reference on the page.
 	 */
-	mmu_notifier_range_init(&range, vma->vm_mm, vma->vm_start,
-				min(vma->vm_end, vma->vm_start +
+	mmu_notifier_range_init(&range, vma->vm_mm, address,
+				min(vma->vm_end, address +
 				    (PAGE_SIZE << compound_order(page))));
 	if (PageHuge(page)) {
 		/*
-- 
2.19.2
