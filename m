Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8676B0003
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 04:48:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n4-v6so269491pgp.8
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 01:48:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u68-v6sor6415275pfd.13.2018.08.15.01.48.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 01:48:00 -0700 (PDT)
Date: Wed, 15 Aug 2018 11:47:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: migration: fix migration of huge PMD shared pages
Message-ID: <20180815084754.6ea4z4pzjkcwepsv@kshutemo-mobl1>
References: <20180813034108.27269-1-mike.kravetz@oracle.com>
 <20180813105821.j4tg6iyrdxgwyr3y@kshutemo-mobl1>
 <d4cf0f85-e010-36f2-3fae-f7983e4f6505@oracle.com>
 <20180814084837.nl7dkea7aov2pzao@black.fi.intel.com>
 <17bfe24d-957f-2985-f134-3ebe2648aecb@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17bfe24d-957f-2985-f134-3ebe2648aecb@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 14, 2018 at 05:15:57PM -0700, Mike Kravetz wrote:
> On 08/14/2018 01:48 AM, Kirill A. Shutemov wrote:
> > On Mon, Aug 13, 2018 at 11:21:41PM +0000, Mike Kravetz wrote:
> >> On 08/13/2018 03:58 AM, Kirill A. Shutemov wrote:
> >>> On Sun, Aug 12, 2018 at 08:41:08PM -0700, Mike Kravetz wrote:
> >>>> I am not %100 sure on the required flushing, so suggestions would be
> >>>> appreciated.  This also should go to stable.  It has been around for
> >>>> a long time so still looking for an appropriate 'fixes:'.
> >>>
> >>> I believe we need flushing. And huge_pmd_unshare() usage in
> >>> __unmap_hugepage_range() looks suspicious: I don't see how we flush TLB in
> >>> that case.
> >>
> >> Thanks Kirill,
> >>
> >> __unmap_hugepage_range() has two callers:
> >> 1) unmap_hugepage_range, which wraps the call with tlb_gather_mmu and
> >>    tlb_finish_mmu on the range.  IIUC, this should cause an appropriate
> >>    TLB flush.
> >> 2) __unmap_hugepage_range_final via unmap_single_vma.  unmap_single_vma
> >>   has three callers:
> >>   - unmap_vmas which assumes the caller will flush the whole range after
> >>     return.
> >>   - zap_page_range wraps the call with tlb_gather_mmu/tlb_finish_mmu
> >>   - zap_page_range_single wraps the call with tlb_gather_mmu/tlb_finish_mmu
> >>
> >> So, it appears we are covered.  But, I could be missing something.
> > 
> > My problem here is that the mapping that moved by huge_pmd_unshare() in
> > not accounted into mmu_gather and can be missed on tlb_finish_mmu().
> 
> Ah, I think I now see the issue you are concerned with.
> 
> When huge_pmd_unshare succeeds we effectively unmap a PUD_SIZE area.
> The routine __unmap_hugepage_range may only have been passed a range
> that is a subset of PUD_SIZE.  In the case I was trying to address,
> try_to_unmap_one() the 'range' will certainly be less than PUD_SIZE.
> Upon further thought, I think that even in the case of try_to_unmap_one
> we should flush PUD_SIZE range.
> 
> My first thought would be to embed this flushing within huge_pmd_unshare
> itself.  Perhaps, whenever huge_pmd_unshare succeeds we should do an
> explicit:
> flush_cache_range(PUD_SIZE)
> flush_tlb_range(PUD_SIZE)
> mmu_notifier_invalidate_range(PUD_SIZE)
> That would take some of the burden off the callers of huge_pmd_unshare.
> However, I am not sure if the flushing calls above play nice in all the
> calling environments.  I'll look into it some more, but would appreciate
> additional comments.

I don't think it would work: flush_tlb_range() does IPI and calling it
under spinlock will not go well. I think we need to find a way to account
it properly in the mmu_gather. It's not obvious to me how.

-- 
 Kirill A. Shutemov
