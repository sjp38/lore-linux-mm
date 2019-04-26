Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DCD2C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:05:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C3BB20679
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:05:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="qnMrGCeJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C3BB20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B38276B000A; Fri, 26 Apr 2019 14:05:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE7DC6B000C; Fri, 26 Apr 2019 14:05:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 988796B000D; Fri, 26 Apr 2019 14:05:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58B7D6B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:05:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f64so2670842pfb.11
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:05:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=n7JQK+1gStJMtkDl7cjgWg2CcKfL8XvWY/bi/qzr9w8=;
        b=CAvQH9eP/hKd/Pg6iyfTymdpSda48jnFu+1IUFTgvL9647CdS4TasOf66vFnZzCHDo
         eCSwrEkBFaG2RxWVNEASU/RL9SpiWarr2ihU7CLGnriqC2Yh9/U6CDhwfx1QjnpTMMRC
         1xup/ctyZIJvzUoP10H9Pwg3pd3G+dzgh2Duq80zCWFGvvE9V4UJoqz+OO/0KUOTKb3M
         wEvt99R0unlfCXlwfAtNuMCOg2LJunktCQeZceReHKnGn63vfvr7ve/nlwgODAl2AGUO
         lJjx3sE7KsndY95gn8hsLa1w/my0je7FrcxcRUgK1C+/f2yu6JeFTfNEKI2mMIMt4jqc
         Q8mQ==
X-Gm-Message-State: APjAAAVbRAV7HWRlrUopDWTQ5QSY0/HsXsP4xyJBXlKujyfJDT4qHlAf
	hf8t64J71YHtjMq/yFiUNTIJF/pWFQ7rABBsSH5SSxpyT4PLvBN5VN/JNo+XhoztK8d6ArR4rD+
	+jW5Tog4+EhfzCQcH0VU2NWPkJUaar+Z4M5zxwJoLIPdJqSH9u7V+gy+Kq4h9aaHR0g==
X-Received: by 2002:aa7:8c9a:: with SMTP id p26mr49413763pfd.251.1556301924848;
        Fri, 26 Apr 2019 11:05:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziE51LhTvESyk8U9EBCb+Zawp+DjF1XwGP52Q40cflR+QkHwTLyw5GyqrLfhWJb7cjrcZQ
X-Received: by 2002:aa7:8c9a:: with SMTP id p26mr49413601pfd.251.1556301923260;
        Fri, 26 Apr 2019 11:05:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556301923; cv=none;
        d=google.com; s=arc-20160816;
        b=DQv6WGZp5Sh5txotu9NMF/ruCYLHk1yqz/XXh5js8dKEo0+QcchbMR+MFzF63SCHl1
         OTdt7QJx+aFyIZ+Tj1oJxGA3gts8NZfA+t2xae4LNwgXdRwM4ahJbLSd7TvmODgFrAuO
         XBUOyr3drfUOQUAmz8S3O/GuYnBA63HVU7dbVAtt2B/vdZ+0whjiJ/QPzht9q/lH4cOx
         pOGRs6lfJYPyuB8t+kg93xaM0cU3H+ib/4nW5W5RRdMvg4FLiHBj0psJ+K2vzZWhMku+
         E6WJIDjyTUI6Idrn4h8RfOIe6oJV16Gzi75L8AQxWuXx9DWV98ZC+WiJBvXXOm5HL2lg
         A94g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=n7JQK+1gStJMtkDl7cjgWg2CcKfL8XvWY/bi/qzr9w8=;
        b=lBM01xVQ8c5TLsb4JwogjzQEtBIz/EoXGQik0xWLvil+yNv2i7A+D19QcxdzSjwOkk
         Y9E1b53dy0McevoLclt/v0r49OtXGdM/Qc2/1ZNU+b4XgSwErAsr7rx7VDi5t8vspAPG
         wzpHuNwcEPreMuvOF/3S/nkOrIQitNQ1dhqQ0HPw4wO6/yrON7csVIOvE8oWEIp2os1z
         MiWYzHF11ScKS7xAfi3YjbSToEvCQYu3kHCVtcTR3d1QRaId18xNKdjZKV9MskwAP3BZ
         U12ILvWBb1cy2lIu2v2v/ftd+8nTqnTFY+fVBShzxbG8fmZ1sAaPNRwwgiC0j6pXbPDp
         2LKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=qnMrGCeJ;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r18si24304575pgv.212.2019.04.26.11.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 11:05:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=qnMrGCeJ;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cc348470002>; Fri, 26 Apr 2019 11:04:55 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 26 Apr 2019 11:05:22 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 26 Apr 2019 11:05:22 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Apr
 2019 18:05:22 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-doc@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, Randy
 Dunlap <rdunlap@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>,
	Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2] docs/vm: Minor editorial changes in the THP and hugetlbfs
