Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9556B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:27:35 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wp4so1350083obc.1
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 05:27:35 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w9si5268691oev.21.2015.01.22.05.27.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 05:27:34 -0800 (PST)
Date: Thu, 22 Jan 2015 16:28:13 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: remove rest usage of VM_NONLINEAR and pte_file()
Message-ID: <20150122132813.GA15803@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org

Hello Kirill A. Shutemov,

The patch 05864bbd92f9: "mm: remove rest usage of VM_NONLINEAR and
pte_file()" from Jan 17, 2015, leads to the following static checker
warning:

	mm/memcontrol.c:4794 mc_handle_file_pte()
	warn: passing uninitialized 'pgoff'

mm/memcontrol.c
  4774  static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
  4775                          unsigned long addr, pte_t ptent, swp_entry_t *entry)
  4776  {
  4777          struct page *page = NULL;
  4778          struct address_space *mapping;
  4779          pgoff_t pgoff;
  4780  
  4781          if (!vma->vm_file) /* anonymous vma */
  4782                  return NULL;
  4783          if (!(mc.flags & MOVE_FILE))
  4784                  return NULL;
  4785  
  4786          mapping = vma->vm_file->f_mapping;
  4787          if (pte_none(ptent))
  4788                  pgoff = linear_page_index(vma, addr);

We used to have an "else pgoff = pte_to_pgoff(ptent);" but now it's just
uninitialized data.

  4789  
  4790          /* page is moved even if it's not RSS of this task(page-faulted). */
  4791  #ifdef CONFIG_SWAP
  4792          /* shmem/tmpfs may report page out on swap: account for that too. */
  4793          if (shmem_mapping(mapping)) {
  4794                  page = find_get_entry(mapping, pgoff);
                                                       ^^^^^

Used here.

  4795                  if (radix_tree_exceptional_entry(page)) {
  4796                          swp_entry_t swp = radix_to_swp_entry(page);
  4797                          if (do_swap_account)
  4798                                  *entry = swp;
  4799                          page = find_get_page(swap_address_space(swp), swp.val);
  4800                  }
  4801          } else
  4802                  page = find_get_page(mapping, pgoff);
  4803  #else
  4804          page = find_get_page(mapping, pgoff);
                                              ^^^^^
And here.

  4805  #endif
  4806          return page;
  4807  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
