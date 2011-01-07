Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E95676B00C3
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 17:06:11 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 7 Jan 2011 17:03:47 -0500
Subject: [RFC][PATCH 0/2] Tunable watermark
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

This patchset introduces a new knob to control each watermark
separately.

[Purpose]
To control the timing at which kswapd/direct reclaim starts(ends)
based on memory pressure and/or application characteristics
because direct reclaim makes a memory alloc/access latency worse.
(We'd like to avoid direct reclaim to keep latency low even if
 under the high memory pressure.)

[Problem]
The thresholds kswapd/direct reclaim starts(ends) depend on
watermark[min,low,high] and currently all watermarks are set
based on min_free_kbytes. min_free_kbytes is the amount of
free memory that Linux VM should keep at least.

This means the difference between thresholds at which kswapd
starts and direct reclaim starts depends on the amount of free
memory.

On the other hand, the amount of required memory depends on
applications. Therefore when it allocates/access memory more
than the difference between watemark[low] and watermark[min],
kernel sometimes runs direct reclaim before allocation and
it makes application latency bigger.

[Solution]
To avoid the situation above, this patch set introduces new
tunables /proc/sys/vm/wmark_min_kbytes, wmark_low_kbytes and
wmark_high_kbytes. Each entry controls watermark[min],
watermark[low] and watermark[high] separately.
By using these parameters one can make the difference between
min and low bigger than the amount of memory which applications
require.

[Example]
This is an example of the problem and solution above.

- System Memory: 2GB
- High memory pressure

In this case, min_free_kbytes and watermarks are automatically
set as follows.
(Here, watermark shows sum of the each zone's watermark.)

min_free_kbytes: 5752
watermark[min] : 5752
watermark[low] : 7190
watermark[high]: 8628

If application allocates/accesses 2000 kbytes memory (bigger
than 1438(=3D 7190 - 5752)), direct reclaim may occur.

By introducing this patch, one can set watermark[low] to bigger
than 7752 which makes the difference between min and low bigger
than 2000. This results in avoidance of direct reclaim without
changing watermark[min].

[Test]
I ran a simple test like below:

System memory: 2GB

$ dd if=3D/dev/zero of=3D/tmp/tmp_file &
$ time mapped-file-stream 1 $((1024 * 1024 * 64))

The result is following.

                  | default |  case 1   |  case 2 |
----------------------------------------------------------
wmark_min_kbytes  |  5752   |    5752   |   5752  |
wmark_low_kbytes  |  7190   |   16384   |  32768  | (KB)
wmark_high_kbytes |  8628   |   20480   |  40960  |
----------------------------------------------------------
real              |   503   |    364    |    337  |
user              |     3   |      5    |      4  | (msec)
sys               |   153   |    149    |    146  |
----------------------------------------------------------
page fault        |  32768  |  32768    |  32768  |
kswapd_wakeup     |   1809  |    335    |    228  | (times)
direct reclaim    |      5  |      0    |      0  |

As you can see, direct reclaim was performed 5 times and
its exec time was 503 msec in the default case. On the other
hand, in case 1 (large delta case ) no direct reclaim was
performed and its exec time was 364 msec.

(*) mapped-file-stream
     This is a micro benchmark from Johannes Weiner that accesses a
     large sparse-file through mmap().
     http://lkml.org/lkml/2010/8/30/226

Any comments or suggestions are welcome	.


Satoru Moriya (2):
  Add explanation about min_free_kbytes to clarify its effect
  Make watermarks tunable separately

 Documentation/sysctl/vm.txt |   40 +++++++++++++++-
 include/linux/mmzone.h      |    6 ++
 kernel/sysctl.c             |   28 +++++++++++-
 mm/page_alloc.c             |  109 +++++++++++++++++++++++++++++++++++++++=
++++
 4 files changed, 181 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
