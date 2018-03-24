Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 990DC6B000C
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 14:24:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q19so10150224qta.17
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 11:24:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r19si5914qki.57.2018.03.24.11.24.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Mar 2018 11:24:03 -0700 (PDT)
Date: Sat, 24 Mar 2018 14:24:00 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180324182359.GB4928@redhat.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180321172932.GE4780@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>

On Wed, Mar 21, 2018 at 10:29:32AM -0700, Matthew Wilcox wrote:
> On Wed, Mar 21, 2018 at 09:31:22AM -0700, Yang Shi wrote:
> > On 3/21/18 6:08 AM, Michal Hocko wrote:
> > > Yes, this definitely sucks. One way to work that around is to split the
> > > unmap to two phases. One to drop all the pages. That would only need
> > > mmap_sem for read and then tear down the mapping with the mmap_sem for
> > > write. This wouldn't help for parallel mmap_sem writers but those really
> > > need a different approach (e.g. the range locking).
> > 
> > page fault might sneak in to map a page which has been unmapped before?
> > 
> > range locking should help a lot on manipulating small sections of a large
> > mapping in parallel or multiple small mappings. It may not achieve too much
> > for single large mapping.
> 
> I don't think we need range locking.  What if we do munmap this way:
> 
> Take the mmap_sem for write
> Find the VMA
>   If the VMA is large(*)
>     Mark the VMA as deleted
>     Drop the mmap_sem
>     zap all of the entries
>     Take the mmap_sem
>   Else
>     zap all of the entries
> Continue finding VMAs
> Drop the mmap_sem
> 
> Now we need to change everywhere which looks up a VMA to see if it needs
> to care the the VMA is deleted (page faults, eg will need to SIGBUS; mmap
> does not care; munmap will need to wait for the existing munmap operation
> to complete), but it gives us the atomicity, at least on a per-VMA basis.
> 

What about something that should fix all issues:
    struct list_head to_free_puds;
    ...
    down_write(&mm->mmap_sem);
    ...
    unmap_vmas(&tlb, vma, start, end, &to_free_puds);
    arch_unmap(mm, vma, start, end);
    /* Fix up all other VM information */
    remove_vma_list(mm, vma);
    ...
    up_write(&mm->mmap_sem);
    ...
    zap_pud_list(rss_update_info, to_free_puds);
    update_rss(rss_update_info)

We collect pud that need to be free/zap we update the page table PUD
entry to pud_none under the write sem and CPU page table lock, add the
pud to the list that need zapping. We only collect pud fully cover,
and usual business for partialy covered pud.

Everything behave as today except that we do not free memory. Care
must be take with the anon vma and we should probably not free the
vma struct either before the zap but all other mm struct can be
updated. The rss_counter would also to be updated post zap pud.

We would need special code to zap pud list, no need to take lock or
do special arch tlb flushing, ptep_get_clear, ... when walking down
those puds. So it should scale a lot better too.

Did i miss something ?

Cheers,
Jerome
