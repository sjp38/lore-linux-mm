Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id DE75F6B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 17:02:05 -0400 (EDT)
Message-ID: <5011AFEC.2040609@redhat.com>
Date: Thu, 26 Jul 2012 17:00:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: hugetlbfs: Close race during teardown of hugetlbfs
 shared page tables v2
References: <20120720134937.GG9222@suse.de>
In-Reply-To: <20120720134937.GG9222@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Larry Woodman <lwoodman@redhat.com>

On 07/20/2012 09:49 AM, Mel Gorman wrote:
> This V2 is still the mmap_sem approach that fixes a potential deadlock
> problem pointed out by Michal.

Larry and I were looking around the hugetlb code some
more, and found what looks like yet another race.

In hugetlb_no_page, we have the following code:


         spin_lock(&mm->page_table_lock);
         size = i_size_read(mapping->host) >> huge_page_shift(h);
         if (idx >= size)
                 goto backout;

         ret = 0;
         if (!huge_pte_none(huge_ptep_get(ptep)))
                 goto backout;

         if (anon_rmap)
                 hugepage_add_new_anon_rmap(page, vma, address);
         else
                 page_dup_rmap(page);
         new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
                                 && (vma->vm_flags & VM_SHARED)));
         set_huge_pte_at(mm, address, ptep, new_pte);
	...
	spin_unlock(&mm->page_table_lock);

Notice how we check !huge_pte_none with our own
mm->page_table_lock held.

This offers no protection at all against other
processes, that also hold their own page_table_lock.

In short, it looks like it is possible for multiple
processes to go through the above code simultaneously,
potentially resulting in:

1) one process overwriting the pte just created by
    another process

2) data corruption, as one partially written page
    gets superceded by an newly zeroed page, but no
    TLB invalidates get sent to other CPUs

3) a memory leak of a huge page

Is there anything that would make this race impossible,
or is this a real bug?

If so, are there more like it in the hugetlbfs code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
