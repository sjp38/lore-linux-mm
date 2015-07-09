Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 24B466B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 09:19:16 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so4176528pdj.3
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 06:19:15 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id uy7si9203567pbc.246.2015.07.09.06.19.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 06:19:15 -0700 (PDT)
Date: Thu, 9 Jul 2015 16:19:00 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v6 5/6] proc: add kpageidle file
Message-ID: <20150709131900.GK2436@esperanza>
References: <cover.1434102076.git.vdavydov@parallels.com>
 <50b7cd0f35f651481ce32414fab5210de5dc1714.1434102076.git.vdavydov@parallels.com>
 <CAJu=L5-fwHMEKmL1Sp7owXyBa0GCrGR=TdKZbh15CJA3WrcwqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJu=L5-fwHMEKmL1Sp7owXyBa0GCrGR=TdKZbh15CJA3WrcwqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg
 Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David
 Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andres,

On Wed, Jul 08, 2015 at 04:01:13PM -0700, Andres Lagar-Cavilla wrote:
> On Fri, Jun 12, 2015 at 2:52 AM, Vladimir Davydov
[...]
> > @@ -275,6 +276,179 @@ static const struct file_operations proc_kpagecgroup_operations = {
> >  };
> >  #endif /* CONFIG_MEMCG */
> >
> > +#ifdef CONFIG_IDLE_PAGE_TRACKING
> > +/*
> > + * Idle page tracking only considers user memory pages, for other types of
> > + * pages the idle flag is always unset and an attempt to set it is silently
> > + * ignored.
> > + *
> > + * We treat a page as a user memory page if it is on an LRU list, because it is
> > + * always safe to pass such a page to page_referenced(), which is essential for
> > + * idle page tracking. With such an indicator of user pages we can skip
> > + * isolated pages, but since there are not usually many of them, it will hardly
> > + * affect the overall result.
> > + *
> > + * This function tries to get a user memory page by pfn as described above.
> > + */
> > +static struct page *kpageidle_get_page(unsigned long pfn)
> > +{
> > +       struct page *page;
> > +       struct zone *zone;
> > +
> > +       if (!pfn_valid(pfn))
> > +               return NULL;
> > +
> > +       page = pfn_to_page(pfn);
> > +       if (!page || !PageLRU(page))
> 
> Isolation can race in while you're processing the page, after these
> checks. This is ok, but worth a small comment.

Agree, will add one.

> 
> > +               return NULL;
> > +       if (!get_page_unless_zero(page))
> > +               return NULL;
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
> > +/*
> > + * This function calls page_referenced() to clear the referenced bit for all
> > + * mappings to a page. Since the latter also clears the page idle flag if the
> > + * page was referenced, it can be used to update the idle flag of a page.
> > + */
> > +static void kpageidle_clear_pte_refs(struct page *page)
> > +{
> > +       unsigned long dummy;
> > +
> > +       if (page_referenced(page, 0, NULL, &dummy, NULL))
> 
> Because of pte/pmd_clear_flush_young* called in the guts of
> page_referenced_one, an N byte write or read to /proc/kpageidle will
> cause N * 64 TLB flushes.
> 
> Additionally, because of the _notify connection to mmu notifiers, this
> will also cause N * 64 EPT TLB flushes (in the KVM Intel case, similar
> for other notifier flavors, you get the point).
> 
> The solution is relatively straightforward: augment
> page_referenced_one with a mode marker or boolean that determines
> whether tlb flushing is required.

Frankly, I don't think that tlb flushes are such a big deal in the scope
of this feature, because one is not supposed to write to kpageidle that
often. However, I agree we'd better avoid overhead we can easily avoid,
so I'll add a new flag to differentiate between kpageidle and reclaim
path in page_referenced, as you suggested.

> 
> For an access pattern tracker such as the one you propose, flushing is
> not strictly necessary: the next context switch will take care. Too
> bad if you missed a few accesses because the pte/pmd was loaded in the
> TLB. Not so easy for MMU notifiers, because each secondary MMU has its
> own semantics. You could arguably throw the towel in there, or try to
> provide a framework (i.e. propagate the flushing flag) and let each
> implementation fill the gaps.
> 
> > +               /*
> > +                * We cleared the referenced bit in a mapping to this page. To
> > +                * avoid interference with the reclaimer, mark it young so that
> > +                * the next call to page_referenced() will also return > 0 (see
> > +                * page_referenced_one())
> > +                */
> > +               set_page_young(page);
> > +}
> > +
> > +static ssize_t kpageidle_read(struct file *file, char __user *buf,
> > +                             size_t count, loff_t *ppos)
> > +{
> > +       u64 __user *out = (u64 __user *)buf;
> > +       struct page *page;
> > +       unsigned long pfn, end_pfn;
> > +       ssize_t ret = 0;
> > +       u64 idle_bitmap = 0;
> > +       int bit;
> > +
> > +       if (*ppos & KPMMASK || count & KPMMASK)
> > +               return -EINVAL;
> > +
> > +       pfn = *ppos * BITS_PER_BYTE;
> > +       if (pfn >= max_pfn)
> > +               return 0;
> > +
> > +       end_pfn = pfn + count * BITS_PER_BYTE;
> > +       if (end_pfn > max_pfn)
> > +               end_pfn = ALIGN(max_pfn, KPMBITS);
> > +
> > +       for (; pfn < end_pfn; pfn++) {
> > +               bit = pfn % KPMBITS;
> > +               page = kpageidle_get_page(pfn);
> > +               if (page) {
> > +                       if (page_is_idle(page)) {
> > +                               /*
> > +                                * The page might have been referenced via a
> > +                                * pte, in which case it is not idle. Clear
> > +                                * refs and recheck.
> > +                                */
> > +                               kpageidle_clear_pte_refs(page);
> > +                               if (page_is_idle(page))
> > +                                       idle_bitmap |= 1ULL << bit;
> > +                       }
> > +                       put_page(page);
> > +               }
> > +               if (bit == KPMBITS - 1) {
> > +                       if (put_user(idle_bitmap, out)) {
> > +                               ret = -EFAULT;
> > +                               break;
> > +                       }
> > +                       idle_bitmap = 0;
> > +                       out++;
> > +               }
> > +       }
> > +
> > +       *ppos += (char __user *)out - buf;
> > +       if (!ret)
> > +               ret = (char __user *)out - buf;
> > +       return ret;
> > +}
> > +
> > +static ssize_t kpageidle_write(struct file *file, const char __user *buf,
> 
> Your reasoning for a host wide /proc/kpageidle is well argued, but I'm
> still hesitant.
> 
> mincore() shows how to (relatively simply) resolve unmapped file pages
> to their backing page cache destination. You could recycle that code
> and then you'd have per process idle/idling interfaces. With the
> advantage of a clear TLB flush demarcation.

Hmm, I still don't see how we could handle page cache that does not
belong to any process in the scope of sys_mincore.

Besides, it'd be awkward to reuse sys_mincore for idle page tracking,
because we need two operations, set idle and check idle, while the
sys_mincore semantic implies only getting information from the kernel,
not vice versa.

Of course, we could introduce a separate syscall, say sys_idlecore, but
IMO it is not a good idea to add a syscall for such a specific feature,
which can be compiled out. I think a proc file suits better for the
purpose, especially counting that we have a bunch of similar files
(pagemap, kpageflags, kpagecount).

Anyway, I'm open for suggestions. If you have a different user API
design in mind, which in your opinion would fit better, please share.

> 
> > +                              size_t count, loff_t *ppos)
> > +{
> > +       const u64 __user *in = (const u64 __user *)buf;
> > +       struct page *page;
> > +       unsigned long pfn, end_pfn;
> > +       ssize_t ret = 0;
> > +       u64 idle_bitmap = 0;
> > +       int bit;
> > +
> > +       if (*ppos & KPMMASK || count & KPMMASK)
> > +               return -EINVAL;
> > +
> > +       pfn = *ppos * BITS_PER_BYTE;
> > +       if (pfn >= max_pfn)
> > +               return -ENXIO;
> > +
> > +       end_pfn = pfn + count * BITS_PER_BYTE;
> > +       if (end_pfn > max_pfn)
> > +               end_pfn = ALIGN(max_pfn, KPMBITS);
> > +
> > +       for (; pfn < end_pfn; pfn++) {
> 
> Relatively straight forward to teleport forward 512 (or more
> correctly: 1 << compound_order(page)) pages for THP pages, once done
> with a THP head, and avoid 511 fruitless trips down rmap.c for each
> tail.

Right, will fix.

> 
> > +               bit = pfn % KPMBITS;
> > +               if (bit == 0) {
> > +                       if (get_user(idle_bitmap, in)) {
> > +                               ret = -EFAULT;
> > +                               break;
> > +                       }
> > +                       in++;
> > +               }
> > +               if (idle_bitmap >> bit & 1) {
> > +                       page = kpageidle_get_page(pfn);
> > +                       if (page) {
> > +                               kpageidle_clear_pte_refs(page);
> > +                               set_page_idle(page);
> 
> In the common case this will make a page both young and idle. This is
> fine. We will come back to it below.
> 
> > +                               put_page(page);
> > +                       }
> > +               }
> > +       }
> > +
> > +       *ppos += (const char __user *)in - buf;
> > +       if (!ret)
> > +               ret = (const char __user *)in - buf;
> > +       return ret;
> > +}
> > +
> > +static const struct file_operations proc_kpageidle_operations = {
> > +       .llseek = mem_lseek,
> > +       .read = kpageidle_read,
> > +       .write = kpageidle_write,
> > +};
> > +
> > +#ifndef CONFIG_64BIT
> > +static bool need_page_idle(void)
> > +{
> > +       return true;
> > +}
> > +struct page_ext_operations page_idle_ops = {
> > +       .need = need_page_idle,
> > +};
> > +#endif
> > +#endif /* CONFIG_IDLE_PAGE_TRACKING */
> > +
> >  static int __init proc_page_init(void)
> >  {
> >         proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
[...]
> > @@ -798,6 +798,14 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
> >                 pte_unmap_unlock(pte, ptl);
> 
> This is not in your patch, but further up in page_referenced_one there
> is the pmd case.
> 
> So what happens on THP split? That was a leading question: you should
> propagate the young and idle flags to the split-up tail pages.

Good catch! I completely forgot about THP slit. Will fix in the next
iteration.

> 
> >         }
> >
> > +       if (referenced && page_is_idle(page))
> > +               clear_page_idle(page);
> 
> Is it so expensive to just call clear without the test .. ?

This function is normally called from a relatively cold path - memory
reclaim, where we modify page->flags anyway, so I think it won't make
any difference if we drop this check.

> 
> > +
> > +       if (page_is_young(page)) {
> > +               clear_page_young(page);
> 
> referenced += test_and_clear_page_young(page) .. ?

Yeah, that does look better.

> 
> > +               referenced++;
> > +       }
> > +
> 
> Invert the order. A page can be both young and idle -- we noted that
> closer to the top of the patch.
> 
> So young bumps referenced up, and then the final referenced value is
> used to clear idle.

I don't think it'd work. Look, kpageidle_write clears pte references and
sets the idle flag. If the page was referenced it also sets the young
flag in order not to interfere with the reclaimer. When kpageidle_read
is called afterwards, it must see the idle flag set iff the page has not
been referenced since kpageidle_write set it. However, if
page_referenced was not called on the page from the reclaim path, it
will still be young no matter if it has been referenced or not and
therefore will always be identified as not idle, which is incorrect.

> 
> >         if (referenced) {
> 
> At this point, if you follow my suggestion of augmenting
> page_referenced_one with a mode indicator (for TLB flushing), you can
> set page young here. There is the added benefit of holding the
> mmap_mutex lock or vma_lock, which prevents reclaim, try_to_unmap,
> migration, from exploiting a small window where page young is not set
> but should.

Yeah, if we go with the page_referenced mode switcher you suggested
above, it's definitely worth moving set_page_young here.

Thank you for the review!

Vladimir

> 
> >                 pra->referenced++;
> >                 pra->vm_flags |= vma->vm_flags;
> > diff --git a/mm/swap.c b/mm/swap.c
> > index ab7c338eda87..db43c9b4891d 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -623,6 +623,8 @@ void mark_page_accessed(struct page *page)
> >         } else if (!PageReferenced(page)) {
> >                 SetPageReferenced(page);
> >         }
> > +       if (page_is_idle(page))
> > +               clear_page_idle(page);
> >  }
> >  EXPORT_SYMBOL(mark_page_accessed);
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
