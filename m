Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TM1fZJ014247
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:01:41 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TM1fnj486880
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:01:41 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TM1fem002354
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:01:41 -0400
Subject: Re: Selective swap out of processes
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1188410818.9682.2.camel@bastion-laptop>
References: <1188320070.11543.85.camel@bastion-laptop>
	 <46D4DBF7.7060102@yahoo.com.au>  <1188383827.11270.36.camel@bastion-laptop>
	 <1188410818.9682.2.camel@bastion-laptop>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 15:01:39 -0700
Message-Id: <1188424899.28903.135.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Javier Cabezas =?ISO-8859-1?Q?Rodr=EDguez?= <jcabezas@ac.upc.edu>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I need the same basic thing for process checkpoint/restart.  I just have
a syscall to which I give a virtual address, and then have the kernel
try to swap it out.  It uses follow_page(FOLL_GET) and find_vma() in the
higher-level function, but this appears to work just fine.

I meant this as a horrible hack to play with a couple of months ago, but
it hasn't quite broken on me, yet.  


diff -puN mm/vmscan.c~ptrace-force-swap1 mm/vmscan.c
--- lxc/mm/vmscan.c~ptrace-force-swap1  2007-03-15 11:21:06.000000000 -0700
+++ lxc-dave/mm/vmscan.c        2007-03-15 13:03:57.000000000 -0700
@@ -614,6 +614,23 @@ static unsigned long shrink_page_list(st        return nr_reclaimed;    
 } 
 
+int try_to_put_page_in_swap(struct page *page)
+{
+
+       get_page(page);
+       if (page_count(page) == 1)
+                /* page was freed from under us. So we are done. */
+                return -EAGAIN;
+       lock_page(page);
+       if (PageWriteback(page))
+               wait_on_page_writeback(page);
+       try_to_unmap(page, 0);
+       //printk("page mapped: %d\n", page_mapped(page));
+       unlock_page(page);
+       put_page(page);
+       return 0;
+}      
+
 /*     
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
