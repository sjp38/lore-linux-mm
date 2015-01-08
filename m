Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id E75C96B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 17:49:47 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id ij19so2149681vcb.8
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 14:49:47 -0800 (PST)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com. [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id y6si3557221vck.27.2015.01.08.14.49.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 14:49:46 -0800 (PST)
Received: by mail-vc0-f178.google.com with SMTP id hq11so2172894vcb.9
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 14:49:46 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 8 Jan 2015 14:49:45 -0800
Message-ID: <CAA25o9Sf62u3mJtBp_swLL0RS2Zb=EjZtWERJqyrbBpk7-bP-A@mail.gmail.com>
Subject: mm performance with zram
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I am taking a closer look at the performance of the Linux MM in the
context of heavy zram usage.  The bottom line is that there is
surprisingly high overhead (35-40%) from MM code other than
compression/decompression routines.  I'd like to share some results in
the hope they will be helpful in planning future development.

SETUP

I am running on an ASUS Chromebox with about 2GB RAM (actually 4GB,
but with mem=1931M).  The zram block device size is approx. 2.8GB
(uncompressed size).

http://www.amazon.com/Asus-CHROMEBOX-M004U-ASUS-Desktop/dp/B00IT1WJZQ

Intel(R) Celeron(R) 2955U @ 1.40GHz
MemTotal:        1930456 kB
SwapTotal:       2827816 kB

I took the kernel from Linus's tree a few days ago: Linux localhost
3.19.0-rc2+ (...) x86_64.  I also set maxcpus=1.  The kernel
configuration is available if needed.

EXPERIMENTS

I wrote a page walker (historically called "balloon") which allocates
a lot of memory, more than physical RAM, and fills it with a dump of
/dev/mem from a Chrome OS system running at capacity.  The memory
compresses down to about 35%.  I ran two main experiments.

1. Compression/decompression.  After filling the memory, the program
touches the first byte of all pages in a random permutation (I tried
sequentially too, it makes little difference).  At steady state, this
forces one page decompression and one compression (on average) at each
step of the walk.

2. Decompression only.  After filling the memory, the program walks
all pages sequentially.  Then it frees the second half of the pages
(the ones most recently touched), and walks the first half.  This
causes one page decompression at each step, and almost no
compressions.

RESULTS

The average time (real time) to walk a page in microseconds is

experiment 1 (compress + decompress): 26.5  us/page
experiment 2 (decompress only): 9.3 us/page

I ran "perf record -ag"during the relevant parts of the experiment.
(CAVEAT: the version of perf I used doesn't match the kernel, it's
quite a bit older, but that should be mostly OK).  I put the output of
"perf report" in this Google Drive folder:

https://drive.google.com/folderview?id=0B6kmZ3mOd0bzVzJKeTV6eExfeFE&usp=sharing

(You shouldn't need a Google ID to access it.  You may have to re-join
the link if the plain text mailer splits it into multiple lines.)

I also tried to analyze cumulative graph profiles.  Interestingly the
only tool I found to do this is gprof2dot (any other suggestion?  I
would prefer a text-based tool).  The output is in the .png files in
the same folder.  The interesting numbers are:

experiment 1
compression 43.2%
decompression 20.4%
everything else 36.4%

experiment 2
decompression 61.7%
everything else 38.3%

The graph profiles don't seem to show low-hanging fruits on any path.

CONCLUSION

Before zram, in a situation involving swapping, the MM overhead was
probably nearly invisible, especially with rotating disks.  But with
zram the MM is surprisingly close to being the main bottleneck.
Compression/decompression speeds will likely improve, and they are
tuneable (tradeoff between compression ratio and speed).  Compression
can happen often in the background, so decompression speed is more
important for latency, and LZ4 decompression can already be a lot
faster than LZO (the experiments use LZO, and LZ4 can be 2x faster).
This suggests that simplifying and speeding up the relevant code paths
in the Linux MM may be worth the effort.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
