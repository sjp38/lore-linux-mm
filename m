Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E5DA69003D3
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 07:05:46 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so4337756pdb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 04:05:46 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tz6si1098743pab.216.2015.07.14.04.05.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 04:05:45 -0700 (PDT)
Date: Tue, 14 Jul 2015 14:05:28 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v7 5/6] proc: add kpageidle file
Message-ID: <20150714110527.GA1015@esperanza>
References: <cover.1436623799.git.vdavydov@parallels.com>
 <25f235220bef9d799f48a060d7638a5de31fc994.1436623799.git.vdavydov@parallels.com>
 <CAJu=L59+7d_16zXZAFfJkr5HSwHsfYXi9EBu_9Sx1tAcJv2LOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJu=L59+7d_16zXZAFfJkr5HSwHsfYXi9EBu_9Sx1tAcJv2LOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg
 Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David
 Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 13, 2015 at 12:02:57PM -0700, Andres Lagar-Cavilla wrote:
> On Sat, Jul 11, 2015 at 7:48 AM, Vladimir Davydov
> <vdavydov@parallels.com> wrote:
[...]
> > +static struct page *kpageidle_get_page(unsigned long pfn)
> > +{
> > +       struct page *page;
> > +       struct zone *zone;
> > +
> > +       if (!pfn_valid(pfn))
> > +               return NULL;
> > +
> > +       page = pfn_to_page(pfn);
> > +       if (!page || PageTail(page) || !PageLRU(page) ||
> > +           !get_page_unless_zero(page))
> 
> get_page_unless_zero does not succeed for Tail pages.

True. So we don't seem to need the PageTail checks here at all, because
if kpageidle_get_page succeeds, the page must be a head, so that we
won't dive into expensive rmap_walk for tail pages. Will remove it then.

> 
> > +               return NULL;
> > +
> > +       if (unlikely(PageTail(page))) {
> > +               put_page(page);
> > +               return NULL;
> > +       }
> > +
> > +       zone = page_zone(page);
> > +       spin_lock_irq(&zone->lru_lock);
> > +       if (unlikely(!PageLRU(page))) {
> > +               put_page(page);
> > +               page = NULL;
> > +       }
> > +       spin_unlock_irq(&zone->lru_lock);
> > +       return page;
> > +}
> > +
> > +static int kpageidle_clear_pte_refs_one(struct page *page,
> > +                                       struct vm_area_struct *vma,
> > +                                       unsigned long addr, void *arg)
> > +{
> > +       struct mm_struct *mm = vma->vm_mm;
> > +       spinlock_t *ptl;
> > +       pmd_t *pmd;
> > +       pte_t *pte;
> > +       bool referenced = false;
> > +
> > +       if (unlikely(PageTransHuge(page))) {
> 
> VM_BUG_ON(!PageHead)?

Don't think it's necessary, because PageTransHuge already does this sort
of check:

: static inline int PageTransHuge(struct page *page)
: {
: 	VM_BUG_ON_PAGE(PageTail(page), page);
: 	return PageHead(page);
: }

> 
> > +               pmd = page_check_address_pmd(page, mm, addr,
> > +                                            PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
> > +               if (pmd) {
> > +                       referenced = pmdp_test_and_clear_young(vma, addr, pmd);
> 
> For any workload using MMU notifiers, this will lose significant
> information by not querying the secondary PTE. The most
> straightforward case is KVM. Once mappings are setup, all access
> activity is recorded through shadow PTEs. This interface will say
> "idle" even though the VM is blasting memory.

Hmm, interesting. It seems we have to introduce
mmu_notifier_ops.clear_young then, which, in contrast to
clear_flush_young, won't flush TLB. Looking back at your comment to v6,
now I see that you already mentioned it, but I missed your point :-(
OK, will do it in the next iteration.

Thanks a lot for the review!

Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
