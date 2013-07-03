Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8E5366B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 04:35:17 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 0/5] Support multiple pages allocation
Date: Wed,  3 Jul 2013 17:34:15 +0900
Message-Id: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello.

This patchset introduces multiple pages allocation feature to buddy
allocator. Currently, there is no ability to allocate multiple pages
at once, so we should invoke single page allocation logic repeatedly.
This has some overheads like as overhead of function call with many
arguments and overhead for finding proper node and zone.

With this patchset, we can reduce these overheads.
Here goes some experimental result of allocation test.
I did the test on below setup.
CPU: 4 cpus, 3.00GHz.
RAM: 4 GB
Kernel: v3.10 vanilla

Each case of result is an average of 20 runs.

Time(us) : Improvement Percentage

Before			Patched	1 page		Patched	2 page		Patched	4 page
--------------------------------------------------------------------------------------
128KB	5.3	0	4.45	16.04%		3.25	38.68%		3.75	29.25%
256KB	13.15	0	10.15	22.81%		8.8	33.08%		8.5	35.36%
512KB	72.3	0	34.65	52.07%		82.65	-14.32%		25	65.42%
1024KB	114.9	0	112.95	1.70%		87.55	23.80%		64.7	43.69%
2MB	131.65	0	102.35	22.26%		91.95	30.16%		126.05	4.25%
4MB	225.55	0	213.2	5.48%		181.95	19.33%		200.8	10.97%
8MB	408.6	0	442.85	-8.38%		350.4	14.24%		365.15	10.63%
16MB	730.55	0	683.35	6.46%		735.5	-0.68%		698.3	4.41%
32MB	1682.6	0	1665.85	1.00%		1445.1	14.12%		1157.05	31.23%
64MB	3229.4	0	3463.2	-7.24%		2538.4	21.40%		1850.55	42.70%
128MB	5465.6	0	4816.2	11.88%		4448.3	18.61%		3528.25	35.45%
256MB	9526.9	0	10091.75 -5.93%		8514.5	10.63%		7978.2	16.26%
512MB	19029.05 0	20079.7	-5.52%		17059.05 10.35%		14713.65 22.68%
1024MB	37284.9	0	39453.75 -5.82%		32969.7	11.57%		28161.65 24.47%



Before			Patched	8 page		Patched	16 page		Patched	32 page
---------------------------------------------------------------------------------------
128KB	5.3	0	3.05	42.45%		2.65	50.00%		2.85	46.23%
256KB	13.15	0	8.2	37.64%		7.45	43.35%		7.95	39.54%
512KB	72.3	0	16.8	76.76%		17.7	75.52%		14.55	79.88%
1024KB	114.9	0	60.05	47.74%		93.65	18.49%		74.2	35.42%
2MB	131.65	0	119.8	9.00%		72.6	44.85%		84.7	35.66%
4MB	225.55	0	227.3	-0.78%		149.95	33.52%		153.6	31.90%
8MB	408.6	0	372.5	8.84%		304.95	25.37%		340.55	16.65%
16MB	730.55	0	772.2	-5.70%		567.4	22.33%		618.3	15.37%
32MB	1682.6	0	1217.7	27.63%		1098.25	34.73%		1168.7	30.54%
64MB	3229.4	0	2237.75	30.71%		1817.8	43.71%		1998.25	38.12%
128MB	5465.6	0	3504.25	35.89%		3466.75	36.57%		3159.35	42.20%
256MB	9526.9	0	7071.2	25.78%		7095.05	25.53%		6800.9	28.61%
512MB	19029.05 0	13640.85 28.32%		13098.2	31.17%		12778.1	32.85%
1024MB	37284.9	0	25897.15 30.54%		24875.6	33.28%		24179.3	35.15%



For one page allocation at once, this patchset makes allocator slower than
before (-5%). But, for more page allocation at once, this patchset makes
allocator faster than before greately.

At first, we can apply this feature to page cache readahead logic which
allocate single page repeatedly. I attach sample implementation to this
patchset(Patch 2-5).

Current implementation is not yet complete. Before polishing this feature,
I want to hear expert's opinion. I don't have any trouble with
current allocator, however, I think that we need this feature soon,
because device I/O is getting faster rapidly and allocator should
catch up this speed.

Thanks.

Joonsoo Kim (5):
  mm, page_alloc: support multiple pages allocation
  mm, page_alloc: introduce alloc_pages_exact_node_multiple()
  radix-tree: introduce radix_tree_[next/prev]_present()
  readahead: remove end range check
  readhead: support multiple pages allocation for readahead

 include/linux/gfp.h        |   16 ++++++++++--
 include/linux/pagemap.h    |   19 +++++++++-----
 include/linux/radix-tree.h |    4 +++
 lib/radix-tree.c           |   34 ++++++++++++++++++++++++
 mm/filemap.c               |   18 ++++++++-----
 mm/mempolicy.c             |    6 +++--
 mm/page_alloc.c            |   62 +++++++++++++++++++++++++++++++++++---------
 mm/readahead.c             |   46 ++++++++++++++++++++++----------
 8 files changed, 162 insertions(+), 43 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