Date: Fri, 26 Apr 2019 11:04:29 -0700
Message-ID: <20190426180429.18098-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1556301895; bh=n7JQK+1gStJMtkDl7cjgWg2CcKfL8XvWY/bi/qzr9w8=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:X-Originating-IP:
	 X-ClientProxiedBy:Content-Transfer-Encoding:Content-Type;
	b=qnMrGCeJn3DR2DW5+VMobDEu0FyIXqY2glYapZVqCljsrT8ATAcKu4ctRVRXvljxV
	 3jfR/lF8M+d81k6m7Pkv6woBBgCUwi6rKJF54qMLzvKC/OvAkMnRTCU2HHaPhtSczv
	 1lzWaN1umNmwLRA7lqK0h0sPoOGUcfpX4koDOtKUC5ec0yPpDc5usMX5ovUGTGJYch
	 1/45yL/97m4lvd3b+pREVUxL3sXMriOwiivNxqmirq67k80sxNysazYDHvRYNf55WM
	 8F8sn0Bjequ+izA52x4UlVU9w+8RId7cDcCnA/cjaaYEpu0nxLlNFV1qfvzovDPP7A
	 q59zichH60JHA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

Some minor wording changes and typo corrections.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Acked-by: Randy Dunlap <rdunlap@infradead.org>
Acked-by: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
---

Changes for v2:
 Added Acked-by for Randy and Mike.
 Rebased on mmotm 2019-04-25-16-30 (in response to Yang Shi).

 Documentation/vm/hugetlbfs_reserv.rst | 17 ++++---
 Documentation/vm/transhuge.rst        | 73 ++++++++++++++-------------
 2 files changed, 46 insertions(+), 44 deletions(-)

diff --git a/Documentation/vm/hugetlbfs_reserv.rst b/Documentation/vm/huget=
lbfs_reserv.rst
index 9d200762114f..f143954e0d05 100644
--- a/Documentation/vm/hugetlbfs_reserv.rst
+++ b/Documentation/vm/hugetlbfs_reserv.rst
@@ -85,10 +85,10 @@ Reservation Map Location (Private or Shared)
 A huge page mapping or segment is either private or shared.  If private,
 it is typically only available to a single address space (task).  If share=
d,
 it can be mapped into multiple address spaces (tasks).  The location and
-semantics of the reservation map is significantly different for two types
+semantics of the reservation map is significantly different for the two ty=
pes
 of mappings.  Location differences are:
=20
-- For private mappings, the reservation map hangs off the the VMA structur=
e.
+- For private mappings, the reservation map hangs off the VMA structure.
   Specifically, vma->vm_private_data.  This reserve map is created at the
   time the mapping (mmap(MAP_PRIVATE)) is created.
 - For shared mappings, the reservation map hangs off the inode.  Specifica=
lly,
@@ -109,15 +109,15 @@ These operations result in a call to the routine huge=
tlb_reserve_pages()::
 				  struct vm_area_struct *vma,
 				  vm_flags_t vm_flags)
=20
-The first thing hugetlb_reserve_pages() does is check for the NORESERVE
+The first thing hugetlb_reserve_pages() does is check if the NORESERVE
 flag was specified in either the shmget() or mmap() call.  If NORESERVE
-was specified, then this routine returns immediately as no reservation
+was specified, then this routine returns immediately as no reservations
 are desired.
=20
 The arguments 'from' and 'to' are huge page indices into the mapping or
 underlying file.  For shmget(), 'from' is always 0 and 'to' corresponds to
 the length of the segment/mapping.  For mmap(), the offset argument could
-be used to specify the offset into the underlying file.  In such a case
+be used to specify the offset into the underlying file.  In such a case,
 the 'from' and 'to' arguments have been adjusted by this offset.
=20
 One of the big differences between PRIVATE and SHARED mappings is the way
@@ -138,7 +138,8 @@ to indicate this VMA owns the reservations.
=20
 The reservation map is consulted to determine how many huge page reservati=
ons
 are needed for the current mapping/segment.  For private mappings, this is
-always the value (to - from).  However, for shared mappings it is possible=
 that some reservations may already exist within the range (to - from).  Se=
e the
+always the value (to - from).  However, for shared mappings it is possible=
 that
+some reservations may already exist within the range (to - from).  See the
 section :ref:`Reservation Map Modifications <resv_map_modifications>`
 for details on how this is accomplished.
=20
@@ -165,7 +166,7 @@ these counters.
 If there were enough free huge pages and the global count resv_huge_pages
 was adjusted, then the reservation map associated with the mapping is
 modified to reflect the reservations.  In the case of a shared mapping, a
