Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3BC7C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:47:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 898352239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:47:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LTv+NTfd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 898352239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 322976B0005; Tue, 23 Jul 2019 01:47:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D1CE8E0003; Tue, 23 Jul 2019 01:47:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C3708E0001; Tue, 23 Jul 2019 01:47:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D847E6B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:47:38 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so25383564pfo.22
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:47:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3cXYdkJu4Ln2/55L4Htzkw7XiZlPUrceVQ4reuZLMzA=;
        b=TmhtmfewVHgWQf+JzQrRl4Rzob3PXbXawSgNzj6gtVNn2vjNtc6ky+vF1sZ/oCVE5w
         LjLrbCji5yFeuT5F8rb9Bsy0rEy46dC6uoW/OoghLSblJbkpO9Jj+m8PH1ItqcOm2zCn
         TuCVyuKekJUtzqsqBNBtiJLwzgaUiP/SfrMq4ZVm7JRANAJTBd4r0CQW5ykt/V8I7Fvo
         8wuAJI2ETU/Mg4h6/yFhzlAOioh1tS4+UlJ6Dem7LJyLkudZjUZz0qr9sJEcpLdRhMHj
         /dViVI/L7qv/aIrqqTfaR7caY6LWS4iKnpPUfL7GO16YC9mQmfmLXn5QQuym1eN239In
         IREw==
X-Gm-Message-State: APjAAAUSptKvmnqfSo7Y/u21X3NHG9vMPd6vtOmPpAWDTFc2dYps+sby
	2u5NmurzeyCoircjts84B06hPYorzuv94uQPHRjZPPFmgzeNFt8c14sgG4ZCZVpt6G4Uef4wZt9
	nnk0nwMtTy6PcCu50UVhD+vaGKq1i0+M820/IhKJBg0GVOEqYl7v8rZwKG8kcRJc=
X-Received: by 2002:a17:902:29e6:: with SMTP id h93mr21819267plb.297.1563860858467;
        Mon, 22 Jul 2019 22:47:38 -0700 (PDT)
X-Received: by 2002:a17:902:29e6:: with SMTP id h93mr21819208plb.297.1563860857413;
        Mon, 22 Jul 2019 22:47:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563860857; cv=none;
        d=google.com; s=arc-20160816;
        b=qFh3rrGJt+N4kdIFY+yHtSkOljVe+UqdHwMPPFNIaKQox8qr842NJg8LarEGJTc2TM
         mzUYjywQQQ2V9XszOYLihO2bl5kBfyPr4SPXJHibRRwIz3/EXjD0TkYOAqLfKN0CAT78
         GWZz5c4bubhWjapx35HJGbihIAzqg3sLvthQAGAaXnHDeQ2OegMKWKInZidXS3xB/Hd1
         APNKtbf21X9/oWKhOaTLr8fLKityHaWhSRv7Q2B1/8A9OGt12OQJ7t+vZXdTee3W9wVx
         5ja7n6PL8bv4Ptv9lBFjRaUEFxghZiEUOBBBZ+k+/2M8n9/hQvc0E2ylsk+p45x56DzH
         cVMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=3cXYdkJu4Ln2/55L4Htzkw7XiZlPUrceVQ4reuZLMzA=;
        b=BZyexxY3AGQLlXq2fEIjtQAxzpnOGwRqAJyAeNsPFvON8C7l1fZF1nbw7LaMdhL2Jn
         b1kPRyBLtDTFhFLKczGoKtZ4Z0EDSMz2td16ZP0mS02OO+OChNhbahZoExIeo2bgdqxe
         Bgtz2JO583v++SAKlIsMZyirHsriLnZ54zKvH/Xu7dci7f0SK86JYMTG80ZRa6xUBoEr
         MerEyUV5amMY3vQUBegxY14I7HBlujZNnMOg938b7UNg3AYSwgGreO2m8bZ4nmH54xEm
         VmBXmO6IQIaLuaeS32GF6adBzL56RO64OqhaXAiLw+WJ+g6TKaakW0UjEEJ9h+HRecef
         hYZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LTv+NTfd;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor51368469pjz.15.2019.07.22.22.47.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 22:47:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LTv+NTfd;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3cXYdkJu4Ln2/55L4Htzkw7XiZlPUrceVQ4reuZLMzA=;
        b=LTv+NTfdGKnOx/ilEL1XtPlomMC5SHSrbwoiBqNVqMsiy2brYATDKKqUPopJQGY+aM
         v2ol8XYJcwV4isNDxChR0SF5qQkQygt5CaJ4Q5UPg2LmrL9/0PBsx/2IE1X/utmhjJwK
         meMtcRo0cnvF8obblJGN1KIqRZ5ZByKTqemHEcNi8uHb6+STmgBFLqtofSoxqnJdYFt3
         yj0YjO7XJ3Aef9e89lXDCcIC4V/OPnDBSwspXZheEjp3qGP5AkW+jCaWB35x2gC1/8ER
         QcF7r49dxH2xzAOrE3/t1PixQPSAR/auai65DPPMSpE0C8wxNmKgWof31+ZIRUbW9C6s
         qEwQ==
