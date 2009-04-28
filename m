Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4F9056B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 02:35:57 -0400 (EDT)
Date: Mon, 27 Apr 2009 23:36:25 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: Swappiness vs. mmap() and interactive response
Message-ID: <20090428063625.GA17785@eskimo.com>
References: <20090428044426.GA5035@eskimo.com> <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 02:35:29PM +0900, KOSAKI Motohiro wrote:
> (cc to linux-mm and Rik)
> 
> > Hi,
> > 
> > So, I just set up Ubuntu Jaunty (using Linux 2.6.28) on a quad core phenom box,
> > and then I did the following (with XFS over LVM):
> > 
> > mv /500gig/of/data/on/disk/one /disk/two
> > 
> > This quickly caused the system to. grind.. to... a.... complete..... halt.
> > Basically every UI operation, including the mouse in Xorg, started experiencing
> > multiple second lag and delays.  This made the system essentially unusable --
> > for example, just flipping to the window where the "mv" command was running
> > took 10 seconds on more than one occasion.  Basically a "click and get coffee"
> > interface.
> 
> I have some question and request.
> 
> 1. please post your /proc/meminfo
> 2. Do above copy make tons swap-out? IOW your disk read much faster than write?
> 3. cache limitation of memcgroup solve this problem?
> 4. Which disk have your /bin and /usr/bin?

I'll answer these out of order if you don't mind.

2. Do above copy make tons swap-out? IOW your disk read much faster than write?

The disks should be roughly similar.  However:

sda is the read disk, sdb is the write.  Here's a few snippets from iostat -xm 10

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await  svctm  %util
sda              67.70     0.00  373.10    0.20    48.47     0.00   265.90     1.94    5.21   2.10  78.32
sdb               0.00  1889.60    0.00  139.80     0.00    52.52   769.34    35.01  250.45   5.17  72.28
---
sda               5.30     0.00  483.80    0.30    60.65     0.00   256.59     1.59    3.28   1.65  79.72
sdb               0.00  3632.70    0.00  171.10     0.00    61.10   731.39   117.09  709.66   5.84 100.00
---
sda              51.20     0.00  478.10    1.00    65.79     0.01   281.27     2.48    5.18   1.96  93.72
sdb               0.00  2104.60    0.00  174.80     0.00    62.84   736.28   108.50  613.64   5.72 100.00
--
sda             153.20     0.00  349.40    0.20    60.99     0.00   357.30     4.47   13.19   2.85  99.80
sdb               0.00  1766.50    0.00  158.60     0.00    59.89   773.34   110.07  672.25   6.30  99.96

This data seems to indicate the IO performance varies, but the reader is usually faster.

4. Which disk have your /bin and /usr/bin?

sda, the reader.

3. cache limitation of memcgroup solve this problem?

I was unable to get this to work -- do you have some documentation handy?

1. please post your /proc/meminfo

$ cat /proc/meminfo 
MemTotal:        3467668 kB
MemFree:           20164 kB
Buffers:             204 kB
Cached:          2295232 kB
SwapCached:         4012 kB
Active:           639608 kB
Inactive:        2620880 kB
Active(anon):     608104 kB
Inactive(anon):   360812 kB
Active(file):      31504 kB
Inactive(file):  2260068 kB
Unevictable:           8 kB
Mlocked:               8 kB
SwapTotal:       4194296 kB
SwapFree:        4186968 kB
Dirty:            147280 kB
Writeback:          8424 kB
AnonPages:        961280 kB
Mapped:            39016 kB
Slab:              81904 kB
SReclaimable:      59044 kB
SUnreclaim:        22860 kB
PageTables:        20548 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     5928128 kB
Committed_AS:    1770348 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      281908 kB
VmallocChunk:   34359449059 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       44928 kB
DirectMap2M:     3622912 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