-file_region will exist that includes the range 'from' 'to'.  For private
+file_region will exist that includes the range 'from' - 'to'.  For private
 mappings, no modifications are made to the reservation map as lack of an
 entry indicates a reservation exists.
=20
@@ -239,7 +240,7 @@ subpool accounting when the page is freed.
 The routine vma_commit_reservation() is then called to adjust the reserve
 map based on the consumption of the reservation.  In general, this involve=
s
 ensuring the page is represented within a file_region structure of the reg=
ion
-map.  For shared mappings where the the reservation was present, an entry
+map.  For shared mappings where the reservation was present, an entry
 in the reserve map already existed so no change is made.  However, if ther=
e
 was no reservation in a shared mapping or this was a private mapping a new
 entry must be created.
diff --git a/Documentation/vm/transhuge.rst b/Documentation/vm/transhuge.rs=
t
index 8df380657430..37c57ca32629 100644
--- a/Documentation/vm/transhuge.rst
+++ b/Documentation/vm/transhuge.rst
@@ -4,8 +4,9 @@
 Transparent Hugepage Support
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
=20
-This document describes design principles Transparent Hugepage (THP)
-Support and its interaction with other parts of the memory management.
+This document describes design principles for Transparent Hugepage (THP)
+support and its interaction with other parts of the memory management
+system.
=20
 Design principles
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
@@ -37,23 +38,23 @@ get_user_pages and follow_page
=20
 get_user_pages and follow_page if run on a hugepage, will return the
 head or tail pages as usual (exactly as they would do on
-hugetlbfs). Most gup users will only care about the actual physical
+hugetlbfs). Most GUP users will only care about the actual physical
 address of the page and its temporary pinning to release after the I/O
 is complete, so they won't ever notice the fact the page is huge. But
 if any driver is going to mangle over the page structure of the tail
 page (like for checking page->mapping or other bits that are relevant
 for the head page and not the tail page), it should be updated to jump
-to check head page instead. Taking reference on any head/tail page would
-prevent page from being split by anyone.
+to check head page instead. Taking a reference on any head/tail page would
+prevent the page from being split by anyone.
=20
 .. note::
    these aren't new constraints to the GUP API, and they match the
-   same constrains that applies to hugetlbfs too, so any driver capable
+   same constraints that apply to hugetlbfs too, so any driver capable
    of handling GUP on hugetlbfs will also work fine on transparent
    hugepage backed mappings.
=20
 In case you can't handle compound pages if they're returned by
-follow_page, the FOLL_SPLIT bit can be specified as parameter to
+follow_page, the FOLL_SPLIT bit can be specified as a parameter to
 follow_page, so that it will split the hugepages before returning
 them.
=20
@@ -66,11 +67,11 @@ pmd_offset. It's trivial to make the code transparent h=
ugepage aware
 by just grepping for "pmd_offset" and adding split_huge_pmd where
 missing after pmd_offset returns the pmd. Thanks to the graceful
 fallback design, with a one liner change, you can avoid to write
-hundred if not thousand of lines of complex code to make your code
+hundreds if not thousands of lines of complex code to make your code
 hugepage aware.
=20
 If you're not walking pagetables but you run into a physical hugepage
-but you can't handle it natively in your code, you can split it by
+that you can't handle natively in your code, you can split it by
 calling split_huge_page(page). This is what the Linux VM does before
 it tries to swapout the hugepage for example. split_huge_page() can fail
 if the page is pinned and you must handle this correctly.
@@ -97,18 +98,18 @@ split_huge_page() or split_huge_pmd() has a cost.
=20
 To make pagetable walks huge pmd aware, all you need to do is to call
 pmd_trans_huge() on the pmd returned by pmd_offset. You must hold the
-mmap_sem in read (or write) mode to be sure an huge pmd cannot be
+mmap_sem in read (or write) mode to be sure a huge pmd cannot be
 created from under you by khugepaged (khugepaged collapse_huge_page
 takes the mmap_sem in write mode in addition to the anon_vma lock). If
 pmd_trans_huge returns false, you just fallback in the old code
 paths. If instead pmd_trans_huge returns true, you have to take the
 page table lock (pmd_lock()) and re-run pmd_trans_huge. Taking the
-page table lock will prevent the huge pmd to be converted into a
+page table lock will prevent the huge pmd being converted into a
 regular pmd from under you (split_huge_pmd can run in parallel to the
 pagetable walk). If the second pmd_trans_huge returns false, you
 should just drop the page table lock and fallback to the old code as
-before. Otherwise you can proceed to process the huge pmd and the
-hugepage natively. Once finished you can drop the page table lock.
+before. Otherwise, you can proceed to process the huge pmd and the
+hugepage natively. Once finished, you can drop the page table lock.
=20
 Refcounts and transparent huge pages
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
@@ -116,61 +117,61 @@ Refcounts and transparent huge pages
 Refcounting on THP is mostly consistent with refcounting on other compound
 pages:
