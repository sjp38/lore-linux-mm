Date: Thu, 16 Nov 2000 18:03:06 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: BOUNCE linux-mm: Admin request (fwd)
Message-ID: <Pine.LNX.3.96.1001116180302.25130A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


---------- Forwarded message ----------
Date: Thu, 16 Nov 2000 15:55:16 -0500
From: owner-linux-mm@kvack.org
To: owner-linux-mm@kvack.org
Subject: BOUNCE linux-mm: Admin request

>From ttabi@interactivesi.com Thu Nov 16 15:55:16 2000
Received: from jump-isi.interactivesi.com ([207.8.4.2]:1523 "HELO
        dinero.interactivesi.com") by kanga.kvack.org with SMTP
	id <S131172AbQKPUzI>; Thu, 16 Nov 2000 15:55:08 -0500
Received: (qmail 12288 invoked from network); 16 Nov 2000 20:56:20 -0000
Received: from one.interactivesi.com (ttabi@10.2.247.106)
  by dinero.interactivesi.com with SMTP; 16 Nov 2000 20:56:20 -0000
Date:   Thu, 16 Nov 2000 14:56:18 -0600
From:   Timur Tabi <ttabi@interactivesi.com>
To:     Linux MM mailing list <linux-mm@kvack.org>,
        Linux Kernel Mailing list <linux-kernel@vger.kernel.org>
Subject: help parsing free_area_struct in 2.2
X-Mailer: The Polarbar Mailer (pbm 1.17b)
Message-Id: <20001116205513Z131172-224+10@kanga.kvack.org>
Return-Path: <ttabi@interactivesi.com>
X-Orcpt: rfc822;linux-mm@kvack.org

I've written a driver which parses the free_area_t structure in 2.4 to
manipulate the list of free physical memory blocks.  I do this because my
driver needs to allocate a block of memory of a particular size at a particular
physical address.  This code works pretty well in 2.4.

I'm now trying to port this code to 2.2.  For 2.2, I needed to patch the kernel
to export various objects like the free_area array and the add_mem_queue()
function.  I expected the free memory manager in 2.2 to be just a simplified
version of 2.4, but something's wrong.

When I parse the linked list of free memory blocks in 2.4, I get large lists of
free areas, such as 10-15 blocks of order 6, and another dozen blocks of order
7, and so on.  However, when I parse the same structures in 2.2, I rarely get
more than 2 blocks of any order.

Let me be more specific.  In 2.2, we have these structures:

struct free_area_struct {
	struct page *next;
	struct page *prev;
	unsigned int * map;
	unsigned long count;
};

static struct free_area_struct free_area[NR_MEM_TYPES][NR_MEM_LISTS];

It appears to me that free_area is a two-dimensional array of linked lists.
The first dimension is the memory type: 0 is normal memory and 1 is DMA.  The
2nd dimension is the order, e.g. free_area[0][2] contains a linked list of free
memory blocks in normal memory, each of order 2 (16KB) in size.

Am I interpreting this data structure wrong?



-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
