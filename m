Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E99DC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7392F205ED
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:38:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kGmqcWpa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7392F205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D04356B0003; Thu, 25 Apr 2019 15:38:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C65A56B0005; Thu, 25 Apr 2019 15:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2D7D6B0006; Thu, 25 Apr 2019 15:38:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5C76B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:38:15 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z34so770637qtz.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=65+EeC4tS8cAFy11ft1adrEZ58aT2BxNRsC3nbrN428=;
        b=BYl6SqnhPmam+OcnVQ0WRrRfqVqyUZ4Mm3cZH8tcfFUlfStijMWoF7mhjUSNzDR6BV
         VXgiriOZ/2sIVSviPIJBlpqShpSkiZpXESqIezPFkSXBddQLEA9CVY2AsA5Sc+jezMR+
         byfI0oNOuY0QuhR9OtK0wk8IPMWYe8ZBJgj4j7EBPlVXxHIeeKur875x2MTN/iBF4iJ8
         4q2xVQIepmMjXHAXL1gnhMtOjR+mWAnLLQ2XMVzOF57BJUGbao5Nz5f744AVuGk772hN
         3Rpm8/L1RZjJV/ThTUg80tY2KoP9v1LA0W/krbvz83TjE2iHD/6EWCU1tT83WyVLR4zZ
         w14A==
X-Gm-Message-State: APjAAAUmEhZsBToQ46bR0MGA9co0ivB3PaPtCI1iSImE/dCjm1ZILp3Z
	xwWfy5ei9PVt7CpZzukgTixZtWLUnPfrGyMzpTYrOCUiwDmc3eb9jN3WLtagDlRjo22r1Gzn7Kb
	QXzVjEtxk5AljJ1uJjYRvwhLTCjM3etjF3KKl4XuaoAb1sgV/xRyJMAevfXFQ7oS1kw==
X-Received: by 2002:a0c:b141:: with SMTP id r1mr31259169qvc.177.1556221095255;
        Thu, 25 Apr 2019 12:38:15 -0700 (PDT)
X-Received: by 2002:a0c:b141:: with SMTP id r1mr31259111qvc.177.1556221094218;
        Thu, 25 Apr 2019 12:38:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556221094; cv=none;
        d=google.com; s=arc-20160816;
        b=Q1imPhXDbsn9ffHAqoe3jSSoH05KBqmZfOAZSQh+r5xmHa+KUwFO9YBr4BuqXJUb9b
         t0oNNzOV7q4GC7JyMU3sy1jtgic91sSucqE2VSm7C0jROSwMLCy72JyOfvj+OWbQfMmQ
         yJHe3B6x1GuumlomgvFB6gI4OEsNP1PrLxKECdlVFWKP9dea+hdwLo26I+n4PH3JgmIY
         GcfKEczMVS9sfgTifcvAGNDKNw/RgkvG/5yfpD5iLd/owbvyQToakMudMs1t6vLZR5kf
         G5/UqLx39o6oMrjieT+f5dkXvwCfA/ExyxkNYMeFY/XqRxVt1q5LxHcRyIQQSSjDCHbg
         MwZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=65+EeC4tS8cAFy11ft1adrEZ58aT2BxNRsC3nbrN428=;
        b=kWk3jFbciq/PLeohR7s0GOIJgN7ECsionkBrkApC6XQz4sc+SeN+mtwfLdnroudA7z
         If+G08nh7hCwrLBNZSufSLklVbM5fS6KDfYI8j5oemDVkdqJuHFmYyuoCvUqO2KyA7ug
         SO2bfPTpwAlMLm4hmHlAT5m79hbpa7r3ImyEHwcoxQQ/XCH+V9eVqpDEqvmPxzok90yY
         OjAz3zG1K35n/fdu4NeYyKlkYBX4RiOPGlF0Epc9prp61lz4V0pqQAAfyQlSu+qpidPb
         dw4OQhrTb1noKXVuoxfnMawwCajejXAW7p9M1klKJtq+J2pWZOgvQ/ovMb9DEkMXPCzh
         MAuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kGmqcWpa;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor13810927qkj.122.2019.04.25.12.38.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 12:38:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kGmqcWpa;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=65+EeC4tS8cAFy11ft1adrEZ58aT2BxNRsC3nbrN428=;
        b=kGmqcWpafIn6yg46u9ahMMq7Tg7ZuR0roqYJwP+aSGwA2XUsu2n/NYgK1OSDYVyQgp
         QQw7GDceBGMVoexfRGK7uembJvSG/jY3QKutzvH6kL838mtYOVVUI+QR2z3ptOuk9YMM
         AuITqEeIiK2JJiljDLtFHJqcCRBEUaHFLqjO0YfNzPiC0ZnXIB0N15Au3CAef9zXtJd5
         pUVWdIFC8Q8Y2X69SyEeauT1nv4/NdHR6kwYYAFFfHeJKDdELYWShWez/GbDuxMRmkCi
         LbcLoMcGd99cRFVUQwkaN/lwm7THeCXLk2jTG+6oBoPxHUOIDbTCzZx8hZNBc6keGuw/
         qgXA==
