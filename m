Received: from e1.ny.us.ibm.com (s1 [10.0.3.101])
	by admin.ny.us.ibm.com. (8.9.3/8.9.3) with ESMTP id JAA116290
	for <linux-mm@kvack.org>; Mon, 16 Apr 2001 09:17:20 -0400
Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e1.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id JAA140110
	for <linux-mm@kvack.org>; Mon, 16 Apr 2001 09:16:57 -0400
Received: from d01ml233.pok.ibm.com (d01ml233.pok.ibm.com [9.117.200.63])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.96) with ESMTP id JAA65518
	for <linux-mm@kvack.org>; Mon, 16 Apr 2001 09:12:58 -0400
Subject: Linux MXT support code (long posting,  part 1 of 2)
Message-ID: <OF98B326E1.C4873631-ON85256A2E.005B86EF@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Mon, 16 Apr 2001 09:18:28 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Greetings,

I am posting here a description of the Memory Expansion Technology (MXT)
and the Linux MXT support patch for a review by the linux-mm community.
To save bandwidth I am not posting the patch itself, but would rather
point you to the URL

     http://oss.software.ibm.com/pub/mxt/patch-2.4.3-md7

This email is part 1 of 2 describing the MXT hardware.
Part 2 describes the software design of the Linux MXT support patch.

Comments and contributions are welcome. Please feel free to send me
email if you have specific questions.   There are also web pages
dedicated to MXT related stuff at

http://oss.software.ibm.com/developerworks/opensource/mxt/

Thanks

Bulent Abali
abali@us.ibm.com



Intro
---------
MXT is a hardware technology for compressing main memory contents.
MXT doubles the effective size of the main memory.  For example
512 MB installed memory appears as 1 GB.  This is done entirely in
hardware, transparent to the CPUs, I/O devices, peripherals and
all software including apps, device drivers and the kernel
with the exception of less than hundred lines of code additions
to the base 2.4 kernel.

A memory controller called the Pinnacle chipset from ServerWorks Inc
incorporates MXT (for x86 platforms.)  ServerWorks, IBM, another
well-known computer company, and a motherboard company are
working to create systems based on the Pinnacle chipset.


Motivation
----------
Memory seems to be cheap.  Why bother with MXT to double the
sizeof memory?

Simply put, MXT saves money and lots of money.
Memory is not really cheap, especially when your system
uses 512 MB or more.  Try the on-line price configurators of
Compaq, IBM, Dell, etc to double the size of your system memory.
Going from 512MB to 1GB adds about $1200 U.S and going from
1GB to 2GB adds about $2500 to the cost of a typical low-end server.
Memory prices are very volatile and depend on the phase of the
moon and whom you buy memory from, but in any case MXT will save
money because the incremental cost of the MXT chipset
is estimated to be in the $100 range.

Yet another consideration is the density of the DIMMs.
A typical low-end system has 4 DIMM slots. If your system needs more
memory, then you need to use higher density DIMMs which cost tons
of money.  512MB and 1GB DIMMs are lot more expensive than 256 MB
DIMMs on a price-per-megabyte basis.  In another (rather extreme)
example,  there are no reasonably priced 2 GB DIMMs to get
to a 8 GB system with 4 dimm slots.  You need to buy a "high-end"
server with more than 4 dimm slots but those boxes cost lot of
money.   MXT will give you
the 8 GB effective size in only four slots with four 1 GB dimms.

In summary, MXT gives you a price/performance advantage.  You can
either double the performance by 2x memory expansion OR you can
use half the amount of memory you would have normally used and get
the same kind of performance at a lesser cost.


Hardware Description
--------------------
MXT is incorporated in to the memory/cache controller chipset. The
controller sits on the Intel 133 MHz front side bus and services
memory requests just as any other memory controller.  The difference
here is that this memory controller has a built-in
compression/decompression circuitry.  It compresses data before
writing to the main memory and decompresses in the other direction.
The compression block size is 1 kilobytes.
Since compression/decompression latency of 1 KB blocks is relatively
long, to absorb this latency the controller is augmented with a 32 MB
(yes, megabyte) third level (L3) cache which contains uncompressed data.
Most of the memory accesses occur to L3;  benchmarks show that L3
has a typical hit ratio of 98 percent or more.  The L3 cache is made
of double data rate (DDR) SDRAM.  The main memory uses standard
off-the-shelf 133 MHz SDRAM.

The MXT compression scheme stores compressed data blocks to the
(compressed) main memory in a variable length format.  The unit
of storage in the main memory is a 256 byte sector.  Depending on its
compressibility, a 1 KB block in the L3 cache
may occupy 0 to 4 sectors in the main memory.
An address translation is made to go from 1 KB block address
to the main memory address by a lookup of the Compression
Translation Table (CTT).  CTT is in a reserved location in the
main memory and it is maintained by the memory controller.
Each 1 KB block's real address (i.e. address on the front
side bus of PIII) maps to one CTT entry which is 16 bytes long.
A CTT entry contains four address pointers each pointing to a 256
byte sector in the (compressed) main memory.  For example, a 1 KB
data block which compresses by a factor of two will occupy only two
sectors in the compressed memory (512 bytes) and the CTT entry will
contain two addresses pointing to those sectors.  The remaining two
pointers will be NULL.

