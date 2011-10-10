Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1AB9C6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 09:07:31 -0400 (EDT)
Date: Mon, 10 Oct 2011 21:07:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
Message-ID: <20111010130722.GA11387@localhost>
References: <20111003134228.090592370@intel.com>
 <1318248846.14400.21.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318248846.14400.21.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org

On Mon, Oct 10, 2011 at 08:14:06PM +0800, Peter Zijlstra wrote:
> On Mon, 2011-10-03 at 21:42 +0800, Wu Fengguang wrote:
> > This is the minimal IO-less balance_dirty_pages() changes that are expected to
> > be regression free (well, except for NFS).
> 
> I can't seem to get around reviewing these patches in detail, but fwiw
> I'm fine with pushing fwd with this set (plus a possible NFS fix).
> 
> I don't see a reason to strip it down even further.
> 
> So I guess that's:
> 
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Thanks :-) In fact you've already reviewed the major parts of the
patchset in great details and helped simplify parts of the algorithm,
which I appreciate a lot.

As for the NFS performance, the dd tests show that adding a writeback
wait queue to limit the number of NFS PG_writeback pages (patches
will follow) is able to gain 48% throughput in itself:

      3.1.0-rc8-ioless6+         3.1.0-rc8-nfs-wq+  
------------------------  ------------------------  
                   22.43       +81.8%        40.77  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   28.21       +52.6%        43.07  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   29.21       +55.4%        45.39  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                   14.12       +40.4%        19.83  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   29.44       +11.4%        32.81  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                    9.09      +240.9%        30.97  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                   25.68       +84.6%        47.42  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   41.06        +7.6%        44.20  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                   39.13       +25.9%        49.26  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                  238.38       +48.4%       353.72  TOTAL

Which will result in 28% overall improvements over the vanilla kernel:

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+  
------------------------  ------------------------  
                   20.89       +95.2%        40.77  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   39.43        +9.2%        43.07  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   26.60       +70.6%        45.39  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                   12.70       +56.1%        19.83  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   27.41       +19.7%        32.81  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                   26.52       +16.8%        30.97  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                   40.70       +16.5%        47.42  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   45.28        -2.4%        44.20  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                   35.74       +37.8%        49.26  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                  275.28       +28.5%       353.72  TOTAL

As for the most concerned NFS commits, the wait queue patch increases
the (nr_commits / bytes_written) ratio by +74% for the thresh=1G,10dd
case, +55% for the thresh=100M,10dd case, and mostly ignorable in the
other 1dd, 2dd cases, which looks acceptable.

The other noticeable change of the wait queue is, the RTT time per
write is reduced by 1-2 order(s) in many of the below cases (from
dozens of seconds to hundreds of milliseconds).

Thanks,
Fengguang
---

PS. mountstats numbers

thresh=1GB
==========

1dd

vanilla        WRITE: 33108 33108 0 13794766688 4502688 89550800 1826162 91643336
ioless6        WRITE: 104355 104355 0 12824990824 14192280 1677501539 13497260 1691407074
nfs-wq         WRITE: 58632 58632 0 13635750848 7973952 148662395 4735943 153535047

vanilla       COMMIT: 29 29 0 3248 3712 45210 191022 236235
ioless6       COMMIT: 26 26 0 2912 3328 32875 196848 229725
nfs-wq        COMMIT: 35 35 0 3920 4480 1156 223393 224550

2dd

vanilla        WRITE: 28681 28681 0 11507024952 3900616 178242698 5849890 184288501
ioless6        WRITE: 151075 151075 0 12192866408 20546200 3195004617 5748708 3200969292
nfs-wq         WRITE: 89925 89925 0 15450966104 12229800 212096905 3443883 215849660

vanilla       COMMIT: 43 43 0 4816 5504 45252 349816 396792
ioless6       COMMIT: 52 52 0 5824 6656 40798 376099 417068
nfs-wq        COMMIT: 66 66 0 7392 8448 10854 490021 502373

10dd

vanilla        WRITE: 47281 47281 0 14044390136 6430216 1378503679 11994453 1390582846
ioless6        WRITE: 35972 35972 0 7959317984 4892192 1205239506 7412186 1212670083
nfs-wq         WRITE: 49625 49625 0 14819167672 6749000 10704223 4135391 14876589

vanilla       COMMIT: 235 235 0 26320 30080 328532 1097793 1426737
ioless6       COMMIT: 128 128 0 14336 16384 73611 388716 462470
nfs-wq        COMMIT: 431 432 0 48384 55168 217056 1775499 1993006


thresh=100MB
============

1dd

vanilla        WRITE: 28858 28858 0 12427843376 3924688 6384263 2308574 8722669
nfs-wq         WRITE: 206620 206620 0 13104059680 28100320 90597897 10245879 101016004

vanilla       COMMIT: 250 250 0 28000 32000 27030 229750 256786
nfs-wq        COMMIT: 267 267 0 29904 34176 4672 247504 252184

2dd

vanilla        WRITE: 32593 32593 0 8382655992 4432648 193667999 3611697 197302564
nfs-wq         WRITE: 98662 98662 0 14025467856 13418032 183280630 5381343 188715890

vanilla       COMMIT: 272 272 0 30464 34816 24445 295949 320576
nfs-wq        COMMIT: 584 584 0 65408 74752 1318 483049 484442

10dd

vanilla        WRITE: 32294 32294 0 6651515344 4391984 104926130 8666874 113596871
nfs-wq         WRITE: 27571 27571 0 12711521256 3749656 6129491 2248486 8385102

vanilla       COMMIT: 825 825 0 92400 105600 82135 739763 822179
nfs-wq        COMMIT: 2449 2449 0 274288 313472 6091 2057767 2064555

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
