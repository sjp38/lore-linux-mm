Received: from hermes.rz.uni-sb.de (hermes.rz.uni-sb.de [134.96.7.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA03378
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 16:29:59 -0500
Received: from sbustd.stud.uni-sb.de (V6MmrBZq1AFNnjwKd5TnZszaSKO66+mw@eris.rz.uni-sb.de [134.96.7.8])
	by hermes.rz.uni-sb.de (8.8.8/8.8.7/8.7.7) with ESMTP id WAA13739
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 22:29:53 +0100 (CET)
Received: from clmsdev (acc3-75.telip.uni-sb.de [134.96.127.75])
          by sbustd.stud.uni-sb.de (8.8.8/8.8.5) with SMTP
	  id WAA15885 for <linux-mm@kvack.org>; Mon, 1 Feb 1999 22:29:51 +0100 (CET)
Message-ID: <004401be4e29$fb998300$c80c17ac@clmsdev>
From: "Manfred Spraul" <masp0008@stud.uni-sb.de>
Subject: Ramdisk for > 1GB / >2 GB
Date: Mon, 1 Feb 1999 22:25:54 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've written a ramdisk driver that can use physical, unmapped memory. I've
posted a beta version this morning to linux-kernel.
Basically, it is a kernel patch that manages the memory (alloc_hugemem(),
free_hugemem()), and a block device driver that can use this memory.

I'm new in the Linux MM, perhaps you could help me on these questions:

1) SMP:
I use a spinlock for every ramdisk, and one page for each drive as a window
to the physical memory. Since only 1 processor uses this page, I can use
__flush_tlb_one( == INVLPG only on the local processor) without any further
synchronization.
Is that stable on SMP, and do you think that this parallel enough?
Linus suggested using one 4MB pte for each processor, but I think that this
would be to much overhead.
Another idea would be using a hash table (eg. 32 spinlocks, 32 pages) that
is shared by all processors.

2) I can't make the driver a module because I use 'pgt_offset_k()' to
traverse the page tables, but init_mm is not exported.
Is there any other way how I can find the pte_t that belongs to my page?

3) Is more than 2 GB memory a problem that only applies to the i386
architecture, or is there demand for that on PowerPC, Sparc32?

Regards,
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
