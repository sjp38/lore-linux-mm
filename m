Message-ID: <385A3DF0.7B82AE33@bbcom-hh.de>
Date: Fri, 17 Dec 1999 14:43:12 +0100
From: Peter Wurbs <wurbs@bbcom-hh.de>
MIME-Version: 1.0
Subject: Limitation of buffer allocation
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I am new to linux and his internals.
Thus sorry for my popular  technical description.

we deal with an streaming application, whereby some streams of data are
received via a high speed network interface card and  written to the
hard disk. Alle data are only written once and later processed.
By means of "vmstat 1" we found out, that all available free memory is
allocated for buffer cache. Allocation starts, when first data are
received and written to the disk. Allocation ends until about 1 MB is
left free.
This kind of allocation is a big problem for the driver of the network
interface card. It allocates memory dynamically by means of "alloc_skb".

If there is a ad-hoc requierement of a bigger memory block, this
function seems to be unable to take away memory from the buffer cache.
Thus alloc_skb returns null pointer, because it must be invoked with
flag "GFP_ATOMIC" (sudden return if there is no memory available). As a
result the driver runs into a faulty deadlocked state.
We work with kernel 2.2.13.
Furthermore we found out that the limitation of memory allocation for
the buffer cache solves the problem. If there is about 2 MB memory left
free for the driver, it never runs into the problem.
We tested some ways to limit buffer allocation:
1)
A tiny user program allocates permanent memory and frees it immediately.

The user program takes the memory from the buffers. Thus it is available

for the driver.
It is straightforward with unknown side effects, but it works.
2)
We changed the values in /proc/sys/vm/freepages.
The min value is the memory space, reserved for the kernel and thus for
the driver. This space can't allocated for buffers.
Increasing the values reserves more space for the kernel. It works too,
and seems to be a fine solution.
3)
We tried to change the values in /proc/sys/vm/buffermem. (Values are
described in /usr/src/linux/Documentation/proc.txt )
But these values dont have any influence on the buffer allocation. Why?

Any comments?

Do you see problems in changing the values in /proc/sys/vm/freepages?
Is there any other solution?

Thanks in advance and bye,


Peter.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
