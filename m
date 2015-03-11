Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3017E90002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 05:06:16 -0400 (EDT)
Received: by padfa1 with SMTP id fa1so9851914pad.3
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 02:06:15 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id f10si5587042pas.26.2015.03.11.02.06.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 02:06:14 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 11 Mar 2015 17:05:46 +0800
Subject: [RFC ] mm: don't ignore file map pages for madvise_free( )
Message-ID: <35FD53F367049845BC99AC72306C23D10458D6173C0B@CNBJMBX05.corpusers.net>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1426036838-18154-3-git-send-email-minchan@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>

Hi

I just want to explain my ideas about file map pages for madvise_free() sys=
call.
As the following patch,
For file map vma, there is 2 types:
1. private file map
	In this type, the pages of this vma are file map pages or anon page (when =
COW happened),
2. shared file map
	In this type, the pages of this vma are all file map pages.

No matter which type file map,
We can handle file map vma as the following:
If the page is file map pages,
We just clear its pte young bit(pte_mkold()),
This will have some advantages, it will make page
Reclaim path move this file map page into inactive
lru list aggressively.

If the page is anon map page, we just handle it in the
Same way as for the pages in anon vma.


---

diff --git a/mm/madvise.c b/mm/madvise.c
index 6d0fcb8..8fdc82f 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -322,7 +322,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned =
long addr,
                ptent =3D ptep_get_and_clear_full(mm, addr, pte,
                                                tlb->fullmm);
                ptent =3D pte_mkold(ptent);
-               ptent =3D pte_mkclean(ptent);
+               if (PageAnon(page))
+                       ptent =3D pte_mkclean(ptent);
                set_pte_at(mm, addr, pte, ptent);
                tlb_remove_tlb_entry(tlb, pte, addr);
        }
@@ -364,10 +365,6 @@ static int madvise_free_single_vma(struct vm_area_stru=
ct *vma,
        if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
                return -EINVAL;

-       /* MADV_FREE works for only anon vma at the moment */
-       if (vma->vm_file)
-               return -EINVAL;
-
        start =3D max(vma->vm_start, start_addr);
        if (start >=3D vma->vm_end)
                return -EINVAL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
