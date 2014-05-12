Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id A52516B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 11:20:36 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hl10so3933252igb.9
        for <linux-mm@kvack.org>; Mon, 12 May 2014 08:20:36 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id kb5si8447331igb.8.2014.05.12.08.20.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 08:20:36 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id at1so3733452iec.33
        for <linux-mm@kvack.org>; Mon, 12 May 2014 08:20:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1405120858040.3090@gentwo.org>
References: <1399811500-14472-1-git-send-email-nasa4836@gmail.com> <alpine.DEB.2.10.1405120858040.3090@gentwo.org>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Mon, 12 May 2014 23:19:55 +0800
Message-ID: <CAHz2CGUfLx7DNgdNoAL0G3a9Ht6yf3bhWaojjNx91aF7L-iDQw@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: add comment for __mod_zone_page_stat
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, fabf@skynet.be, sasha.levin@oracle.com, oleg@redhat.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, Cyrill Gorcunov <gorcunov@gmail.com>, dave.hansen@linux.intel.com, toshi.kani@hp.com, paul.gortmaker@windriver.com, srivatsa.bhat@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 12, 2014 at 10:01 PM, Christoph Lameter <cl@linux.com> wrote:
> >
> >/*
> > * For use when we know that interrupts are disabled,
> > * or when we know that preemption is disabled and that
> > * particular counter cannot be updated from interrupt context.
> > */
>
> The description above looks ok to me. The problem is that you are
> considering the page related data structures as an issue for races and not
> the data structures relevant for vm statistics.

Hi,  Christoph,

Yep. I did.

Let me restate the point here.

 To use  __mod_zone_page_stat when we know that either
 1. interrupts are disabled, or
 2. preemption is disabled and that particular counter cannot be
    updated from interrupt context.

For those call sites currently using __mod_zone_page_stat, they just guarantees
the counter is never modified from an interrupt context, but doesn't disable
preemption.

This means they guarantee that even they are preemted the vm
counter won't be modified incorrectly.  Because the counter is page-related
(e.g., a new anon page added), and they are exclusively hold the pte lock.

This is why I emphasized on 'the page related data structures as an
issue for races'.

So, as you concludes in the other mail that __modd_zone_page_stat
couldn't be used.
in mlocked_vma_newpage, then what qualifies other call sites for using
it, in the same situation?
See:

void page_add_new_anon_rmap(struct page *page,
        struct vm_area_struct *vma, unsigned long address)
{
        VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
        SetPageSwapBacked(page);
        atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
        if (PageTransHuge(page))
                __inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
        __mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
                        hpage_nr_pages(page));         <---  using it.
        __page_set_anon_rmap(page, vma, address, 1);
        if (!mlocked_vma_newpage(vma, page)) {     <--- couldn't use it ?
                SetPageActive(page);
                lru_cache_add(page);
        } else
                add_page_to_unevictable_list(page);
}

Hope I express it clearly enough.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