X-Google-Smtp-Source: APXvYqyYe/3rz9xBUXLNERR+e5KdXyWi4mtihGNQRWxsbU72wlnwYwEKAlT9HNtS4qwpBKqtQY1vLg==
X-Received: by 2002:a17:90a:8c18:: with SMTP id a24mr78356191pjo.111.1563860856821;
        Mon, 22 Jul 2019 22:47:36 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s5sm15801131pfm.97.2019.07.22.22.47.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 22:47:35 -0700 (PDT)
Date: Tue, 23 Jul 2019 14:47:29 +0900
From: Minchan Kim <minchan@kernel.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com,
	Benoit Lize <lizeb@google.com>, Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 1/5] mm: introduce MADV_COLD
Message-ID: <20190723054729.GC128252@google.com>
References: <20190714233401.36909-1-minchan@kernel.org>
 <20190714233401.36909-2-minchan@kernel.org>
 <CAJuCfpFqnXshLH=sW4GLEFixjTWNSh0Dap3Qt-E-Ho2uy-R43w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpFqnXshLH=sW4GLEFixjTWNSh0Dap3Qt-E-Ho2uy-R43w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 03:14:57PM -0700, Suren Baghdasaryan wrote:
> Hi Minchan,
> Couple comments inline.
> Thanks!
> 
> On Sun, Jul 14, 2019 at 4:34 PM Minchan Kim <minchan@kernel.org> wrote:
> >
> > When a process expects no accesses to a certain memory range, it could
> > give a hint to kernel that the pages can be reclaimed when memory pressure
> > happens but data should be preserved for future use.  This could reduce
> > workingset eviction so it ends up increasing performance.
> >
> > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > MADV_COLD can be used by a process to mark a memory range as not expected
> > to be used in the near future. The hint can help kernel in deciding which
> > pages to evict early during memory pressure.
> >
> > It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves
> >
> >         active file page -> inactive file LRU
> >         active anon page -> inacdtive anon LRU
> >
> > Unlike MADV_FREE, it doesn't move active anonymous pages to inactive
> > file LRU's head because MADV_COLD is a little bit different symantic.
> > MADV_FREE means it's okay to discard when the memory pressure because
> > the content of the page is *garbage* so freeing such pages is almost zero
> > overhead since we don't need to swap out and access afterward causes just
> > minor fault. Thus, it would make sense to put those freeable pages in
> > inactive file LRU to compete other used-once pages. It makes sense for
> > implmentaion point of view, too because it's not swapbacked memory any
> > longer until it would be re-dirtied. Even, it could give a bonus to make
> > them be reclaimed on swapless system. However, MADV_COLD doesn't mean
> > garbage so reclaiming them requires swap-out/in in the end so it's bigger
> > cost. Since we have designed VM LRU aging based on cost-model, anonymous
> > cold pages would be better to position inactive anon's LRU list, not file
> > LRU. Furthermore, it would help to avoid unnecessary scanning if system
> > doesn't have a swap device. Let's start simpler way without adding
> > complexity at this moment. However, keep in mind, too that it's a caveat
> > that workloads with a lot of pages cache are likely to ignore MADV_COLD
> > on anonymous memory because we rarely age anonymous LRU lists.
> >
> > * man-page material
> >
> > MADV_COLD (since Linux x.x)
> >
> > Pages in the specified regions will be treated as less-recently-accessed
> > compared to pages in the system with similar access frequencies.
> > In contrast to MADV_FREE, the contents of the region are preserved
> > regardless of subsequent writes to pages.
> >
> > MADV_COLD cannot be applied to locked pages, Huge TLB pages, or VM_PFNMAP
> > pages.
> >
> > * v2
> >  * add up the warn with lots of page cache workload - mhocko
> >  * add man page stuff - dave
> >
> > * v1
> >  * remove page_mapcount filter - hannes, mhocko
> >  * remove idle page handling - joelaf
> >
> > * RFCv2
> >  * add more description - mhocko
> >
> > * RFCv1
> >  * renaming from MADV_COOL to MADV_COLD - hannes
> >
> > * internal review
> >  * use clear_page_youn in deactivate_page - joelaf
> >  * Revise the description - surenb
> >  * Renaming from MADV_WARM to MADV_COOL - surenb
> >
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/swap.h                   |   1 +
> >  include/uapi/asm-generic/mman-common.h |   1 +
> >  mm/internal.h                          |   2 +-
> >  mm/madvise.c                           | 180 ++++++++++++++++++++++++-
> >  mm/oom_kill.c                          |   2 +-
> >  mm/swap.c                              |  42 ++++++
> >  6 files changed, 224 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index de2c67a33b7e..0ce997edb8bb 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -340,6 +340,7 @@ extern void lru_add_drain_cpu(int cpu);
> >  extern void lru_add_drain_all(void);
> >  extern void rotate_reclaimable_page(struct page *page);
> >  extern void deactivate_file_page(struct page *page);
> > +extern void deactivate_page(struct page *page);
> >  extern void mark_page_lazyfree(struct page *page);
> >  extern void swap_setup(void);
> >
> > diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> > index 63b1f506ea67..ef8a56927b12 100644
> > --- a/include/uapi/asm-generic/mman-common.h
> > +++ b/include/uapi/asm-generic/mman-common.h
> > @@ -45,6 +45,7 @@
> >  #define MADV_SEQUENTIAL        2               /* expect sequential page references */
> >  #define MADV_WILLNEED  3               /* will need these pages */
> >  #define MADV_DONTNEED  4               /* don't need these pages */
> > +#define MADV_COLD      5               /* deactivatie these pages */
> 
> s/deactivatie/deactivate

