Received: from localhost (localhost.localdomain [127.0.0.1])
	by einstein.tteng.com.br (Postfix) with ESMTP id 44D3E1205CA
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 12:33:10 -0200 (BRDT)
Received: from [192.168.0.141] (luciano.tteng.com.br [192.168.0.141])
	by einstein.tteng.com.br (Postfix) with ESMTP id 356F01205C4
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 12:33:09 -0200 (BRDT)
Message-ID: <41937940.9070001@tteng.com.br>
Date: Thu, 11 Nov 2004 12:37:52 -0200
From: "Luciano A. Stertz" <luciano@tteng.com.br>
MIME-Version: 1.0
Subject: [Fwd: Page allocator doubt]
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

	May someone help me? I tried kernelnewbies, but got no answers.

	TIA,
	Luciano Stertz

-------- Original Message --------
Subject: Page allocator doubt
Date: Wed, 10 Nov 2004 15:31:41 -0200
From: Luciano A. Stertz <luciano@tteng.com.br>
To: KERNEL <kernelnewbies@nl.linux.org>


	I have a doubt about the page allocation. I need to allocate a number
of contiguous pages to later initialize and add them to the page cache.
I'm doing something like that:

	struct address_space *x = &area->vm_file->f_dentry->d_inode->i_data;
	struct page *page = alloc_pages(mapping_gfp_mask(x)|__GFP_COLD, order);

	for (i = 0; i< 1<<order; i++) {
		struct page *pg = page + i;
		printk("Page count of page %i is %i\n", i, page_count(pg));
		printk("Page address: 0x%lx\n", page_address(pg));
	}

	For my surprise, for order = 4 I got the following output:

	Page count of page 0 is 1
	Page address: 0xe00000003c1e0000
	Page count of page 1 is 0
	Page address: 0xe00000003c1e4000
	Page count of page 2 is 0
	Page address: 0xe00000003c1e8000
	Page count of page 3 is 0
	Page address: 0xe00000003c1ec000

	Only the first page got it page counter incremented. Is this expected?
As far as I understand, if page_count is 0 the page is free.
	Looking at page_alloc, I found set_page_refs (below), and it really
sets the page count only for the first page for machines with MMU.
	I'm confused... are these pages really allocated to me?

	I'm running kernel 2.6.8-rc3 on a IPF machine.

	Thanks in advance for any help!

	Luciano Stertz


static inline void set_page_refs(struct page *page, int order)
{
#ifdef CONFIG_MMU
     set_page_count(page, 1);
#else
     int i;

     /*
      * We need to reference all the pages for this order, otherwise if
      * anyone accesses one of the pages with (get/put) it will be freed.
      */
     for (i = 0; i < (1 << order); i++)
         set_page_count(page+i, 1);
#endif /* CONFIG_MMU */
}



-- 
Luciano A. Stertz
luciano@tteng.com.br
T&T Engenheiros Associados Ltda
http://www.tteng.com.br
Fone/Fax (51) 3224 8425

--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
