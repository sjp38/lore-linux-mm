Received: from edt.com (IDENT:root@calapooia [198.107.47.151])
	by jones.edt.com (8.9.3/8.9.3) with ESMTP id NAA06365
	for <linux-mm@kvack.org>; Thu, 5 Oct 2000 13:55:54 -0700 (PDT)
Message-ID: <39DCEAE9.BDEA23BD@edt.com>
Date: Thu, 05 Oct 2000 13:56:09 -0700
From: Steve Case <steve@edt.com>
MIME-Version: 1.0
Subject: map_user_kiobuf and 1 Gb (2.4-test8)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm working on a device driver module for our PCI interface cards which
attempts to map user memory for DMA. I was pleased to find the
map_user_kiobuf function and its allies, since this appears to do
exactly what I need. Everything worked fine, until I sent it to a
customer who has a system w/  1 Gb of memory - it locked up real good as
soon as he tried DMA. After making sure we had the same software -
2.4-test8, with the CONFIG_HIGHMEM4G flag set, two pentium IIIs, etc. we
discovered that everything worked if he pulled a DIMM and went to 768M.
The actual amount of memory used by his test remained fairly small.

In the driver I use map_user_iobuf with the user space address, then
cycle through the maplist filling in a scatter-gather list:

/* scatter - gather list */
struct {
    u_int addr;
    u_int size;
} sg;

size=0;
while (size < xfersize)
    {

                 sg.addr =
virt_to_bus(page_address(iobuf.maplist[entrys]));

/* deal with page crossings */

                 if ((u_int)sg.addr & (PAGE_SIZE - 1))
                    thissize = PAGE_SIZE - ((u_int)sg.addr & (PAGE_SIZE
- 1)) ;
                else
                    thissize= PAGE_SIZE;

                if (size + thissize > xfersize)
                        thissize = xfersize - size ;

/* set scatter-gather element size */
                   sg.size = thissize;

                    size += thissize;

    }

The scatter-gather list itself is allocated using kmalloc(); the bus
address is retrieved using virt_to_bus(). We present our card with the
bus address of the scatter-gather list, from which it does DMA to get
the address/size pairs. This works fine for < 1Gb. So, either the
map_user_iobuf function is giving me a bad (unmapped) address, or
kmalloc/virt_to_bus is breaking down at 1Gb.

Are there any obvious gotchas about using kiobuf in systems >= 1 GB?

Thanks,

Steve Case
Engineering Design Team
steve@edt.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
