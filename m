Message-ID: <396C9188.523658B9@sangate.com>
Date: Wed, 12 Jul 2000 18:40:56 +0300
From: Mark Mokryn <mark@sangate.com>
MIME-Version: 1.0
Subject: map_user_kiobuf problem in 2.4.0-test3
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-scsi@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Here's the scenario:
2.4.0-test3 SMP build running on a single 800MHz PIII (Dell GX-300)
After obtaining a mapping to a high memory region (i.e. either
PCI memory or physical memory reserved by passing mem=XXX to the kernel
at boot), I am trying to write a raw device with data in the mapped
region.
This fails, with map_user_kiobuf spitting out "Mapped page missing"
The raw write works, of course, if the mapping is to a kmalloc'ed
buffer.

I have tried the above with 2.2.14 SMP, and it works, so something in
2.4 is broken.
On another interesting note: The raw devices I'm writing to are Fibre
Channel drives controlled by a Qlogic 2200 adapter (in 2.2.14 I'm using
the Qlogic driver). When writing large sequential blocks to a single
drive, I reached 8MB/s when the memory was mapped to the high reserved
region, while CPU utilization was down to about 5%. When the mapping was
to PCI space, I was able to write at only 4MB/s, and CPU utilization was
up to 60%! This is very strange, since if the transfer rate was for some
unknown reason lower in the case of PCI (vs. high physical memory), then
one would expect the CPU utilization to be even lower, since the adapter
performs DMA. But instead, the CPU is sweating... So, it appears that
there's a problem in 2.2.14 as well, when the mapping is to PCI space...
Additionally, the max transfer rate of 8MB/s seems rather slow - don't
know why yet...

-Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
