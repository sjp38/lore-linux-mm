Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 37A786B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 16:51:42 -0400 (EDT)
Date: Tue, 31 Mar 2009 22:52:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-ID: <20090331205215.GA9137@random.random>
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <1238457560-7613-2-git-send-email-ieidus@redhat.com> <1238457560-7613-3-git-send-email-ieidus@redhat.com> <1238457560-7613-4-git-send-email-ieidus@redhat.com> <1238457560-7613-5-git-send-email-ieidus@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1238457560-7613-5-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, dmonakhov@openvz.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello,

I attach below some benchmark of the new ksm tree algorithm, showing
ksm performance in best and worst case scenarios.

-----------------------------------------------------------
Here a program ksmpages.c that tries to create the worst case scenario
for the ksm tree algorithm.

-----------------------------------------------------------
/* ksmpages.c: exercise KSM (C) Red Hat Inc. GPL'd */

#include <stdlib.h>
#include <malloc.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include "ksm.h"

#define SIZE (1UL*1024*1024*1024)

#define PAGE_SIZE 4096
#define PAGES (SIZE/PAGE_SIZE)

int ksm_register_memory(char * p)
{
	int fd;
	int ksm_fd;
	int r = 1;
	struct ksm_memory_region ksm_region;
 
	fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
	if (fd == -1)
		goto out;
 
	ksm_fd = ioctl(fd, KSM_CREATE_SHARED_MEMORY_AREA);
	if (ksm_fd == -1)
		goto out_free;
 
	ksm_region.npages = PAGES;
	ksm_region.addr = (unsigned long) p;
	r = ioctl(ksm_fd, KSM_REGISTER_MEMORY_REGION, &ksm_region);
	if (r)
		goto out_free1;
 
	return r;
 
out_free1:
	close(ksm_fd);
out_free:
	close(fd);
out:
	return r;
}

int main(void)
{
	unsigned long page;
	char *p = memalign(PAGE_SIZE, PAGES*PAGE_SIZE);
	if (!p)
		perror("memalign"), exit(1);

	if (ksm_register_memory(p))
		printf("failed to register into ksm, run inside VM\n");
	else
		printf("registered into ksm, run outside VM\n");

	for (page = 0; page < PAGES; page++) {
		char *ppage;
		ppage = p + page * PAGE_SIZE +
			PAGE_SIZE - sizeof(unsigned long);
		*(unsigned long *)ppage = page;
	}

	pause();

	return 0;
}
-----------------------------------------------------------

ksmpages exercises ksm tree algorithm worst case where pages are all
equal except for the last bytes, so the memcmp breaks after having
accessed the worst-case amount of memory (i.e. almost 4096 bytes for
each level of the stable or unstable tree).

Top after running the first copy of ksmpages:

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
16473 andrea    20   0 1027m 1.0g  328 S    0 25.9   0:01.14 ksmpages

Below is "vmstat 1" while running a second copy with kksmd running at
100% CPU load:

-----------------------------------------------------------
 1  0   3104 2806044  60256  45532    0    0     0     0  912  338  0 25 74  0
 1  0   3104 2805700  60256  45532    0    0     0     0  676  171  0 27 73  0
 1  0   3104 2805452  60264  45524    0    0     0    36  708  172  0 23 77  0
 1  0   3104 2806428  60264  45532    0    0     0     0  787  210  0 25 75  0
 1  0   3104 2806212  60264  45524    0    0     0     0  643  132  0 25 75  0
 1  0   3104 2805864  60264  45524    0    0     0     0  685  157  0 27 73  0
 1  0   3104 2805616  60264  45524    0    0     0     0  640  128  0 23 77  0
 1  0   3104 2805368  60264  45524    0    0     0     0  637  131  0 25 75  0
 1  0   3104 2804996  60280  45508    0    0     0    76  704  165  0 25 75  0
 2  0   3104 2804748  60280  45524    0    0     0     0  636  131  0 27 73  0
 1  0   3104 2804500  60280  45524    0    0     0     0  641  133  0 23 77  0

Here the second copy of ksmpages is started.

 2  0   3104 2660544  60280  45524    0    0     0     0  711  178  0 28 72  0
 1  0   3104 1754096  60280  45524    0    0     0     0  839  172  1 47 53  0

1G of ram has been allocated and initialized by ksmpages.

 1  0   3104 1753848  60280  45524    0    0     0     0  632  122  0 27 73  0
 1  0   3104 1753328  60280  45524    0    0     0     0  661  167  0 23 77  0
 1  0   3104 1753104  60280  45524    0    0     0     0  635  129  0 25 75  0
 1  0   3104 1752856  60280  45524    0    0     0     0  635  127  0 25 75  0
 1  0   3104 1752608  60280  45524    0    0     0     0  677  158  0 27 73  0
 1  0   3104 1752360  60280  45524    0    0     0     0  636  132  0 23 77  0
 1  0   3104 1752112  60280  45524    0    0     0     0  638  133  0 25 75  0
 1  0   3104 1751864  60280  45524    0    0     0     0  665  149  0 25 75  0

