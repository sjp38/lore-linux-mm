Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2FAE6B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 16:28:19 -0400 (EDT)
From: Andrew Hastings <abh@cray.com>
Message-Id: <201003222028.o2MKSDsD006611@pogo.us.cray.com>
Date: Mon, 22 Mar 2010 15:28:13 -0500
Subject: BUG: Use after free in free_huge_page()
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

It looks like there's a use-after-free issue in free_huge_page().

free_huge_page() says:

        mapping = (struct address_space *) page_private(page);
	...
        if (mapping)
                hugetlb_put_quota(mapping, 1);

Running a kernel with CONFIG_DEBUG_SLAB, we get a "Oops: <NULL>" in
hugetlb_put_quota.  The stack backtrace looks like:

  free_huge_page
  put_page
  ... driver functions ...
  __fput
  fput
  filp_close
  put_files_struct
  exit_files
  do_exit
  do_group_exit
  get_signal_to_deliver
  do_notify_resume
  ptregscall_common

'mapping' points to memory containing POISON_FREE:

>> dump 0xffff880407464f20 16
0xffff880407464f20: 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b : kkkkkkkkkkkkkkkk
0xffff880407464f30: 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b : kkkkkkkkkkkkkkkk

I think what happens is:
1.  Driver does get_user_pages() for pages mapped by hugetlbfs.
2.  Process exits.
3.  hugetlbfs file is closed; the vma->vm_file->f_mapping value stored in
    page_private now points to freed memory
4.  Driver file is closed; driver's release() function calls put_page()
    which calls free_huge_page() which passes bogus mapping value to
    hugetlb_put_quota().

We've seen this with 2.6.27.42 but free_huge_page() is unchanged in 2.6.33.1.

git commit c79fb75e5a514a5a35f22c229042aa29f4237e3a ("hugetlb: fix quota
management for private mappings") is what introduced the reliance on mapping
in free_huge_page().

I'd like to help with a fix, but it's not immediately obvious to me what
the right path is.  Should hugetlb_no_page() always call add_to_page_cache()
even if VM_MAYSHARE is clear?

-Andrew Hastings
 Cray Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