=20
-  - get_page()/put_page() and GUP operate in head page's ->_refcount.
+  - get_page()/put_page() and GUP operate on head page's ->_refcount.
=20
   - ->_refcount in tail pages is always zero: get_page_unless_zero() never
-    succeed on tail pages.
+    succeeds on tail pages.
=20
   - map/unmap of the pages with PTE entry increment/decrement ->_mapcount
     on relevant sub-page of the compound page.
=20
-  - map/unmap of the whole compound page accounted in compound_mapcount
+  - map/unmap of the whole compound page is accounted for in compound_mapc=
ount
     (stored in first tail page). For file huge pages, we also increment
     ->_mapcount of all sub-pages in order to have race-free detection of
     last unmap of subpages.
=20
 PageDoubleMap() indicates that the page is *possibly* mapped with PTEs.
=20
-For anonymous pages PageDoubleMap() also indicates ->_mapcount in all
+For anonymous pages, PageDoubleMap() also indicates ->_mapcount in all
 subpages is offset up by one. This additional reference is required to
 get race-free detection of unmap of subpages when we have them mapped with
 both PMDs and PTEs.
=20
-This is optimization required to lower overhead of per-subpage mapcount
-tracking. The alternative is alter ->_mapcount in all subpages on each
+This optimization is required to lower the overhead of per-subpage mapcoun=
t
+tracking. The alternative is to alter ->_mapcount in all subpages on each
 map/unmap of the whole compound page.
=20
-For anonymous pages, we set PG_double_map when a PMD of the page got split
-for the first time, but still have PMD mapping. The additional references
-go away with last compound_mapcount.
+For anonymous pages, we set PG_double_map when a PMD of the page is split
+for the first time, but still have a PMD mapping. The additional reference=
s
+go away with the last compound_mapcount.
=20
-File pages get PG_double_map set on first map of the page with PTE and
-goes away when the page gets evicted from page cache.
+File pages get PG_double_map set on the first map of the page with PTE and
+goes away when the page gets evicted from the page cache.
=20
 split_huge_page internally has to distribute the refcounts in the head
 page to the tail pages before clearing all PG_head/tail bits from the page
 structures. It can be done easily for refcounts taken by page table
-entries. But we don't have enough information on how to distribute any
+entries, but we don't have enough information on how to distribute any
 additional pins (i.e. from get_user_pages). split_huge_page() fails any
-requests to split pinned huge page: it expects page count to be equal to
-sum of mapcount of all sub-pages plus one (split_huge_page caller must
-have reference for head page).
+requests to split pinned huge pages: it expects page count to be equal to
+the sum of mapcount of all sub-pages plus one (split_huge_page caller must
+have a reference to the head page).
=20
 split_huge_page uses migration entries to stabilize page->_refcount and
-page->_mapcount of anonymous pages. File pages just got unmapped.
+page->_mapcount of anonymous pages. File pages just get unmapped.
=20
-We safe against physical memory scanners too: the only legitimate way
-scanner can get reference to a page is get_page_unless_zero().
+We are safe against physical memory scanners too: the only legitimate way
+a scanner can get a reference to a page is get_page_unless_zero().
=20
 All tail pages have zero ->_refcount until atomic_add(). This prevents the
 scanner from getting a reference to the tail page up to that point. After =
the
-atomic_add() we don't care about the ->_refcount value. We already known h=
ow
+atomic_add() we don't care about the ->_refcount value. We already know ho=
w
 many references should be uncharged from the head page.
=20
 For head page get_page_unless_zero() will succeed and we don't mind. It's
-clear where reference should go after split: it will stay on head page.
+clear where references should go after split: it will stay on the head pag=
e.
=20
-Note that split_huge_pmd() doesn't have any limitation on refcounting:
+Note that split_huge_pmd() doesn't have any limitations on refcounting:
 pmd can be split at any point and never fails.
=20
 Partial unmap and deferred_split_huge_page()
@@ -182,10 +183,10 @@ in page_remove_rmap() and queue the THP for splitting=
 if memory pressure
 comes. Splitting will free up unused subpages.
=20
 Splitting the page right away is not an option due to locking context in
-the place where we can detect partial unmap. It's also might be
+the place where we can detect partial unmap. It also might be
 counterproductive since in many cases partial unmap happens during exit(2)=
 if
 a THP crosses a VMA boundary.
=20
-Function deferred_split_huge_page() is used to queue page for splitting.
+The function deferred_split_huge_page() is used to queue a page for splitt=
ing.
 The splitting itself will happen when we get memory pressure via shrinker
 interface.
--=20
2.20.1

