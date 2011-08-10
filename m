Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE2490013D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 07:01:08 -0400 (EDT)
Date: Wed, 10 Aug 2011 12:01:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3 of 3] thp: mremap support and TLB optimization
Message-ID: <20110810110102.GO9211@csn.ul.ie>
References: <patchbomb.1312649882@localhost>
 <10a29e95223e52e49a61.1312649885@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <10a29e95223e52e49a61.1312649885@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Aug 06, 2011 at 06:58:05PM +0200, aarcange@redhat.com wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This adds THP support to mremap (decreases the number of split_huge_page
> called).
> 
> Here are also some benchmarks with a proggy like this:
> 
> ===
> #define _GNU_SOURCE
> #include <sys/mman.h>
> #include <stdlib.h>
> #include <stdio.h>
> #include <string.h>
> #include <sys/time.h>
> 
> #define SIZE (5UL*1024*1024*1024)
> 
> int main()
> {
>         static struct timeval oldstamp, newstamp;
> 	long diffsec;
> 	char *p, *p2, *p3, *p4;
> 	if (posix_memalign((void **)&p, 2*1024*1024, SIZE))
> 		perror("memalign"), exit(1);
> 	if (posix_memalign((void **)&p2, 2*1024*1024, SIZE))
> 		perror("memalign"), exit(1);
> 	if (posix_memalign((void **)&p3, 2*1024*1024, 4096))
> 		perror("memalign"), exit(1);
> 
> 	memset(p, 0xff, SIZE);
> 	memset(p2, 0xff, SIZE);
> 	memset(p3, 0x77, 4096);
> 	gettimeofday(&oldstamp, NULL);
> 	p4 = mremap(p, SIZE, SIZE, MREMAP_FIXED|MREMAP_MAYMOVE, p3);
> 	gettimeofday(&newstamp, NULL);
> 	diffsec = newstamp.tv_sec - oldstamp.tv_sec;
> 	diffsec = newstamp.tv_usec - oldstamp.tv_usec + 1000000 * diffsec;
> 	printf("usec %ld\n", diffsec);
> 	if (p == MAP_FAILED || p4 != p3)
> 	//if (p == MAP_FAILED)
> 		perror("mremap"), exit(1);
> 	if (memcmp(p4, p2, SIZE))
> 		printf("mremap bug\n"), exit(1);
> 	printf("ok\n");
> 
> 	return 0;
> }
> ===
> 
> THP on
> 
>  Performance counter stats for './largepage13' (3 runs):
> 
>           69195836 dTLB-loads                 ( +-   3.546% )  (scaled from 50.30%)
>              60708 dTLB-load-misses           ( +-  11.776% )  (scaled from 52.62%)
>          676266476 dTLB-stores                ( +-   5.654% )  (scaled from 69.54%)
>              29856 dTLB-store-misses          ( +-   4.081% )  (scaled from 89.22%)
>         1055848782 iTLB-loads                 ( +-   4.526% )  (scaled from 80.18%)
>               8689 iTLB-load-misses           ( +-   2.987% )  (scaled from 58.20%)
> 
>         7.314454164  seconds time elapsed   ( +-   0.023% )
> 
> THP off
> 
>  Performance counter stats for './largepage13' (3 runs):
> 
>         1967379311 dTLB-loads                 ( +-   0.506% )  (scaled from 60.59%)
>            9238687 dTLB-load-misses           ( +-  22.547% )  (scaled from 61.87%)
>         2014239444 dTLB-stores                ( +-   0.692% )  (scaled from 60.40%)
>            3312335 dTLB-store-misses          ( +-   7.304% )  (scaled from 67.60%)
>         6764372065 iTLB-loads                 ( +-   0.925% )  (scaled from 79.00%)
>               8202 iTLB-load-misses           ( +-   0.475% )  (scaled from 70.55%)
> 
>         9.693655243  seconds time elapsed   ( +-   0.069% )
> 
> grep thp /proc/vmstat
> thp_fault_alloc 35849
> thp_fault_fallback 0
> thp_collapse_alloc 3
> thp_collapse_alloc_failed 0
> thp_split 0
> 
> thp_split 0 confirms no thp split despite plenty of hugepages allocated.
> 
> The measurement of only the mremap time (so excluding the 3 long
> memset and final long 10GB memory accessing memcmp):
> 
> THP on
> 
> usec 14824
> usec 14862
> usec 14859
> 
> THP off
> 
> usec 256416
> usec 255981
> usec 255847
> 
> With an older kernel without the mremap optimizations (the below patch
> optimizes the non THP version too).
> 
> THP on
> 
> usec 392107
> usec 390237
> usec 404124
> 
> THP off
> 
> usec 444294
> usec 445237
> usec 445820
> 
> I guess with a threaded program that sends more IPI on large SMP it'd
> create an even larger difference.
> 
> All debug options are off except DEBUG_VM to avoid skewing the
> results.
> 
> The only problem for native 2M mremap like it happens above both the
> source and destination address must be 2M aligned or the hugepmd can't
> be moved without a split but that is an hardware limitation.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

It's a pity about the tristate but if the alternative really is that bad
and results in unnecessary calls, it can be lived with if a comment is
stuck above move_huge_pmd() explaining the return values.

Otherwise

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
