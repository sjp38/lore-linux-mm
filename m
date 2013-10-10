Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 66CFF6B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:12:49 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2976085pab.4
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 09:12:49 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] initialize PG_reserved for tail pages of gigantig compound pages
Date: Thu, 10 Oct 2013 18:12:40 +0200
Message-Id: <1381421561-10203-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gleb Natapov <gleb@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Hi,

large CC list because the below patch is important to merge before
3.12 final, either that or 11feeb498086a3a5907b8148bdf1786a9b18fc55
should be reverted ASAP.

The optimization 11feeb498086a3a5907b8148bdf1786a9b18fc55 avoids
deferefencing the head page during KVM mmio vmexit, and it is a
worthwhile optimization.

However for it to work, PG_reserved must be identical between tail and
head pages of all compound pages (at least those that can end up used
as guest physical memory). That looked a safe assumption to make and
it is enforced everywhere except by the gigantic compound page
initialization code (i.e. KVM running on hugepagesz=1g didn't work as
expected).

This further patch enforces the above assumption for gigantic compound
pages too. It has been successfully verified to fix the gigantic
compound pages memory leak in combination with patch
11feeb498086a3a5907b8148bdf1786a9b18fc55.

Enforcing PG_reserved not set for tail pages of hugetlbfs gigantic
compound pages sounds safer regardless of commit
11feeb498086a3a5907b8148bdf1786a9b18fc55 to be consistent with the
other hugetlbfs page sizes (i.e hugetlbfs page order < MAX_ORDER).

Thanks,
Andrea

Andrea Arcangeli (1):
  mm: hugetlb: initialize PG_reserved for tail pages of gigantig
    compound pages

 mm/hugetlb.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
