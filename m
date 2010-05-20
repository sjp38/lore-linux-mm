Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9734460032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 16:11:59 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d5f2b269-4215-4f28-a396-763b44c63265@default>
Date: Thu, 20 May 2010 13:10:43 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: frontswap performance vs swap-to-ramdisk
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com, Avi Kivity <avi@redhat.com>, Pavel Machek <pavel@ucw.cz>, hughd@google.com, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

SUMMARY: frontswap is (unexpectedly) about 5% faster
than swap-to_RAM.  Speedup is largely due to the fact
that ramswap goes through the block I/O layer and
frontswap does not.

ramswap, with frontswap: 65.73s (stddev=3D6.5)
ramswap, no frontswap:   69.07s (stddev=3D9.0)
(100 test runs of each)

My conclusion is that the block I/O layer is expensive
(and irrelevant) for hypervisor-swap-to-RAM.  Some parallel
asynchronous mechanism that batches multiple swap-to-RAM
requests might be written which might be similar to but
more efficient (for RAM) than the existing block layer.
But, lacking that, the existing synchronous page-at-a-time
design is a better match than a batching asynchronous design
for frontswap and thus for hypervisor-swap-to-RAM.

DETAIL (long):

A couple of weeks ago in the lengthy thread discussing the
proposed frontswap patch (http://lkml.org/lkml/2010/4/22/174),
Pavel asked for a performance comparison between frontswap and
swap-to-ram (http://lkml.org/lkml/2010/5/2/80)

I replied that I expected frontswap to be a bit slower
because it is entirely dynamic and requires hypercalls,
whereas ramswap would be swapping to a known-fixed-size
pre-allocated area in kernel RAM.  Note that the
dynamicity of frontswap is a critical functionality...
the hypervisor decides dynamically for every single
page-to-be-swapped if there is hypervisor RAM available
or not, thus allowing it to do "intelligent overcommitment".
So, even if it were a bit slower, frontswap has functionality
that can't be obtained from ramswap.

Working with input from Nitin Gupta, I created a
simple benchmark to allocate a fixed amount of memory
(controlled by a parameter "N"), write to it, and
read it back to ensure it contained the expected values.
Then I used the ramdisk_size=3D262144 kernel parameter
to get a 256M disk.  For each run of the benchmark,
I raw-overwrite the ramdisk with dd, recreate the
ramswap with mkswap, and swapon it.  (During the
benchmark, no other swap is enabled.)  I then time the
benchmark.  Oddly, even though all swapping is going to RAM
(as can be confirmed via iostat), there is anomalous
behavior with a very large percentage of "iowait" time.
(For more on this see Appendix below.)

For any given system RAM size, I manually vary "N"
until I find a size that causes some significant swapping
to the ramdisk to occur, but not so large that any OOM'ing
ever occurs.

I tested everything on bare metal Linux (RHEL6 beta), but
to compare apples-to-apples vs frontswap, I need to run it
in a virtual machine on Xen.  I chose a 2.6.32 pv_ops
kernel (PV, not in a VMX container) with 768M of memory
of which 256M will be dedicated to the ramswap.
For frontswap runs, I limit the hypervisor memory available
to 256M.  I also ensured that cleancache was not running
so as to eliminate any other memory management deltas.
Since even normal swapping has lots of wait time and
since apples-to-apples requires hypervisor time to
also be accounted for, I measure elapsed time (not
user+sys) with the VM in single-user mode.  No other
activity is running on the physical machine and there
is no I/O in the benchmark so, after the benchmark is
loaded, there is no I/O component to be measured.
Since I saw a fair amount of variability in individual
measurements (both with frontswap and ramswap), I
made 100 runs to obtain both a good mean and standard
deviation.

Frontswap is a "fronting store" even for a ramswap so
the number of pages read and written to ramswap vs
frontswap should be identical.  The only differences
should be:
1) where the data is written -- hypervisor RAM vs
   kernel RAM
2) hypercall overhead for frontswap vs. block device
   overhead for ramswap
3) implementation differences between frontswap-in-Xen
   and ramswap-in-Linux (e.g. tree manipulation for
   tracking the pages, memory allocation protocols, etc)

Interestingly, both the frontswap implementation in
Xen and the ramswap implementation in Linux use
radix trees to insert/lookup the pages so this
is yet one fewer difference.

So with 100 runs of each, the results are:

ramswap, with frontswap: 65.73s (stddev=3D6.5)
ramswap, no frontswap:   69.07s (stddev=3D9.0)

My conclusion is that the block I/O layer is expensive
(and irrelevant) for hypervisor-swap-to-RAM.  Some parallel
asynchronous mechanism that batches multiple swap-to-RAM
requests might be written which might be similar to but
more efficient (for RAM) than the existing block layer.
But, lacking that, the existing synchronous page-at-a-time
design is a better match than a batching asynchronous design
for frontswap and for hypervisor-swap-to-RAM.

APPENDIX:

I was surprised at the large amount of I/O wait time
(>90-95%) spent when swapping to RAM.  Note that it was
observed on bare metal as well as in a VM. At first, I
thought (hoped? :-) that it was due to the block layer, but
since frontswap skips this layer and still has a large I/O
wait time, this theory was incorrect.  As an experiment,
I measured the exact same benchmark with the same
parameters with a disk as swap instead of ramswap
and got the following results (also 100 runs):

diskswap, with frontswap: 65.64s (stddev=3D6.1)
diskswap, no frontswap: 70.93s (stddev=3D7.0)

While one would expect the frontswap numbers to be
virtually identical since the exact sequence of events
should occur (with frontswap acting as a "fronting store",
all swaps go to hypervisor RAM regardless of the device),
the comparison of diskswap to ramswap with NO frontswap
was jaw-dropping.  Clearly something in the swap subsystem
is tuned for rotating disks instead of for faster
non-rotating devices!  Digging a bit, I found
the recently added swap code intended for special
casing solid-state devices and tracked that to its
source.  I guessed that adding:

queue_flag_set_unlocked(QUEUE_FLAG_NONROT,disk->queue)

in brd_alloc (in drivers/block/brd.c, the ramdisk
module) might inform the swap subsystem that it
shouldn't do whatever tuning it was doing for disks.
Unfortunately, this didn't make any difference.
This makes me wonder if swap to SSD (or swap to
ramzswap) is going to be any faster than swap-to-disk!
Clearly, other threads can use the CPU (and I/O)
when the swap subsystem is twiddling its thumbs,
but when memory pressure is nearly to the breaking
point, one would think that there would be an
urgency to get swap pages out of memory!

So... if anyone reads this far and has any ideas on
how to "tune" the swap subsystem better for ramdisk
(and SSD), I can try to rerun the numbers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
