Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA15406
	for <linux-mm@kvack.org>; Sun, 29 Sep 2002 17:52:37 -0700 (PDT)
Message-ID: <3D97A052.276A6D59@digeo.com>
Date: Sun, 29 Sep 2002 17:52:34 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: hugetlbfs-2.5.39-3
References: <20020930003558.GO22942@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
>> ..
> +int hugetlb_prefault(struct address_space *mapping, struct vm_area_struct *vma)
> +{
> +       struct mm_struct *mm = current->mm;
> +       unsigned long addr;
> +       int ret = 0;
> +
> +       BUG_ON(vma->vm_start & ~HPAGE_MASK);
> +       BUG_ON(vma->vm_end & ~HPAGE_MASK);
> +
> +       spin_lock(&mm->page_table_lock);
> +       for (addr = vma->vm_start; addr < vma->vm_end; addr += HPAGE_SIZE) {
> +               unsigned long idx;
> +               pte_t *pte = huge_pte_alloc(mm, addr);
> +               struct page *page;
> +
> +               if (!pte) {
> +                       ret = -ENOMEM;
> +                       goto out;
> +               }
> +               if (!pte_none(*pte))
> +                       continue;
> +
> +               idx = ((addr - vma->vm_start) >> HPAGE_SHIFT)
> +                       + (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
> +               page = find_get_page(mapping, idx);
> +               if (!page) {
> +                       page = alloc_hugetlb_page();
> +                       if (!page) {
> +                               ret = -ENOMEM;
> +                               goto out;
> +                       }
> +                       add_to_page_cache(page, mapping, idx);
> +               }
> +               set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
> +       }
> +out:
> +       spin_unlock(&mm->page_table_lock);
> +       return ret;
> +}

huge_pte_alloc() is a sleeping function.

When you plug that one, I'd appreciate it if you could find a way
of not taking mapping->page_lock inside mm->page_table_lock.  Those
locks have "no relationship" at present (I think), and it'd be nice
to keep it that way.

But putting page_lock inside page_table_lock would be the right
ordering if it's unavoidable.  page_lock is a very inner lock,
and shall become a very short-held one.

So I suggest you do the "is it there, no, allocate it, is it there
now, yes, oh gee we raced" thing.

Apart from that - nifty.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