It takes around 8 seconds for kksmd to complete a full scan of the 1G
indexed in the unstable tree plus the refresh of the checksum of the
whole 2G registered.

 1  0   3104 1758944  60280  45524    0    0     0     0  649  122  0 27 73  0
 1  0   3104 1772316  60280  45524    0    0     0     0  660  128  0 23 77  0
 1  0   3104 1784668  60280  45524    0    0     0     0  711  159  0 25 75  0
 1  0   3104 1796252  60280  45524    0    0     0     0  669  138  0 25 75  0
 1  0   3104 1807908  60280  45524    0    0     0     0  653  124  0 27 73  0
 1  0   3104 1819044  60280  45524    0    0     0     0  677  148  0 23 77  0
 1  0   3104 1829684  60280  45524    0    0     0     0  649  131  0 25 75  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0   3104 1840324  60280  45524    0    0     0     0  653  131  0 25 75  0
 1  0   3104 1850840  60280  45524    0    0     0    96  734  158  0 27 73  0
 1  0   3104 1861132  60280  45524    0    0     0     0  645  133  0 23 77  0
 1  0   3104 1871424  60280  45524    0    0     0     0  639  129  0 25 75  0
 1  0   3104 1881716  60280  45524    0    0     0     0  676  147  0 25 75  0
 1  0   3104 1891736  60280  45524    0    0     0     0  649  122  0 27 73  0
 1  0   3104 1901656  60280  45524    0    0     0     4  656  137  0 23 77  0
 1  0   3104 1911576  60280  45524    0    0     0     0  682  162  0 25 75  0
 1  0   3104 1921496  60280  45524    0    0     0     0  642  128  0 25 75  0
 1  0   3104 1931292  60280  45524    0    0     0     0  630  126  0 27 73  0
 1  0   3104 1941064  60280  45524    0    0     0     0  676  152  0 23 77  0
 1  0   3104 1950760  60284  45520    0    0     0    24  667  136  0 25 75  0
 1  0   3104 1960160  60284  45524    0    0     0     0  649  129  0 25 75  0
 1  0   3104 1969584  60284  45524    0    0     0     0  671  145  0 27 73  0
 1  0   3104 1978736  60284  45524    0    0     0     0  643  128  0 23 77  0
 1  0   3104 1988036  60284  45524    0    0     0     0  638  127  0 25 75  0
 1  0   3104 1997212  60284  45524    0    0     0     0  674  156  0 25 75  0
 1  0   3104 2006240  60284  45524    0    0     0     0  632  124  0 27 73  0
 1  0   3104 2016204  60284  45524    0    0     0     0  636  128  0 23 77  0
 1  0   3104 2028452  60284  45524    0    0     0     0  691  156  0 25 75  0
 1  0   3104 2040728  60284  45524    0    0     0     0  657  133  0 25 75  0
 1  0   3104 2053004  60284  45524    0    0     0     0  660  128  0 27 73  0
 1  0   3104 2065428  60284  45524    0    0     0     0  686  153  0 23 77  0
 1  0   3104 2077680  60284  45524    0    0     0     0  660  127  0 25 75  0
 1  0   3104 2089264  60284  45524    0    0     0     0  656  127  0 25 75  0
 2  0   3104 2100796  60284  45524    0    0     0     0  670  148  0 27 73  0
 1  0   3104 2112476  60284  45524    0    0     0     0  652  138  0 23 77  0
 1  0   3104 2123884  60284  45524    0    0     0     0  641  129  0 25 75  0
 1  0   3104 2135516  60284  45524    0    0     0     0  674  151  0 25 75  0
 1  0   3104 2147196  60284  45524    0    0     0     0  645  126  0 27 73  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0   3104 2158704  60284  45524    0    0     0     0  650  128  0 23 77  0
 1  0   3104 2170236  60284  45524    0    0     0     0  697  177  0 25 75  0
 1  0   3104 2181620  60284  45524    0    0     0     0  650  130  0 25 75  0
 1  0   3104 2192532  60284  45524    0    0     0     0  639  122  0 27 73  0
 1  0   3104 2203444  60284  45524    0    0     0     0  670  145  0 23 77  0
 1  0   3104 2214356  60284  45524    0    0     0     0  631  127  0 25 75  0
 1  0   3104 2225268  60284  45524    0    0     0     0  630  134  0 25 75  0
 1  0   3104 2235488  60284  45524    0    0     0     0  669  153  0 27 73  0
 1  0   3104 2245780  60284  45524    0    0     0     0  633  132  0 23 77  0
 1  0   3104 2255924  60284  45524    0    0     0     0  632  141  0 25 75  0
 1  0   3104 2265448  60284  45524    0    0     0     0  657  144  0 25 75  0
 1  0   3104 2274452  60284  45524    0    0     0     0  626  129  0 27 73  0
 1  0   3104 2286224  60284  45524    0    0     0     0  661  130  0 23 77  0
 1  0   3104 2297980  60284  45524    0    0     0     0  675  156  0 25 75  0
 1  0   3104 2309760  60284  45524    0    0     0     0  654  128  0 25 75  0
 1  0   3104 2321540  60284  45524    0    0     0     0  629  122  0 27 73  0
 1  0   3104 2333468  60284  45524    0    0     0     0  696  166  0 23 77  0
 1  0   3104 2344952  60284  45524    0    0     0     0  638  129  0 25 75  0
 1  0   3104 2356088  60284  45524    0    0     0     0  631  127  0 25 75  0
 1  0   3104 2367272  60284  45524    0    0     0     0  639  150  0 27 73  0
 1  0   3104 2378432  60284  45524    0    0     0     0  633  132  0 23 77  0
 1  0   3104 2389468  60284  45524    0    0     0     0  622  132  0 25 75  0
 1  0   3104 2400628  60284  45524    0    0     0     0  677  154  0 25 75  0
 1  0   3104 2411664  60284  45524    0    0     0     0  628  122  0 27 73  0
 1  0   3104 2422824  60284  45524    0    0     0     0  639  128  0 23 77  0
 1  0   3104 2433984  60284  45524    0    0     0     0  653  148  0 25 75  0
 1  0   3104 2444700  60284  45524    0    0     0     0  627  133  0 25 75  0
 1  0   3104 2455264  60284  45524    0    0     0     0  634  128  0 27 73  0
 1  0   3104 2465656  60284  45524    0    0     0     0  678  155  0 23 77  0
 1  0   3104 2476220  60284  45524    0    0     0     0  631  131  0 25 75  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0   3104 2486760  60284  45524    0    0     0     0  641  139  0 25 75  0
 1  0   3104 2496756  60284  45524    0    0     0     0  651  148  0 27 73  0
 1  0   3104 2506676  60284  45524    0    0     0     0  630  130  0 23 77  0
 1  0   3104 2516448  60284  45524    0    0     0     0  631  127  0 25 75  0
 1  0   3104 2525848  60284  45524    0    0     0     0  676  154  0 25 75  0
 1  0   3104 2534752  60284  45524    0    0     0     0  625  122  0 27 73  0
 1  0   3104 2546720  60284  45524    0    0     0     0  665  145  0 23 77  0
 1  0   3104 2559864  60284  45524    0    0     0     0  700  158  0 25 75  0
 1  0   3104 2573008  60284  45524    0    0     0     0  671  127  0 25 75  0
 1  0   3104 2586028  60284  45524    0    0     0     0  681  126  0 27 73  0
 1  0   3104 2599024  60284  45524    0    0     0     0  681  145  0 23 77  0
 1  0   3104 2611772  60284  45524    0    0     0     0  662  132  0 25 75  0
 1  0   3104 2624320  60284  45524    0    0     0     0  668  129  0 25 75  0
 1  0   3104 2636844  60284  45524    0    0     0     0  698  152  0 27 73  0
 1  0   3104 2649368  60284  45524    0    0     0     0  665  128  0 23 77  0
 1  0   3104 2661892  60284  45524    0    0     0     0  660  127  0 25 75  0
 1  0   3104 2674268  60284  45524    0    0     0     0  695  161  0 25 75  0
 1  0   3104 2686816  60284  45524    0    0     0     0  652  124  0 27 73  0
 1  0   3104 2699192  60284  45524    0    0     0     0  667  128  0 23 77  0
 1  0   3104 2711220  60284  45524    0    0     0     0  696  161  0 25 75  0
 1  0   3104 2723224  60284  45524    0    0     0     0  653  132  0 25 75  0
 1  0   3104 2735128  60284  45524    0    0     0     0  650  127  0 27 73  0
 1  0   3104 2747156  60284  45524    0    0     0     0  700  154  0 23 77  0
 1  0   3104 2758640  60284  45524    0    0     0     0  662  127  0 25 75  0
 1  0   3104 2770172  60284  45524    0    0     0     0  671  127  0 25 75  0
 1  0   3104 2781432  60284  45524    0    0     0     0  685  150  0 27 73  0
 1  0   3104 2792196  60284  45524    0    0     0     0  663  135  0 23 77  0
 1  0   3104 2799308  60284  45524    0    0     0     0  662  148  0 24 76  0
 1  0   3104 2799416  60284  45524    0    0     0     0  700  213  0 21 78  0