Fixed.

> 
> >
> >  /* common parameters: try to keep these consistent across architectures */
> >  #define MADV_FREE      8               /* free pages only if memory pressure */
> > diff --git a/mm/internal.h b/mm/internal.h
> > index f53a14d67538..c61b215ff265 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -39,7 +39,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf);
> >  void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
> >                 unsigned long floor, unsigned long ceiling);
> >
> > -static inline bool can_madv_dontneed_vma(struct vm_area_struct *vma)
> > +static inline bool can_madv_lru_vma(struct vm_area_struct *vma)
> >  {
> >         return !(vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP));
> >  }
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 968df3aa069f..bae0055f9724 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -40,6 +40,7 @@ static int madvise_need_mmap_write(int behavior)
> >         case MADV_REMOVE:
> >         case MADV_WILLNEED:
> >         case MADV_DONTNEED:
> > +       case MADV_COLD:
> >         case MADV_FREE:
> >                 return 0;
> >         default:
> > @@ -307,6 +308,178 @@ static long madvise_willneed(struct vm_area_struct *vma,
> >         return 0;
> >  }
> >
> > +static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> > +                               unsigned long end, struct mm_walk *walk)
> > +{
> > +       struct mmu_gather *tlb = walk->private;
> > +       struct mm_struct *mm = tlb->mm;
> > +       struct vm_area_struct *vma = walk->vma;
> > +       pte_t *orig_pte, *pte, ptent;
> > +       spinlock_t *ptl;
> > +       struct page *page;
> > +       unsigned long next;
> > +
> > +       next = pmd_addr_end(addr, end);
> > +       if (pmd_trans_huge(*pmd)) {
> > +               pmd_t orig_pmd;
> > +
> > +               tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
> > +               ptl = pmd_trans_huge_lock(pmd, vma);
> > +               if (!ptl)
> > +                       return 0;
> > +
> > +               orig_pmd = *pmd;
> > +               if (is_huge_zero_pmd(orig_pmd))
> > +                       goto huge_unlock;
> > +
> > +               if (unlikely(!pmd_present(orig_pmd))) {
> > +                       VM_BUG_ON(thp_migration_supported() &&
> > +                                       !is_pmd_migration_entry(orig_pmd));
> > +                       goto huge_unlock;
> > +               }
> > +
> > +               page = pmd_page(orig_pmd);
> > +               if (next - addr != HPAGE_PMD_SIZE) {
> > +                       int err;
> > +
> > +                       if (page_mapcount(page) != 1)
> > +                               goto huge_unlock;
> > +
> > +                       get_page(page);
> > +                       spin_unlock(ptl);
> > +                       lock_page(page);
> > +                       err = split_huge_page(page);
> > +                       unlock_page(page);
> > +                       put_page(page);
> > +                       if (!err)
> > +                               goto regular_page;
> > +                       return 0;
> > +               }
> > +
> > +               if (pmd_young(orig_pmd)) {
> > +                       pmdp_invalidate(vma, addr, pmd);
> > +                       orig_pmd = pmd_mkold(orig_pmd);
> > +
> > +                       set_pmd_at(mm, addr, pmd, orig_pmd);
> > +                       tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> > +               }
> > +
> > +               test_and_clear_page_young(page);
> > +               deactivate_page(page);
> > +huge_unlock:
> > +               spin_unlock(ptl);
> > +               return 0;
> > +       }
> > +
> > +       if (pmd_trans_unstable(pmd))
> > +               return 0;
> > +
> > +regular_page:
> > +       tlb_change_page_size(tlb, PAGE_SIZE);
> > +       orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +       flush_tlb_batched_pending(mm);
> > +       arch_enter_lazy_mmu_mode();
> > +       for (; addr < end; pte++, addr += PAGE_SIZE) {
> > +               ptent = *pte;
> > +
> > +               if (pte_none(ptent))
> > +                       continue;
> > +
> > +               if (!pte_present(ptent))
> > +                       continue;
> > +
> > +               page = vm_normal_page(vma, addr, ptent);
> > +               if (!page)
> > +                       continue;
> > +
> > +               /*
> > +                * Creating a THP page is expensive so split it only if we
> > +                * are sure it's worth. Split it if we are only owner.
> > +                */
> > +               if (PageTransCompound(page)) {
> > +                       if (page_mapcount(page) != 1)
> > +                               break;
> > +                       get_page(page);
> > +                       if (!trylock_page(page)) {
> > +                               put_page(page);
> > +                               break;
> > +                       }
> > +                       pte_unmap_unlock(orig_pte, ptl);
> > +                       if (split_huge_page(page)) {
> > +                               unlock_page(page);
> > +                               put_page(page);
> > +                               pte_offset_map_lock(mm, pmd, addr, &ptl);
> > +                               break;
> > +                       }
> > +                       unlock_page(page);
> > +                       put_page(page);
> > +                       pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> > +                       pte--;
> > +                       addr -= PAGE_SIZE;
> > +                       continue;
> > +               }
> > +
> > +               VM_BUG_ON_PAGE(PageTransCompound(page), page);
> > +
> > +               if (pte_young(ptent)) {
> > +                       ptent = ptep_get_and_clear_full(mm, addr, pte,
> > +                                                       tlb->fullmm);
> > +                       ptent = pte_mkold(ptent);
> > +                       set_pte_at(mm, addr, pte, ptent);
> > +                       tlb_remove_tlb_entry(tlb, pte, addr);
> > +               }
> > +
> > +               /*
> > +                * We are deactivating a page for accelerating reclaiming.
> > +                * VM couldn't reclaim the page unless we clear PG_young.
> > +                * As a side effect, it makes confuse idle-page tracking
> > +                * because they will miss recent referenced history.
> > +                */
> > +               test_and_clear_page_young(page);
> > +               deactivate_page(page);
> > +       }
> > +
> > +       arch_enter_lazy_mmu_mode();
> 
> Did you mean to say arch_leave_lazy_mmu_mode() ?

Oops, Fixed.

Thanks, Suren!

