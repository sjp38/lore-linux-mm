Received: from scs.ch (nutshell.scs.ch [212.254.229.150])
	by mail.scs.ch (8.11.2/8.11.2) with ESMTP id f8ADCVf28987
	for <linux-mm@kvack.org>; Mon, 10 Sep 2001 15:12:32 +0200
Message-ID: <3B9CBC3D.7B6509DF@scs.ch>
Date: Mon, 10 Sep 2001 15:12:29 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Memory managment locks
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
   

I am writing a kernel thread, that should check if a process' page (specified by a virtual address and the pointer to a task structure) is present in physical memory, and
if this is the case pin it in memory (i.e. prevent it from being swapped out). I plan to pin the page by incrementing it's usage count (i.e. the count field of the
corresponding page descriptor) - this is the way map_user_kiobuf() pins pages in memory. I have some questions about semaphores and spinlocks to be used, when accessing a
process' mm structure and page tables:

(1) To parse a process' page tables I need to hold the page_table_lock in the process' mm_struct structure (according to A.Rubini's device driver book,
http://www.xml.com/ldd/chapter/book/ch13.html). I still need to keep the lock held while incrementing the page's usage count (according to various comments throughout the
kernel sources, page_table_lock prevents kswapd() from swapping out pages of the process). Question: Are there other spinlocks or semaphores to be held during the
operations I mentioned?

(2) When is the semaphore mmap_sem in the mm_struct structure to be held? When is the alloc_lock spinlock in the task_struct structure to be held?

(3) When multiple locks / semaphores have to be acquired, is there any rule concerning the order in which they should be acquired to prevent dead locks?

(4) Why isn't page_table_lock a read/write spinlock (is there any reason to prevent several threads from scanning a process' page table simultaneously)?

Thanks in advance for any help
Martin

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