It takes kksmd 96 seconds to merge 1G of ram in the absolute worst
case which has been created artificially. In the absolute worst case
scenario memory is freed roughly at a rate of 10M/sec.

 1  0   3104 2799416  60284  45524    0    0     0     0  672  193  0 24 76  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0   3104 2799416  60284  45524    0    0     0     0  678  194  0 20 80  0
 1  0   3104 2799416  60284  45524    0    0     0     0  694  219  0 22 78  0
 1  0   3104 2799416  60284  45524    0    0     0     0  673  193  0 22 78  0
 1  0   3104 2799416  60284  45524    0    0     0     0  673  188  0 23 77  0
 1  0   3104 2799416  60284  45524    0    0     0     0  701  217  0 20 80  0
 1  0   3104 2799416  60284  45524    0    0     0     0  677  194  0 22 78  0
 1  0   3104 2799416  60284  45524    0    0     0     0  694  198  0 22 78  0
 1  0   3104 2799416  60284  45524    0    0     0     0  683  212  0 23 77  0
 1  0   3104 2799416  60284  45524    0    0     0     0  675  192  0 20 80  0
 1  0   3104 2799416  60284  45524    0    0     0     0  684  197  0 22 78  0
 1  0   3104 2799416  60284  45524    0    0     0     0  702  213  0 22 79  0
 1  0   3104 2799416  60284  45524    0    0     0     0  671  192  0 23 77  0
 1  0   3104 2799416  60284  45524    0    0     0     0  681  194  0 20 80  0
 1  0   3104 2799416  60284  45524    0    0     0     0  695  219  0 21 79  0
 1  0   3104 2799416  60284  45524    0    0     0     0  682  193  0 22 78  0
 1  0   3104 2799416  60284  45524    0    0     0     0  676  189  0 23 77  0
 1  0   3104 2799416  60284  45524    0    0     0     0  710  223  0 20 80  0
 1  0   3104 2799416  60284  45524    0    0     0     0  681  197  0 22 79  0

Result in top is:

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
16473 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.14 ksmpages
16625 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.01 ksmpages

SHR shows 1G full shared.

Start a new ksmpages:

 1  0   3104 2799292  60424  45544    0    0     0     0  685  185  0 24 76  0
 1  0   3104 2799292  60424  45544    0    0     0     0  699  230  0 21 79  0
 1  0   3104 2799292  60424  45544    0    0     0     0  679  189  0 22 78  0
 1  0   3104 2799292  60424  45544    0    0     0     0  678  196  0 22 78  0
 1  0   3104 2799292  60424  45544    0    0     0     0  704  215  0 19 81  0
 1  0   3104 2797664  60424  45544    0    0     0     0  795  330  1 22 77  0
 1  0   3104 2797516  60424  45548    0    0     0     0  722  276  0 21 79  0
 1  0   3104 2797516  60424  45548    0    0     0     0  706  242  0 23 77  0

Third copy of ksmpages started.

 2  0   3104 2518704  60424  45548    0    0     0     0 4113  228  0 27 73  0
 1  0   3104 1787900  60424  45548    0    0     0     0 13534  195  1 43 56  0

