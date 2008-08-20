Date: Wed, 20 Aug 2008 20:05:51 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 0/2] Quicklist is slighly problematic.
Message-Id: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Cristoph,

Thank you for explain your quicklist plan at OLS.

So, I made summary to issue of quicklist.
if you have a bit time, Could you please read this mail and patches?
And, if possible, Could you please tell me your feeling?


--------------------------------------------------------------------

Now, Quicklist store some page in each CPU as cache.
(Each CPU has node_free_pages/16 pages)

and it is used for page table cache.
Then, exit() increase cache, the other hand fork() spent it.

So, if apache type (one parent and many child model) middleware run,
One CPU process fork(), Other CPU process the middleware work and exit().

At that time, One CPU don't have page table cache at all,
Others have maximum caches.

	QList_max = (#ofCPUs - 1) x Free / 16
	=> QList_max / (Free + QList_max) = (#ofCPUs - 1) / (16 + #ofCPUs - 1)

So, How much quicklist spent memory at maximum case?
That is #CPUs proposional because it is per CPU cache but cache amount calculation doesn't use #ofCPUs.

	Above calculation mean

	 Number of CPUs per node            2    4    8   16
	 ==============================  ====================
	 QList_max / (Free + QList_max)   5.8%  16%  30%  48%


Wow! Quicklist can spent about 50% memory at worst case.
More unfortunately, it doesn't have any cache shrinking mechanism.
So it cause some wrong thing.

1. End user misunderstand to memory leak happend.
	=> /proc/meminfo should display amount quicklist

2. It can cause OOM killer
	=> Amount of quicklists shouldn't be proposional to #ofCPUs.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