If the line is very compressible, for example if it contains all zeros,
it will use no sectors at all.  Instead, the compressed
data will be stored in the CTT entry itself (which is 16 bytes long).
So in the best case, for example a 4 KB page filled with zeros will
occupy only 64 bytes in the memory!  One good thing about this
stuff is that all of the operations are performed by the memory
controller with no software intervention at all. Standard hardware
parts, peripherals and software run as-is with no changes at all.

There is a set of nifty hardware functions called "fast page
operations".  The memory controller exposes them via some memory
mapped control registers.  A fast-page-op clears or moves a 4 KB
page instantly, about 8 to 10 times faster than a Pentium III
using memset or memcpy.   This is possible because
fast-page-ops do not really move bulk data as processor does.
Instead, fast-page-ops update the pointers in the CTT entries.
Clearing a 4KB page is merely setting few bits in the 16 byte CTT
entry and replacing the sector pointers with a compression code-word
which says "this 4KB page contains all zeros" :-)  Likewise,
moving a 4 KB page is merely updating few CTT entries.

We benchmarked the fast zero page op in the 2.2 kernel, by re#defining
clear_bigpage(), hence copy_cow_page() in mm/memory.c would use
fast zeroing instead of memset.
We then observed that kernel could fork large memory processes
2.5 times faster because kernel must clear cow pages before handing
them out to the processes.  There are quite a few places that the 2.4
kernels can be speeded up using fast-page-ops.  However, I will
leave its discussion to another time.


Performance Impact and Compressibility
--------------------------------------
We ran few CPU benchmarks to measure impact of L3 cache.
We found that L3 has a negligible
performance impact due to its relatively large size (32MB)
Benchmarks showed that when working set fit in L3, they
ran slighlty faster on MXT boxes than on the standard boxes
due to the Double Data Rate (DDR) SDRAM used in the L3 cache.
If the working set of the benchmark
didn't fit in the L3 cache, then the MXT system ran slightly slower.
However, in either case, the performance impact of L3 was negligible.
There are few reports detailing these benchmarks at URLs [1,2]

Benchmarks with large memory requirements benefitted from MXT
significantly since memory size was doubled.
A database benchmark ran in 66% shorter time on
a 1 GB MXT enabled memory (2 GB effective) over a standard system
with 1 GB memory.  We also ran a well known webserver benchmark on
an MXT box with the TUX 2.0 webserver.
We observed that the webserver throughput doubled due to the
2x effective memory size.  See the URL [3] below
for a chart summarizing this benchmarking exercise and also
see some cost comparisons.

So, how compressible are the main memory contents?  We have
overwhelming data indicating that generally the main memory
contents are 2x compressible or better.  We sampled memory
contents of quite a few systems running different apps and
benchmarks and found that they compress better than 2X.
We mirrored contents of about dozen web sites and found that
2x compression is generally the rule.  See the report [2] below
for this data.

Those in the know immediately raise the issue of compressed
GIF and JPEG files that exist on a typical webserver today.  Since
graphics files are already compressed, they jump to the conclusion
that memory contents of a typical web server cannot be further
compressed.
Measurements do not support this conclusion.  It all depends
on the file sizes.  GIFs and JPEGs found on web servers are
typically small files, smaller than the 4 KB page size in i386.
We think that due to fragmentation in the memory (since files
are memory mapped) even a 100 byte file occupies 4 KB and ends
up being very compressible.  To verify this we populated file
system with hundreds of thousands of 100 byte size incompressible
files.  We then copied these files to /dev/null to bring them in
the page cache.  We then measured that the compressibility of the
main memory is 4.4x (compared to 1.0 expected compressibility!)
So, it appears that when these small files are brought in to the
memory they take up more than 100 bytes because of their associated
filesystem structures, page fragmentation, and all the other
crud that comes off the disk due to the minimum 1 KB disk transfer
size.  The report in URL [2] explains this observation in more
detail.  Perhaps someone with the filesystem expertise have a
better explanation.

If you want to see the compressibility of your own system try the
graphical monitor xcompress available at URL [4].
Xcompress opens /dev/mem and samples the main memory contents and
estimates system compressibility, as if this was an MXT box.
It produces a number between 0.0 to 1.0.  Smaller is better.
For example 0.5 means that memory is compressible by a factor
of 2 (1/0.5).  Please post your results here or send it to me and
I will post it on the website for everybody to see.

[1] http://oss.software.ibm.com/developerworks/opensource/mxt/
[2]
http://oss.software.ibm.com/developerworks/opensource/mxt/publications/mxtperformance.pdf
[3]
http://oss.software.ibm.com/developerworks/opensource/mxt/publications/mxtpriceperf.pdf
[4]
http://oss.software.ibm.com/developerworks/opensource/mxt/tools/xcompress.tar.gz



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