Third copy of ksmpages initialized its 1G of ram.

 1  0   3104 1823500  60424  45548    0    0     0     0  657  151  0 27 73  0
 1  0   3104 1858616  60428  45544    0    0     0    36  801  201  0 25 75  0
 1  0   3104 1893004  60428  45544    0    0     0     0  629  119  0 26 74  0
 1  0   3104 1926212  60428  45544    0    0     0     0  662  166  0 24 76  0
 1  0   3104 1958452  60428  45544    0    0     0     0  626  130  0 24 76  0
 1  0   3104 1988388  60428  45544    0    0     0     0  625  137  0 29 71  0
 1  0   3104 2017080  60428  45544    0    0     0     0  643  156  0 23 77  0
 1  0   3104 2047584  60428  45544    0    0     0     0  622  132  0 27 73  0
 1  0   3104 2077568  60428  45544    0    0     0     0  629  127  0 24 76  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0   3104 2106584  60428  45544    0    0     0     0  677  171  0 23 77  0
 2  0   3104 2135476  60428  45544    0    0     0     0  623  119  0 28 72  0
 1  0   3104 2164392  60428  45544    0    0     0     0  619  137  0 26 74  0
 1  0   3104 2191896  60428  45544    0    0     0     0  637  147  0 23 77  0
 1  0   3104 2219152  60428  45544    0    0     0     0  620  132  0 27 73  0
 1  0   3104 2244920  60428  45544    0    0     0     0  621  126  0 22 78  0
 1  0   3104 2271056  60428  45544    0    0     0     0  666  164  0 26 74  0
 1  0   3104 2303172  60428  45544    0    0     0     0  626  122  0 27 73  0
 1  0   3104 2334892  60428  45544    0    0     0     0  621  132  0 26 74  0
 1  0   3104 2365272  60428  45544    0    0     0     0  642  148  0 23 77  0
 1  0   3104 2395652  60428  45544    0    0     0     0  632  140  0 23 77  0
 1  0   3104 2426008  60428  45544    0    0     0     0  620  122  0 28 72  0
 1  0   3104 2454924  60428  45544    0    0     0     0  665  165  0 23 77  0
 1  0   3104 2483172  60428  45544    0    0     0     0  618  119  0 27 73  0
 1  0   3104 2509536  60428  45544    0    0     0     0  618  132  0 26 74  0
 1  0   3104 2537384  60428  45544    0    0     0     0  660  164  0 22 78  0
 1  0   3104 2567764  60428  45544    0    0     0     0  622  132  0 30 70  0
 1  0   3104 2597524  60428  45544    0    0     0     0  620  119  0 24 76  0
 1  0   3104 2626292  60428  45544    0    0     0     0  639  158  0 24 76  0
 1  0   3104 2654936  60428  45544    0    0     0     0  624  131  0 26 74  0
 1  0   3104 2683704  60436  45536    0    0     0    28  640  151  0 23 77  0
 1  0   3104 2710960  60436  45544    0    0     0     0  673  152  0 26 74  0
 1  0   3104 2737844  60436  45544    0    0     0     0  618  132  0 28 72  0
 1  0   3104 2763364  60436  45544    0    0     0     0  619  123  0 24 76  0
 2  0   3104 2778328  60436  45544    0    0     0     0  657  183  0 23 77  0

This time it took kksmd only 34 seconds to merge the pages and it
started freeing pages immediately. This is because the ksmpages are in
the stable tree now, and they get merged immediately without checksum
overhead, only the worst-case memcmp for each level of the tree runs.

