Received: from mail.cs.tu-berlin.de (root@mail.cs.tu-berlin.de [130.149.17.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA07862
	for <Linux-MM@kvack.org>; Mon, 26 Oct 1998 06:52:14 -0500
Received: from faun.cs.tu-berlin.de (pokam@faun.cs.tu-berlin.de [130.149.31.105])
	by mail.cs.tu-berlin.de (8.9.1/8.9.1) with ESMTP id MAA18628
	for <Linux-MM@kvack.org>; Mon, 26 Oct 1998 12:44:15 +0100 (MET)
From: Gilles Pokam <pokam@cs.tu-berlin.de>
Received: (from pokam@localhost)
	by faun.cs.tu-berlin.de (8.9.1/8.9.0) id MAA12564
	for Linux-MM@kvack.org; Mon, 26 Oct 1998 12:44:11 +0100 (MET)
Message-Id: <199810261144.MAA12564@faun.cs.tu-berlin.de>
Subject: mmap() for a cluster of pages
Date: Mon, 26 Oct 1998 12:44:11 +0100 (MET)
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm trying to developp my own driver. The problem is that i have to use a 
large amount of contiguous memory. For this purpose, in the __get_free_pages()
function, i use an order of 4 (for example).

I have implemented the mmap(), nopage(), open() and release() operations of 
the vma and file structures. Like mentionned in the book of Alessandro Rubini,
"Device Driver for Linux", when using more than one page size, the mmap()
is only able to mmap the first page of a page cluster.

I have tried to play with the usage count of the page, but i didn't succeed.
The problem is that, i don't think i have well understand what happens whith 
the usage count when a page cluster is mapped ! 

That is how i was thinking:
 I use __get_free_pages to allocates the memory, so the usage count of the 
 first page in the cluster is already incremented to 1, the rest are zero. 
 When mmap() calls the nopage() method to retrieve the faulting address, the 
 later also increments the usage count of the first page (count = 2).After
 that, by the next call, the whole block is unloaded because the count of the 
 other page are 0. So i have tried to increment the usage count of the other 
 page in the open() method, before the nopage() as been called due to a 
 faulting address, but it didn't help me! 

 What happens exactly by the call of the mmap() ? Which steps are involved and
 which function increments or decrements the usage count ? 

 I know for example that the whole block is unloaded after the first call 
 because the usage count of the other page are somewhere dropped to zero 
 (by the munmap ??), but i don't know when this step occurs during the mmap() 
 call.

 I will be very honor to receive some information about it.

  Thanx,
 
-- 
/_/_/_/_/_/_/_/_/_/_/_/_/_//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/ 
  POKAM TIENTCHEU Gilles,                                     
  Technical University Berlin            | Room : FR 2068
  Secretariat FR 2-2                     | Voice: 030 - 314 73116
  Franklinstrasse 28/29 , D-10587 Berlin  | Email: pokam@cs.tu-berlin.de
/_/_/_/_/_/_/_/_/_/_/_/_/_//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
