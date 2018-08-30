Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id ABFED6B5237
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:57:55 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o18-v6so8868098qtm.11
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:57:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 51-v6si3919800qvp.53.2018.08.30.09.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 09:57:54 -0700 (PDT)
Date: Thu, 30 Aug 2018 12:57:51 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180830165751.GD3529@redhat.com>
References: <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
 <20180827074645.GB21556@dhcp22.suse.cz>
 <20180827134633.GB3930@redhat.com>
 <9209043d-3240-105b-72a3-b4cd30f1b1f1@oracle.com>
 <20180829181424.GB3784@redhat.com>
 <20180829183906.GF10223@dhcp22.suse.cz>
 <20180829211106.GC3784@redhat.com>
 <20180830105616.GD2656@dhcp22.suse.cz>
 <20180830140825.GA3529@redhat.com>
 <20180830161800.GJ2656@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180830161800.GJ2656@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-rdma@vger.kernel.org, Matan Barak <matanb@mellanox.com>, Leon Romanovsky <leonro@mellanox.com>, Dimitri Sivanich <sivanich@sgi.com>

On Thu, Aug 30, 2018 at 06:19:52PM +0200, Michal Hocko wrote:
> On Thu 30-08-18 10:08:25, Jerome Glisse wrote:
> > On Thu, Aug 30, 2018 at 12:56:16PM +0200, Michal Hocko wrote:
> > > On Wed 29-08-18 17:11:07, Jerome Glisse wrote:
> > > > On Wed, Aug 29, 2018 at 08:39:06PM +0200, Michal Hocko wrote:
> > > > > On Wed 29-08-18 14:14:25, Jerome Glisse wrote:
> > > > > > On Wed, Aug 29, 2018 at 10:24:44AM -0700, Mike Kravetz wrote:
> > > > > [...]
> > > > > > > What would be the best mmu notifier interface to use where there are no
> > > > > > > start/end calls?
> > > > > > > Or, is the best solution to add the start/end calls as is done in later
> > > > > > > versions of the code?  If that is the suggestion, has there been any change
> > > > > > > in invalidate start/end semantics that we should take into account?
> > > > > > 
> > > > > > start/end would be the one to add, 4.4 seems broken in respect to THP
> > > > > > and mmu notification. Another solution is to fix user of mmu notifier,
> > > > > > they were only a handful back then. For instance properly adjust the
> > > > > > address to match first address covered by pmd or pud and passing down
> > > > > > correct page size to mmu_notifier_invalidate_page() would allow to fix
> > > > > > this easily.
> > > > > > 
> > > > > > This is ok because user of try_to_unmap_one() replace the pte/pmd/pud
> > > > > > with an invalid one (either poison, migration or swap) inside the
> > > > > > function. So anyone racing would synchronize on those special entry
> > > > > > hence why it is fine to delay mmu_notifier_invalidate_page() to after
> > > > > > dropping the page table lock.
> > > > > > 
> > > > > > Adding start/end might the solution with less code churn as you would
> > > > > > only need to change try_to_unmap_one().
> > > > > 
> > > > > What about dependencies? 369ea8242c0fb sounds like it needs work for all
> > > > > notifiers need to be updated as well.
> > > > 
> > > > This commit remove mmu_notifier_invalidate_page() hence why everything
> > > > need to be updated. But in 4.4 you can get away with just adding start/
> > > > end and keep around mmu_notifier_invalidate_page() to minimize disruption.
> > > 
> > > OK, this is really interesting. I was really worried to change the
> > > semantic of the mmu notifiers in stable kernels because this is really
> > > a hard to review change and high risk for anybody running those old
> > > kernels. If we can keep the mmu_notifier_invalidate_page and wrap them
> > > into the range scope API then this sounds like the best way forward.
> > > 
> > > So just to make sure we are at the same page. Does this sounds goo for
> > > stable 4.4. backport? Mike's hugetlb pmd shared fixup can be applied on
> > > top. What do you think?
> > 
> > You need to invalidate outside page table lock so before the call to
> > page_check_address(). For instance like below patch, which also only
> > do the range invalidation for huge page which would avoid too much of
> > a behavior change for user of mmu notifier.
> 
> Right. I would rather not make this PageHuge special though. So the
> fixed version should be.

Why not testing for huge ? Only huge is broken and thus only that
need the extra range invalidation. Doing the double invalidation
for single page is bit overkill.

Also below is bogus you need to add a out_notify: label to avoid
an inbalance in start/end callback.

> 
> From c05849f6789ec36e2ff11adcd8fa6cfb05e870a9 Mon Sep 17 00:00:00 2001
> From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
> Date: Thu, 31 Aug 2017 17:17:27 -0400
> Subject: [PATCH] mm/rmap: update to new mmu_notifier semantic v2
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> commit 369ea8242c0fb5239b4ddf0dc568f694bd244de4 upstrea.
> 
> Please note that this patch differs from the mainline because we do not
> really replace mmu_notifier_invalidate_page by mmu_notifier_invalidate_range
> because that requires changes to most of existing mmu notifiers. We also
> do not want to change the semantic of this API in old kernels. Anyway
> Jerome has suggested that it should be sufficient to simply wrap
> mmu_notifier_invalidate_page by *_invalidate_range_start()/end() to fix
> invalidation of larger than pte mappings (e.g. THP/hugetlb pages during
> migration). We need this change to handle large (hugetlb/THP) pages
> migration properly.
> 
> Note that because we can not presume the pmd value or pte value we have
> to assume the worst and unconditionaly report an invalidation as
> happening.
> 
> Changed since v2:
>   - try_to_unmap_one() only one call to mmu_notifier_invalidate_range()
>   - compute end with PAGE_SIZE << compound_order(page)
>   - fix PageHuge() case in try_to_unmap_one()
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Bernhard Held <berny156@gmx.de>
> Cc: Adam Borowski <kilobyte@angband.pl>
> Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
> Cc: Wanpeng Li <kernellwp@gmail.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Takashi Iwai <tiwai@suse.de>
> Cc: Nadav Amit <nadav.amit@gmail.com>
> Cc: Mike Galbraith <efault@gmx.de>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: axie <axie@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com> # backport to 4.4
> ---
>  mm/rmap.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 1bceb49aa214..aba994f55d6c 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1324,12 +1324,21 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	pte_t pteval;
>  	spinlock_t *ptl;
>  	int ret = SWAP_AGAIN;
> +	unsigned long start = address, end;
>  	enum ttu_flags flags = (enum ttu_flags)arg;
>  
>  	/* munlock has nothing to gain from examining un-locked vmas */
>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>  		goto out;
>  
> +	/*
> +	 * We have to assume the worse case ie pmd for invalidation. Note that
> +	 * the page can not be free in this function as call of try_to_unmap()
> +	 * must hold a reference on the page.
> +	 */
> +	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> +
>  	pte = page_check_address(page, mm, address, &ptl, 0);
>  	if (!pte)
>  		goto out;

Instead

>  		goto out_notify;

> @@ -1450,6 +1459,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	if (ret != SWAP_FAIL && ret != SWAP_MLOCK && !(flags & TTU_MUNLOCK))
>  		mmu_notifier_invalidate_page(mm, address);

+out_notify:

> +	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
>  out:
>  	return ret;
>  }
>  
> -- 
> 2.18.0
> 
> -- 
> Michal Hocko
> SUSE Labs