NOTE: the checksum is not used in any way to find equal pages, but
only to avoid filling the unstable tree with frequently changing
pages. In the future the dirty bit in the spte will tell us which
pages are changing frequently and which not in a more efficient way
than the checksum (only problem EPT sptes have no dirty bit). Removing
the checksum would only make the unstable tree more unstable, but it
would have no other downside (unstable tree is unstable anyway, but
it's less unstable than it would be, thanks to the checksum).

 1  0   3104 2778328  60448  45532    0    0     0    56  703  211  0 20 80  0
 1  0   3104 2778328  60448  45544    0    0     0     0  671  199  0 25 75  0
 1  0   3104 2778328  60448  45544    0    0     0     0  702  209  0 20 80  0
 0  0   3104 2778328  60448  45544    0    0     0     0  677  196  0 24 76  0
 1  0   3104 2778328  60448  45544    0    0     0     0  672  189  0 21 79  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0   3104 2778328  60452  45540    0    0     0     4  694  237  0 20 80  0
 1  0   3104 2778328  60452  45544    0    0     0     0  675  189  0 24 76  0
 1  0   3104 2778328  60452  45544    0    0     0     0  676  199  0 23 77  0
 1  0   3104 2778328  60452  45544    0    0     0     0  700  207  0 19 81  0

Top:

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
16473 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.14 ksmpages
16625 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.01 ksmpages
16887 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.02 ksmpages

SHR shows 1g shared for all three tasks.

Start a new copy of ksmpages:

 1  0   3104 2778576  60472  45544    0    0     0     0  702  231  0 22 78  0
 1  0   3104 2778576  60472  45544    0    0     0     0  682  189  0 23 77  0
 1  0   3104 2778576  60472  45544    0    0     0     0  682  213  0 20 80  0
 0  0   3104 2778576  60472  45544    0    0     0     0  699  217  0 21 79  0
 0  0   3104 2778576  60472  45544    0    0     0     0  683  205  0 22 78  0
 1  0   3104 2776800  60472  45544    0    0     0     0  795  327  1 22 77  0
 1  0   3104 2776800  60472  45552    0    0     0     0  724  282  0 21 79  0
 1  0   3104 2776800  60472  45552    0    0     0     0  683  197  0 22 78  0

ksmpages fourth copy is stared here:

 2  0   3104 2305216  60472  45552    0    0     0     0 6015  262  0 34 66  0
 1  0   3104 1772652  60472  45548    0    0     0     0 9988  171  1 42 57  0

ksmpages initialized its ram.

 1  0   3104 1807880  60480  45540    0    0     0    52  657  142  0 23 77  0
 1  0   3104 1841832  60480  45548    0    0     0     0  624  131  0 25 75  0
 1  0   3104 1875660  60480  45548    0    0     0     0  665  162  0 25 75  0
 1  0   3104 1908344  60488  45540    0    0     0    44  636  138  0 27 73  0
 1  0   3104 1940212  60488  45548    0    0     0     0  626  129  0 23 77  0
 1  0   3104 1969732  60488  45548    0    0     0     0  648  150  0 25 75  0
 1  0   3104 1998152  60488  45548    0    0     0     0  622  129  0 25 75  0
 1  0   3104 2028380  60488  45548    0    0     0     0  616  124  0 25 75  0
 2  0   3104 2058044  60488  45548    0    0     0     0  661  162  0 25 75  0
 1  0   3104 2086764  60488  45548    0    0     0     0  617  130  0 25 75  0
 1  0   3104 2115284  60488  45548    0    0     0     0  621  128  0 25 75  0
 1  0   3104 2143928  60488  45548    0    0     0     0  642  148  0 27 73  0
 1  0   3104 2171212  60488  45548    0    0     0     0  623  131  0 23 77  0
 1  0   3104 2198344  60488  45548    0    0     0     0  616  132  0 25 75  0
 1  0   3104 2224016  60488  45548    0    0     0     0  657  157  0 25 75  0
 1  0   3104 2249408  60488  45548    0    0     0     0  614  122  0 27 73  0
 1  0   3104 2281236  60488  45548    0    0     0     0  626  129  0 23 77  0
 1  0   3104 2312808  60488  45548    0    0     0     0  669  159  0 25 75  0
 1  0   3104 2342820  60488  45548    0    0     0     0  622  134  0 25 75  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0   3104 2372976  60488  45548    0    0     0     0  617  122  0 27 73  0
 1  0   3104 2402960  60488  45548    0    0     0     0  652  149  0 23 77  0
 1  0   3104 2431732  60488  45548    0    0     0     0  620  131  0 25 75  0
 1  0   3104 2459808  60488  45548    0    0     0     0  622  135  0 25 75  0
 1  0   3104 2486448  60488  45548    0    0     0     0  659  160  0 27 73  0
 1  0   3104 2513348  60488  45548    0    0     0     0  619  129  0 23 77  0
 1  0   3104 2543328  60488  45548    0    0     0     0  620  129  0 25 75  0
 1  0   3104 2572916  60488  45548    0    0     0     0  652  154  0 25 75  0
 1  0   3104 2601364  60488  45548    0    0     0     0  618  128  0 25 75  0
 1  0   3104 2629884  60488  45548    0    0     0     0  626  140  0 25 75  0
 1  0   3104 2658280  60488  45548    0    0     0     0  653  159  0 25 75  0
 1  0   3104 2685688  60488  45548    0    0     0     0  619  132  0 25 75  0
 1  0   3104 2712720  60488  45548    0    0     0     0  619  126  0 27 73  0
 1  0   3104 2738392  60488  45548    0    0     0     0  643  153  0 23 77  0
 1  0   3104 2758752  60488  45548    0    0     0    24  649  145  0 24 76  0

Again 34 seconds, rate is roughly 30M/sec and there are 262144 pages
queued in the stable tree tree, with memcmp running for 4088 bytes per
page indexed.

 1  0   3104 2758852  60488  45548    0    0     0     0  683  193  0 22 79  0
 1  0   3104 2758852  60488  45548    0    0     0     0  691  212  0 23 76  0
 1  0   3104 2758852  60488  45548    0    0     0     0  673  195  0 20 80  0
 1  0   3104 2758852  60488  45548    0    0     0     0  672  195  0 21 79  0
 1  0   3104 2758852  60492  45544    0    0     0    20  714  223  0 21 79  0
 1  0   3104 2758852  60492  45548    0    0     0     0  680  190  0 23 77  0
 1  0   3104 2758852  60492  45548    0    0     0     0  674  194  0 20 80  0
 1  0   3104 2758852  60492  45548    0    0     0     0  689  222  0 22 78  0

Top:

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
16473 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.14 ksmpages
16625 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.01 ksmpages
16887 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.02 ksmpages
16928 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.03 ksmpages

So on a 4G system, with 4G allocated, we still have 2.7G free.

             total       used       free     shared    buffers     cached
Mem:       4043228    1284304    2758924          0      60500      45548
-/+ buffers/cache:    1178256    2864972
Swap:      5863684       3104    5860580

Now it's time to serially start 8 windows VM taking 1G of ram each,
after a couple of minutes 'vmstat 1' is below:

 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0 102976 1010296   8416 508884    1    3     3    13   10   29  1 23 75  0
 1  0 102976 1035592   8416 508940    0    0     0     0 1939 2661  0 25 74  0
 1  0 102976 1064320   8416 508940    0    0     0     0 1893 2655  0 25 74  0
 1  0 102976 1091948   8416 508940    0    0     0     0 1904 2679  0 25 74  0
 1  0 102976 1120128   8416 508940    0    0     0     0 1878 2653  0 25 74  0
 3  0 102976 1148524   8416 508940    0    0     0     0 1879 2664  0 25 74  0
 1  0 102976 1176820   8420 508940    0    0     0     4 1889 2657  0 25 74  0
 1  0 102976 1204944   8420 508940    0    0     0     0 1872 2674  0 25 74  0
 1  0 102976 1230608   8420 508940    0    0     0     0 1918 2656  0 25 74  0
 1  0 102972 1258372   8428 508936    0    0    40    88 1991 2832  0 25 73  1
 1  0 102972 1263496   8428 508984    0    0     0     0 1673 2770  1 24 75  0
 1  0 102956 1289952   8428 508984    0    0     0     0 1735 2743  0 25 75  0
 1  0 102956 1293576   8428 508992    0    0     0     0 1678 2719  1 24 75  0
 1  0 102944 1290848   8452 509376    0    0     0     0 1610 2692  1 25 74  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0 102944 1293976   8452 509376    0    0     0     0 1648 2720  0 24 75  0
 1  0 102944 1291116   8452 509376    0    0     0     0 1632 2701  1 25 74  0

All VM had most of their memory fully shared.

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
16979 andrea    20   0 1147m 975m 929m S    3 24.7   3:17.55 qemu-system-x86
16473 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.14 ksmpages
16625 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.01 ksmpages
16887 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.02 ksmpages
16928 andrea    20   0 1027m 1.0g 1.0g S    0 25.9   0:01.03 ksmpages
16990 andrea    20   0 1147m 1.0g 967m S    0 25.7   3:16.66 qemu-system-x86
17095 andrea    20   0 1148m 1.0g 976m S    0 26.2   3:21.58 qemu-system-x86
17136 andrea    20   0 1148m 1.0g 977m S    0 26.3   2:43.85 qemu-system-x86
17367 andrea    20   0 1145m 1.0g 981m S    0 26.3   2:29.99 qemu-system-x86
17372 andrea    20   0 1148m 1.0g 980m S    0 26.4   2:27.67 qemu-system-x86
17527 andrea    20   0 1145m 1.0g 979m S    0 26.3   2:25.75 qemu-system-x86
17621 andrea    20   0 1148m 1.0g 979m S    0 26.4   2:26.34 qemu-system-x86

So total 12G are allocated with only 4G of RAM. Around 1G is still
free and very little swap is used.

Now that we're statisfied about the worst case being fully usable
thanks to the O(log(N)) complexity of the ksm tree algorithm (modulo
the checksum load that is O(N) where N is the number of the not shared
pages), I modify the ksmpages like this to exercise the ksm best case
scenario.

-               *(unsigned long *)ppage = page;
+               *(unsigned long *)ppage = 1;

 0  0   5372 3684996  31912 266328    0    0     0     0  612  616  0  0 100  0
 0  0   5372 3684996  31912 266328    0    0     0     0  611  598  0  0 100  0
 0  0   5372 3684996  31912 266328    0    0     0     0  613  615  0  0 100  0
 0  0   5372 3685120  31912 266328    0    0     0     0  610  600  0  0 100  0
 0  0   5372 3685120  31912 266328    0    0     0     0  613  617  0  0 100  0
 0  0   5372 3685120  31912 266328    0    0     0     0  611  599  0  0 100  0

ksmpages best case started.

 2  0   5372 2901972  31912 266328    0    0     0     0  838  280  1 43 56  0
 1  0   5372 2617840  31912 266328    0    0     0     0  692  146  0 32 68  0

ksmpages finishes to initialize its ram.

 1  0   5372 2848932  31920 266320    0    0     0    20  636  154  0 24 76  0
 1  0   5372 3104268  31920 266328    0    0     0     0  619  122  0 26 74  0
 1  0   5372 3363668  31920 266328    0    0     0     0  623  144  0 24 76  0
 1  0   5372 3629688  31920 266328    0    0     0     0  618  124  0 26 74  0

kksmd takes only 4 seconds merge and free 1G of ram because the moment
the single equal page goes in the unstable tree, the memcmp succeeds
immediately and after that all pages are merged into the single page
in the stable tree.

 1  0   5372 3665520  31920 266328    0    0     0     0  647  198  0 21 79  0
 0  0   5372 3665520  31920 266328    0    0     0     0  658  202  0 23 77  0
 1  0   5372 3665520  31920 266328    0    0     0     0  650  206  0 20 80  0
 1  0   5372 3665520  31920 266328    0    0     0     0  647  194  0 22 78  0

A new copy of ksmpages started:

 2  0   5372 3395336  31920 266328    0    0     0     0 30096  234  0 29 71  0
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0   5372 2867512  31920 266328    0    0     0     0 69466  167  1 46 54  0

kksmd now starts to free pages before ksmpages finishes initializing its memory.

 1  0   5372 3104144  31920 266328    0    0     0     0  620  147  0 24 76  0
 1  0   5372 3337104  31920 266328    0    0     0     0  616  117  0 26 74  0
 1  0   5372 3565768  31920 266328    0    0     0     0  619  142  0 24 76  0
 1  0   5372 3645796  31920 266328    0    0     0     0  633  171  0 24 76  0

In 4 seconds all ram is merged again. RAM is freed roughly at 256M/sec
in the best case with stable tree composed of only one page and
unstable tree empty and no checksum computed because of the constant
'stable-tree' match.

 1  0   5372 3645796  31920 266328    0    0     0     0  645  207  0 20 80  0
 1  0   5372 3645796  31920 266328    0    0     0     0  646  201  0 23 77  0
 1  0   5372 3645796  31920 266328    0    0     0     0  659  202  0 20 80  0
 1  0   5372 3645796  31920 266328    0    0     0     0  643  198  0 22 78  0

The rbtree balancing being guaranteed by rb_color despite the unstable
tree pages changing without the tree being updated accordingly,
guarantees that as more pages are added in stable and unstable tree,
the memcmp overhead will increase only logarithmically. The checksum
overhead instead increases linearly with only the amount of pages
present in the unstable tree.

To verify that there is no COW and that pages are mapped readonly in
the pte, we modify ksmpages.c to loop and read all the pages after
the initialization.

/* ksmpages.c: exercise KSM (C) Red Hat Inc. GPL'd */

#include <stdlib.h>
#include <malloc.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include "ksm.h"

#define SIZE (1UL*1024*1024*1024)

#define PAGE_SIZE 4096
#define PAGES (SIZE/PAGE_SIZE)

unsigned long global;

int ksm_register_memory(char * p)
{
	int fd;
	int ksm_fd;
	int r = 1;
	struct ksm_memory_region ksm_region;
 
	fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
	if (fd == -1)
		goto out;
 
	ksm_fd = ioctl(fd, KSM_CREATE_SHARED_MEMORY_AREA);
	if (ksm_fd == -1)
		goto out_free;
 
	ksm_region.npages = PAGES;
	ksm_region.addr = (unsigned long) p;
	r = ioctl(ksm_fd, KSM_REGISTER_MEMORY_REGION, &ksm_region);
	if (r)
		goto out_free1;
 
	return r;
 
out_free1:
	close(ksm_fd);
out_free:
	close(fd);
out:
	return r;
}

int main(void)
{
	unsigned long page;
	char *p = memalign(PAGE_SIZE, PAGES*PAGE_SIZE);
	if (!p)
		perror("memalign"), exit(1);

	if (ksm_register_memory(p))
		printf("failed to register into ksm, run inside VM\n");
	else
		printf("registered into ksm, run outside VM\n");

	for (page = 0; page < PAGES; page++) {
		char *ppage;
		ppage = p + page * PAGE_SIZE +
			PAGE_SIZE - sizeof(unsigned long);
		*(unsigned long *)ppage = page;
	}
	for (;;) {
		long before, after;
		struct timeval tv;
		sleep(1);
		gettimeofday(&tv, NULL);
		before = tv.tv_sec * 1000000 + tv.tv_usec;
		for (page = 0; page < PAGES; page++) {
			char *ppage;
			ppage = p + page * PAGE_SIZE +
				PAGE_SIZE - sizeof(unsigned long);
			global = *(unsigned long *)ppage;
		}
		gettimeofday(&tv, NULL);
		after = tv.tv_sec * 1000000 + tv.tv_usec;
		printf("%d usec\n", after-before);
	}

	pause();

	return 0;
}

7529 usec
7250 usec
7282 usec
7285 usec
7521 usec
7635 usec
7649 usec
7575 usec
7589 usec
7574 usec
7510 usec
7551 usec
7476 usec
7168 usec

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
19123 andrea    20   0 1027m 1.0g 1.0g S    1 25.9   0:02.81 ksmpages
19124 andrea    20   0 1027m 1.0g 1.0g S    1 25.9   0:02.72 ksmpages

The usec taken to read the memory don't change after the merging of
the pages. In fact thanks to sharing the same physical memory,
physically indexed CPU caches could improve application performance.

Here the oprofile including only the start of 2 ksmpages tasks until
they both share the same 1G of ram. Because ksmpages is explicitly
written to exacerbate the absolute worst case of ksm, most of the time
as expected is spent in memcmp_pages that is run to search the stable
and unstable trees.

CPU: Core 2, speed 2003 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        image name               app name                 symbol name
478896   75.8928  ksm.ko                   ksm                      memcmp_pages
38802     6.1491  ksmpages                 ksmpages                 main
28959     4.5893  ksm.ko                   ksm                      kthread_ksm_scan_thread
10643     1.6866  vmlinux-2.6.29           vmlinux-2.6.29           ext2_free_branches
9442      1.4963  vmlinux-2.6.29           vmlinux-2.6.29           nv_adma_qc_prep
8023      1.2714  vmlinux-2.6.29           vmlinux-2.6.29           bit_cursor
6603      1.0464  ksm.ko                   ksm                      get_rmap_item
4887      0.7745  vmlinux-2.6.29           vmlinux-2.6.29           ext2_new_inode
3527      0.5589  vmlinux-2.6.29           vmlinux-2.6.29           ahci_init_one
3012      0.4773  vmlinux-2.6.29           vmlinux-2.6.29           cfb_imageblit
2954      0.4681  vmlinux-2.6.29           vmlinux-2.6.29           register_framebuffer
2092      0.3315  ksm.ko                   ksm                      .text
1505      0.2385  libc-2.8.so              libc-2.8.so              (no symbols)
1425      0.2258  oprofiled                oprofiled                (no symbols)
1208      0.1914  vmlinux-2.6.29           vmlinux-2.6.29           try_to_extend_transaction
1081      0.1713  opreport                 opreport                 (no symbols)
1041      0.1650  libstdc++.so.6.0.8       libstdc++.so.6.0.8       (no symbols)
869       0.1377  vmlinux-2.6.29           vmlinux-2.6.29           pcie_aspm_init_link_state
855       0.1355  vmlinux-2.6.29           vmlinux-2.6.29           bit_clear_margins
817       0.1295  ksm.ko                   ksm                      is_present_pte
774       0.1227  vmlinux-2.6.29           vmlinux-2.6.29           put_disk
771       0.1222  vmlinux-2.6.29           vmlinux-2.6.29           journal_forget
741       0.1174  vmlinux-2.6.29           vmlinux-2.6.29           ext3_mark_iloc_dirty
635       0.1006  vmlinux-2.6.29           vmlinux-2.6.29           acpi_ds_exec_end_op
624       0.0989  vmlinux-2.6.29           vmlinux-2.6.29           fb_read
595       0.0943  vmlinux-2.6.29           vmlinux-2.6.29           acpi_ds_restart_control_method
595       0.0943  vmlinux-2.6.29           vmlinux-2.6.29           get_domain_for_dev
537       0.0851  vmlinux-2.6.29           vmlinux-2.6.29           cfb_copyarea
510       0.0808  libcrypto.so.0.9.8       libcrypto.so.0.9.8       (no symbols)
503       0.0797  vmlinux-2.6.29           vmlinux-2.6.29           configfs_mkdir
472       0.0748  ksm.ko                   ksm                      is_zapped_item
470       0.0745  vmlinux-2.6.29           vmlinux-2.6.29           ext2_truncate
419       0.0664  vmlinux-2.6.29           vmlinux-2.6.29           aer_print_error
411       0.0651  vmlinux-2.6.29           vmlinux-2.6.29           tcp_v6_rcv
406       0.0643  libbfd-2.18.so           libbfd-2.18.so           (no symbols)
362       0.0574  vmlinux-2.6.29           vmlinux-2.6.29           vesafb_setcolreg
318       0.0504  vmlinux-2.6.29           vmlinux-2.6.29           ext3_group_add
312       0.0494  ld-2.8.so                ld-2.8.so                (no symbols)
291       0.0461  vmlinux-2.6.29           vmlinux-2.6.29           domain_update_iommu_coherency
284       0.0450  bash                     bash                     (no symbols)
277       0.0439  vmlinux-2.6.29           vmlinux-2.6.29           compat_blkdev_ioctl
271       0.0429  vmlinux-2.6.29           vmlinux-2.6.29           ext2_block_to_path
262       0.0415  vmlinux-2.6.29           vmlinux-2.6.29           queue_requests_store
251       0.0398  vmlinux-2.6.29           vmlinux-2.6.29           nv_adma_tf_read
242       0.0384  ksm.ko                   ksm                      scan_get_next_index
236       0.0374  ksm.ko                   ksm                      try_to_merge_one_page
221       0.0350  vmlinux-2.6.29           vmlinux-2.6.29           pcie_aspm_exit_link_state
217       0.0344  vmlinux-2.6.29           vmlinux-2.6.29           sg_scsi_ioctl


Here the profiling of the same workload but with the change that
exercises the ksm absolute best case.

-               *(unsigned long *)ppage = page;
+               *(unsigned long *)ppage = 1;

CPU: Core 2, speed 2003 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        image name               app name                 symbol name
28855    25.9326  ksm.ko                   ksm                      memcmp_pages
14677    13.1906  ksm.ko                   ksm                      kthread_ksm_scan_thread
9610      8.6367  vmlinux-2.6.29           vmlinux-2.6.29           ext2_free_branches
8127      7.3039  vmlinux-2.6.29           vmlinux-2.6.29           nv_adma_qc_prep
6742      6.0592  vmlinux-2.6.29           vmlinux-2.6.29           bit_cursor
6578      5.9118  ksm.ko                   ksm                      get_rmap_item
5124      4.6051  vmlinux-2.6.29           vmlinux-2.6.29           ext2_new_inode
4216      3.7890  vmlinux-2.6.29           vmlinux-2.6.29           ahci_init_one
3500      3.1455  vmlinux-2.6.29           vmlinux-2.6.29           cfb_imageblit
3288      2.9550  ksmpages                 ksmpages                 main
3137      2.8193  vmlinux-2.6.29           vmlinux-2.6.29           register_framebuffer
1611      1.4478  ksm.ko                   ksm                      .text
1055      0.9482  vmlinux-2.6.29           vmlinux-2.6.29           bit_clear_margins
903       0.8115  vmlinux-2.6.29           vmlinux-2.6.29           journal_forget
894       0.8035  vmlinux-2.6.29           vmlinux-2.6.29           put_disk
767       0.6893  vmlinux-2.6.29           vmlinux-2.6.29           acpi_ds_restart_control_method
640       0.5752  vmlinux-2.6.29           vmlinux-2.6.29           acpi_ds_exec_end_op
626       0.5626  libc-2.8.so              libc-2.8.so              (no symbols)
608       0.5464  vmlinux-2.6.29           vmlinux-2.6.29           fb_read
518       0.4655  vmlinux-2.6.29           vmlinux-2.6.29           vesafb_setcolreg
482       0.4332  vmlinux-2.6.29           vmlinux-2.6.29           cfb_copyarea
478       0.4296  vmlinux-2.6.29           vmlinux-2.6.29           ext2_truncate
451       0.4053  ksm.ko                   ksm                      scan_get_next_index
404       0.3631  ksm.ko                   ksm                      is_present_pte
330       0.2966  vmlinux-2.6.29           vmlinux-2.6.29           ext2_block_to_path
320       0.2876  oprofiled                oprofiled                (no symbols)
270       0.2427  vmlinux-2.6.29           vmlinux-2.6.29           try_to_extend_transaction
253       0.2274  bash                     bash                     (no symbols)
242       0.2175  vmlinux-2.6.29           vmlinux-2.6.29           get_domain_for_dev
240       0.2157  vmlinux-2.6.29           vmlinux-2.6.29           domain_update_iommu_coherency
185       0.1663  vmlinux-2.6.29           vmlinux-2.6.29           pcie_aspm_init_link_state
156       0.1402  vmlinux-2.6.29           vmlinux-2.6.29           acpi_table_print_madt_entry
154       0.1384  vmlinux-2.6.29           vmlinux-2.6.29           acpi_ds_get_field_names
149       0.1339  vmlinux-2.6.29           vmlinux-2.6.29           configfs_mkdir
148       0.1330  vmlinux-2.6.29           vmlinux-2.6.29           ext3_mark_iloc_dirty
145       0.1303  ld-2.8.so                ld-2.8.so                (no symbols)
142       0.1276  vmlinux-2.6.29           vmlinux-2.6.29           ext3_group_add
138       0.1240  opreport                 opreport                 (no symbols)
130       0.1168  vmlinux-2.6.29           vmlinux-2.6.29           device_to_iommu
130       0.1168  vmlinux-2.6.29           vmlinux-2.6.29           fb_compat_ioctl
127       0.1141  vmlinux-2.6.29           vmlinux-2.6.29           acpi_ev_pci_config_region_setup
121       0.1087  ksm.ko                   ksm                      try_to_merge_one_page
113       0.1016  vmlinux-2.6.29           vmlinux-2.6.29           queue_requests_store
107       0.0962  vmlinux-2.6.29           vmlinux-2.6.29           fbcon_prepare_logo
101       0.0908  libbfd-2.18.so           libbfd-2.18.so           (no symbols)

In the shell where I was running 'vmstat 1' to know when to opcontrol
--stop to interrupt the profiling after all memory was already shared,
it is also visible the ksmpages 'read loop' improves substantially
thanks to the cache effects, when all the pages become the same.

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0   3188 1783940  39204 281408    0    2     3    12   21    5  1 23 76  0
9743 usec
 1  0   3188 1536304  39208 281404    0    0     0     4 31262  291  1 31 68  0
9186 usec
8201 usec
 2  0   3188 1518376  39208 281408    0    0     0     0 25964  304  1 25 74  0
9505 usec
7713 usec
 1  0   3188 1654276  39208 281408    0    0     0     0 26275  307  1 25 74  0
7755 usec
6346 usec
 1  0   3188 1875652  39208 281408    0    0     0     0 25539  271  0 25 75  0
7600 usec
5188 usec
 1  0   3188 2101088  39208 281408    0    0     0     0 25687  280  0 25 74  0
7639 usec
4044 usec
 1  0   3188 2335168  39208 281504    0    0     0     0 25932  277  0 25 75  0
7673 usec
2574 usec
 1  0   3188 2572344  39208 281504    0    0     0     0 25853  294  0 25 74  0
7772 usec
1618 usec
 1  0   3188 2814220  39208 281504    0    0     0     0 26334  284  0 25 75  0
6047 usec
1617 usec
 1  0   3188 3059280  39208 281504    0    0     0     0 26092  284  0 25 75  0
4504 usec
1615 usec
 1  0   3188 3310648  39208 281504    0    0     0     0 26036  279  0 25 75  0
3108 usec
1626 usec
 1  0   3188 3567180  39208 281504    0    0     0   340 26025  283  0 25 75  0
1619 usec
1608 usec
 1  0   3188 3621548  39208 281504    0    0     0     0 24191  334  0 22 78  0
1606 usec
1611 usec
 1  0   3188 3621624  39208 281504    0    0     0     0 23763  356  0 21 79  0
1604 usec
1608 usec
 1  0   3188 3621624  39208 281504    0    0     0     0 23757  335  0 22 79  0
1604 usec
1612 usec
 0  0   3188 3621624  39208 281504    0    0     0     0 23750  350  0 22 79  0
1614 usec
1607 usec
 1  0   3188 3621624  39216 281496    0    0     0   456 23874  360  0 21 78  0
1609 usec
1608 usec
 1  0   3188 3621624  39216 281548    0    0     0     0 23693  352  0 21 79  0
1604 usec
1608 usec
 1  0   3188 3621624  39216 281548    0    0     0     0 23746  359  0 21 79  0
1609 usec
1631 usec
 1  0   3188 3621624  39216 281548    0    0     0     0 23814  432  0 22 78  0
1605 usec
1608 usec
 1  0   3188 3621624  39216 281548    0    0     0     0 23799  410  0 21 79  0
1613 usec

The read loop runs 4 times faster for both copies of ksmpages in the
background after all memory is merged and the virtual address points
to the same physical page that is already cached in the CPU (because
of physically indexed caches).

The whole benchmark has been run with pages_to_scan set to 99999 and
sleep_time 10 that make kksmd run at 100% CPU load, in real life
scenarios kksmd may do less scanning and memory freeing may happen at
a slower peace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