X-Google-Smtp-Source: APXvYqxJWnKbmPyafzaSVSOZH5fQrArntJiEUQp5Ikfbkpo7lSyVmM7W4Ij9PygzzAd8my/RAoxhGxKbSBdueY27wnk=
X-Received: by 2002:a37:7dc2:: with SMTP id y185mr29994451qkc.166.1556221093917;
 Thu, 25 Apr 2019 12:38:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190425190426.10051-1-rcampbell@nvidia.com>
In-Reply-To: <20190425190426.10051-1-rcampbell@nvidia.com>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 25 Apr 2019 12:38:02 -0700
Message-ID: <CAHbLzkojmk73xsHXtteiMif5_=Cqo13M1HeQedyuV4MTCEEk+Q@mail.gmail.com>
Subject: Re: [PATCH] docs/vm: Minor editorial changes in the THP and hugetlbfs documentation.
To: rcampbell@nvidia.com
Cc: Linux MM <linux-mm@kvack.org>, linux-doc@vger.kernel.org, 
	Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Mike Kravetz <mike.kravetz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 12:05 PM <rcampbell@nvidia.com> wrote:
>
> From: Ralph Campbell <rcampbell@nvidia.com>
>
> Some minor wording changes and typo corrections.
>
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  Documentation/vm/hugetlbfs_reserv.rst | 17 +++---
>  Documentation/vm/transhuge.rst        | 77 ++++++++++++++-------------
>  2 files changed, 48 insertions(+), 46 deletions(-)
>
> diff --git a/Documentation/vm/hugetlbfs_reserv.rst b/Documentation/vm/hugetlbfs_reserv.rst
> index 9d200762114f..f143954e0d05 100644
> --- a/Documentation/vm/hugetlbfs_reserv.rst
> +++ b/Documentation/vm/hugetlbfs_reserv.rst
> @@ -85,10 +85,10 @@ Reservation Map Location (Private or Shared)
>  A huge page mapping or segment is either private or shared.  If private,
>  it is typically only available to a single address space (task).  If shared,
>  it can be mapped into multiple address spaces (tasks).  The location and
> -semantics of the reservation map is significantly different for two types
> +semantics of the reservation map is significantly different for the two types
>  of mappings.  Location differences are:
>
> -- For private mappings, the reservation map hangs off the the VMA structure.
> +- For private mappings, the reservation map hangs off the VMA structure.
>    Specifically, vma->vm_private_data.  This reserve map is created at the
>    time the mapping (mmap(MAP_PRIVATE)) is created.
>  - For shared mappings, the reservation map hangs off the inode.  Specifically,
> @@ -109,15 +109,15 @@ These operations result in a call to the routine hugetlb_reserve_pages()::
>                                   struct vm_area_struct *vma,
>                                   vm_flags_t vm_flags)
>
> -The first thing hugetlb_reserve_pages() does is check for the NORESERVE
> +The first thing hugetlb_reserve_pages() does is check if the NORESERVE
>  flag was specified in either the shmget() or mmap() call.  If NORESERVE
> -was specified, then this routine returns immediately as no reservation
> +was specified, then this routine returns immediately as no reservations
>  are desired.
>
>  The arguments 'from' and 'to' are huge page indices into the mapping or
>  underlying file.  For shmget(), 'from' is always 0 and 'to' corresponds to
>  the length of the segment/mapping.  For mmap(), the offset argument could
> -be used to specify the offset into the underlying file.  In such a case
> +be used to specify the offset into the underlying file.  In such a case,
>  the 'from' and 'to' arguments have been adjusted by this offset.
>
>  One of the big differences between PRIVATE and SHARED mappings is the way
> @@ -138,7 +138,8 @@ to indicate this VMA owns the reservations.
>
>  The reservation map is consulted to determine how many huge page reservations
>  are needed for the current mapping/segment.  For private mappings, this is
> -always the value (to - from).  However, for shared mappings it is possible that some reservations may already exist within the range (to - from).  See the
> +always the value (to - from).  However, for shared mappings it is possible that
> +some reservations may already exist within the range (to - from).  See the
>  section :ref:`Reservation Map Modifications <resv_map_modifications>`
>  for details on how this is accomplished.
>
> @@ -165,7 +166,7 @@ these counters.
>  If there were enough free huge pages and the global count resv_huge_pages
>  was adjusted, then the reservation map associated with the mapping is
>  modified to reflect the reservations.  In the case of a shared mapping, a
> -file_region will exist that includes the range 'from' 'to'.  For private
> +file_region will exist that includes the range 'from' - 'to'.  For private
>  mappings, no modifications are made to the reservation map as lack of an
>  entry indicates a reservation exists.
>
> @@ -239,7 +240,7 @@ subpool accounting when the page is freed.
>  The routine vma_commit_reservation() is then called to adjust the reserve
>  map based on the consumption of the reservation.  In general, this involves
>  ensuring the page is represented within a file_region structure of the region
> -map.  For shared mappings where the the reservation was present, an entry
> +map.  For shared mappings where the reservation was present, an entry
>  in the reserve map already existed so no change is made.  However, if there
>  was no reservation in a shared mapping or this was a private mapping a new
>  entry must be created.
> diff --git a/Documentation/vm/transhuge.rst b/Documentation/vm/transhuge.rst
> index a8cf6809e36e..0be61b0d75d3 100644
> --- a/Documentation/vm/transhuge.rst
> +++ b/Documentation/vm/transhuge.rst
> @@ -4,8 +4,9 @@
>  Transparent Hugepage Support
>  ============================
>
> -This document describes design principles Transparent Hugepage (THP)
> -Support and its interaction with other parts of the memory management.
> +This document describes design principles for Transparent Hugepage (THP)
> +support and its interaction with other parts of the memory management
> +system.
>
>  Design principles
>  =================
> @@ -35,27 +36,27 @@ Design principles
>  get_user_pages and follow_page
>  ==============================
>
> -get_user_pages and follow_page if run on a hugepage, will return the
> +get_user_pages and follow_page, if run on a hugepage, will return the
>  head or tail pages as usual (exactly as they would do on
> -hugetlbfs). Most gup users will only care about the actual physical
> +hugetlbfs). Most GUP users will only care about the actual physical
>  address of the page and its temporary pinning to release after the I/O
>  is complete, so they won't ever notice the fact the page is huge. But
>  if any driver is going to mangle over the page structure of the tail
>  page (like for checking page->mapping or other bits that are relevant
>  for the head page and not the tail page), it should be updated to jump
> -to check head page instead. Taking reference on any head/tail page would
> -prevent page from being split by anyone.
> +to check head page instead. Taking a reference on any head/tail page would
> +prevent the page from being split by anyone.
>
>  .. note::
>     these aren't new constraints to the GUP API, and they match the
> -   same constrains that applies to hugetlbfs too, so any driver capable
> +   same constraints that apply to hugetlbfs too, so any driver capable
>     of handling GUP on hugetlbfs will also work fine on transparent
>     hugepage backed mappings.
>
>  In case you can't handle compound pages if they're returned by
> -follow_page, the FOLL_SPLIT bit can be specified as parameter to
> +follow_page, the FOLL_SPLIT bit can be specified as a parameter to
>  follow_page, so that it will split the hugepages before returning
> -them. Migration for example passes FOLL_SPLIT as parameter to
> +them. Migration for example passes FOLL_SPLIT as a parameter to

