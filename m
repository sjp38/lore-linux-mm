Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i9Q2PHNo001307
	for <linux-mm@kvack.org>; Mon, 25 Oct 2004 19:25:17 -0700 (PDT)
Date: Mon, 25 Oct 2004 19:24:59 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: [RFC/Patch]Making Removable zone[0/4]
Message-Id: <20041025160642.690F.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

This patch set is to make new zone (Hotremovable) for 
memory hotplug to create area which is removed relatively easily.
I made this patch set 2 month ago,
but I thought this patch set has many problem,
so I was worried whether it should be posted for a long time.

However I'm feeling its time become too long. 
So, I post this to ask which is better way.
If you have any suggestions, please tell me.



This patches make Hotremovable attribute as orthogonal against
DMA/Normal/Highmem. So, there will be six zones
(DMA/Normal/Highmem/ Removable DMA/ Removable Normal/ 
 Removable Highmem).
However, this orthogonal attribute is cause of problems like 
followings....

  1) Zone Id bits in page->flags must be extended from 2 to 3
     to make 6 zones. However, there is not enough space in it.
  2) Array size of zonelist for 6 zones might be too big.
     (Especially, when there are a lot of numbers of nodes)
  3) Index of zonelist array is decided by __GFP_xxx bit. So,
     index must be power of 2. But, GFP_Removable can be set with
     GFP_HIGHMEM or GFP_DMA. (not power of 2).
  4) Some of kernel codes assume that order of Zone's index is
     DMA -> Normal -> Highmem. 
     But removable attribute will break its order.
  5) Zonelist order must be also changed. 
     Which is better zonelist order? 
     a) Removable Highmem -> Removable Normal -> Removable DMA
        -> Highmem -> Normal -> DMA
     b) Removable Highmem -> Highmem -> Removable Normal -> Normal 
        -> Removable DMA -> DMA

If the kind of zone is just 4 types like DMA/Normal/Highmem/Removable
(Not orthogonal), some of these problems become easy.
And I suppose 4) and 5) imply more codes like mem_molicy
must be changed.

But 6 zones code has an advantage for hotplug of kernel memory.
If an component of kernel can become hot-removable, 
probably it would like to use "Horemovable DMA" or
"Hotremovable Normal".
So, I also worried which type of removable zone is better.


These patch set is old, but they can be applied against 2.6.9-mm1.
Please comment.

Bye.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
