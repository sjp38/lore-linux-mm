Message-ID: <A33AEFDC2EC0D411851900D0B73EBEF766DC67@NAPA>
From: Hua Ji <hji@netscreen.com>
Subject: RE: Running out of vmalloc space
Date: Thu, 17 May 2001 11:51:49 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>What are the implications of making such a change?  Will it work when
>there is less or more memory in the system?  Should this be a
>configurable kernel parameter?

My 2 cents:

By default, linux kernel space starts from PAGE_OFFSET, which is 0xC0000000.
In other words,
All the kernel can only have 1G memory left for usage, if/when under a 32bit
CPU.

Even with the 1G left, the cake left for vmalloc is much less than the 1G.
Kernel
will map the PAGE_OFFSET~PAGE_OFFSET+physical_memory for kmalloc usage. The
real start point for
vmalloc is high_memory + 8M(this is a hole). 

Hence, we can understand that the virtual address left for vmalloc is really
small.

For example, if your machine has a physical memory of 256M. And then your
vmalloc can only manage
(1G-256M-8M) space.

If we go through the get_vma_area that is called by vmalloc(), we will find
this:

------------------------------------------
addr = VMALLOC_START;
.....

 if (addr > VMALLOC_END-size) {	 
			kfree(area);
			return NULL;
		}
------------------------------------------

Therefore, it is very possible that your driver codes can't find **big
enough hole** in the vmlist, which
is a global linked list for maintaining all the vm_struct data structures.

For enlarging the managed memory, you can try this:

* change the PAGE_OFFSET to 0x80000000(for example) from 0xC000000. Then you
will have 1G extra memory managable:-). However, the side effect is: your
user level tasks can only range from 0x0 to 0x8000000(2G).



Wish helpful,

Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