The migration example has been removed by me. The patch has been on
linux-next. Please check "doc: mm: migration doesn't use FOLL_SPLIT
anymore" out.

Thanks,
Yang

>  follow_page because it's not hugepage aware and in fact it can't work
>  at all on hugetlbfs (but it instead works fine on transparent
>  hugepages thanks to FOLL_SPLIT). migration simply can't deal with
> @@ -72,11 +73,11 @@ pmd_offset. It's trivial to make the code transparent hugepage aware
>  by just grepping for "pmd_offset" and adding split_huge_pmd where
>  missing after pmd_offset returns the pmd. Thanks to the graceful
>  fallback design, with a one liner change, you can avoid to write
> -hundred if not thousand of lines of complex code to make your code
> +hundreds if not thousands of lines of complex code to make your code
>  hugepage aware.
>
>  If you're not walking pagetables but you run into a physical hugepage
> -but you can't handle it natively in your code, you can split it by
> +that you can't handle natively in your code, you can split it by
>  calling split_huge_page(page). This is what the Linux VM does before
>  it tries to swapout the hugepage for example. split_huge_page() can fail
>  if the page is pinned and you must handle this correctly.
> @@ -103,18 +104,18 @@ split_huge_page() or split_huge_pmd() has a cost.
>
>  To make pagetable walks huge pmd aware, all you need to do is to call
>  pmd_trans_huge() on the pmd returned by pmd_offset. You must hold the
> -mmap_sem in read (or write) mode to be sure an huge pmd cannot be
> +mmap_sem in read (or write) mode to be sure a huge pmd cannot be
>  created from under you by khugepaged (khugepaged collapse_huge_page
>  takes the mmap_sem in write mode in addition to the anon_vma lock). If
>  pmd_trans_huge returns false, you just fallback in the old code
>  paths. If instead pmd_trans_huge returns true, you have to take the
>  page table lock (pmd_lock()) and re-run pmd_trans_huge. Taking the
> -page table lock will prevent the huge pmd to be converted into a
> +page table lock will prevent the huge pmd being converted into a
>  regular pmd from under you (split_huge_pmd can run in parallel to the
>  pagetable walk). If the second pmd_trans_huge returns false, you
>  should just drop the page table lock and fallback to the old code as
> -before. Otherwise you can proceed to process the huge pmd and the
> -hugepage natively. Once finished you can drop the page table lock.
> +before. Otherwise, you can proceed to process the huge pmd and the
> +hugepage natively. Once finished, you can drop the page table lock.
>
>  Refcounts and transparent huge pages
>  ====================================
> @@ -122,61 +123,61 @@ Refcounts and transparent huge pages
>  Refcounting on THP is mostly consistent with refcounting on other compound
>  pages:
>
> -  - get_page()/put_page() and GUP operate in head page's ->_refcount.
> +  - get_page()/put_page() and GUP operate on head page's ->_refcount.
>
>    - ->_refcount in tail pages is always zero: get_page_unless_zero() never
> -    succeed on tail pages.
> +    succeeds on tail pages.
>
>    - map/unmap of the pages with PTE entry increment/decrement ->_mapcount
>      on relevant sub-page of the compound page.
>
> -  - map/unmap of the whole compound page accounted in compound_mapcount
> +  - map/unmap of the whole compound page is accounted for in compound_mapcount
>      (stored in first tail page). For file huge pages, we also increment
>      ->_mapcount of all sub-pages in order to have race-free detection of
>      last unmap of subpages.
>
>  PageDoubleMap() indicates that the page is *possibly* mapped with PTEs.
>
> -For anonymous pages PageDoubleMap() also indicates ->_mapcount in all
> +For anonymous pages, PageDoubleMap() also indicates ->_mapcount in all
>  subpages is offset up by one. This additional reference is required to
>  get race-free detection of unmap of subpages when we have them mapped with
>  both PMDs and PTEs.
>
> -This is optimization required to lower overhead of per-subpage mapcount
> -tracking. The alternative is alter ->_mapcount in all subpages on each
> +This optimization is required to lower the overhead of per-subpage mapcount
> +tracking. The alternative is to alter ->_mapcount in all subpages on each
>  map/unmap of the whole compound page.
>
> -For anonymous pages, we set PG_double_map when a PMD of the page got split
> -for the first time, but still have PMD mapping. The additional references
> -go away with last compound_mapcount.
> +For anonymous pages, we set PG_double_map when a PMD of the page is split
> +for the first time, but still have a PMD mapping. The additional references
> +go away with the last compound_mapcount.
>
> -File pages get PG_double_map set on first map of the page with PTE and
> -goes away when the page gets evicted from page cache.
> +File pages get PG_double_map set on the first map of the page with PTE and
> +goes away when the page gets evicted from the page cache.
>
>  split_huge_page internally has to distribute the refcounts in the head
>  page to the tail pages before clearing all PG_head/tail bits from the page
>  structures. It can be done easily for refcounts taken by page table
> -entries. But we don't have enough information on how to distribute any
> +entries, but we don't have enough information on how to distribute any
>  additional pins (i.e. from get_user_pages). split_huge_page() fails any
> -requests to split pinned huge page: it expects page count to be equal to
> -sum of mapcount of all sub-pages plus one (split_huge_page caller must
> -have reference for head page).
> +requests to split pinned huge pages: it expects page count to be equal to
> +the sum of mapcount of all sub-pages plus one (split_huge_page caller must
> +have a reference to the head page).
>
>  split_huge_page uses migration entries to stabilize page->_refcount and
> -page->_mapcount of anonymous pages. File pages just got unmapped.
> +page->_mapcount of anonymous pages. File pages just get unmapped.
>
> -We safe against physical memory scanners too: the only legitimate way
> -scanner can get reference to a page is get_page_unless_zero().
> +We are safe against physical memory scanners too: the only legitimate way
> +a scanner can get a reference to a page is get_page_unless_zero().
>
>  All tail pages have zero ->_refcount until atomic_add(). This prevents the
>  scanner from getting a reference to the tail page up to that point. After the
> -atomic_add() we don't care about the ->_refcount value. We already known how
> +atomic_add() we don't care about the ->_refcount value. We already know how
>  many references should be uncharged from the head page.
>
>  For head page get_page_unless_zero() will succeed and we don't mind. It's
> -clear where reference should go after split: it will stay on head page.
> +clear where references should go after split: it will stay on the head page.
>
> -Note that split_huge_pmd() doesn't have any limitation on refcounting:
> +Note that split_huge_pmd() doesn't have any limitations on refcounting:
>  pmd can be split at any point and never fails.
>
>  Partial unmap and deferred_split_huge_page()
> @@ -188,10 +189,10 @@ in page_remove_rmap() and queue the THP for splitting if memory pressure
>  comes. Splitting will free up unused subpages.
>
>  Splitting the page right away is not an option due to locking context in
> -the place where we can detect partial unmap. It's also might be
> +the place where we can detect partial unmap. It also might be
>  counterproductive since in many cases partial unmap happens during exit(2) if
>  a THP crosses a VMA boundary.
>
> -Function deferred_split_huge_page() is used to queue page for splitting.
> +The function deferred_split_huge_page() is used to queue a page for splitting.
>  The splitting itself will happen when we get memory pressure via shrinker
>  interface.
> --
> 2.20.1
>

