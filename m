Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 990986B01BA
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 20:17:18 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2O0HGGb010147
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Mar 2010 09:17:16 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D149645DE52
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:17:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B155645DE4F
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:17:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 904F41DB8043
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:17:15 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 23CA2E38001
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:17:15 +0900 (JST)
Date: Wed, 24 Mar 2010 09:13:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 05/11] Export unusable free space index via
 /proc/unusable_index
Message-Id: <20100324091331.776e8588.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361003231716k54ca1ae8u92793be7f2fdf374@mail.gmail.com>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-6-git-send-email-mel@csn.ul.ie>
	<20100324090312.4e1cc725.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361003231716k54ca1ae8u92793be7f2fdf374@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 2010 09:16:07 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Kame.
> 
> On Wed, Mar 24, 2010 at 9:03 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 23 Mar 2010 12:25:40 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> >
> >> Unusable free space index is a measure of external fragmentation that
> >> takes the allocation size into account. For the most part, the huge page
> >> size will be the size of interest but not necessarily so it is exported
> >> on a per-order and per-zone basis via /proc/unusable_index.
> >>
> >> The index is a value between 0 and 1. It can be expressed as a
> >> percentage by multiplying by 100 as documented in
> >> Documentation/filesystems/proc.txt.
> >>
> >> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> >> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> Acked-by: Rik van Riel <riel@redhat.com>
> >> ---
> >> A Documentation/filesystems/proc.txt | A  13 ++++-
> >> A mm/vmstat.c A  A  A  A  A  A  A  A  A  A  A  A | A 120 +++++++++++++++++++++++++++++++++
> >> A 2 files changed, 132 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> >> index 5e132b5..5c4b0fb 100644
> >> --- a/Documentation/filesystems/proc.txt
> >> +++ b/Documentation/filesystems/proc.txt
> >> @@ -452,6 +452,7 @@ Table 1-5: Kernel info in /proc
> >> A  sys A  A  A  A  See chapter 2
> >> A  sysvipc A  A  Info of SysVIPC Resources (msg, sem, shm) A  A  A  A  A  A  A  (2.4)
> >> A  tty A  A  A Info of tty drivers
> >> + unusable_index Additional page allocator information (see text)(2.5)
> >> A  uptime A  A  A System uptime
> >> A  version A  A  Kernel version
> >> A  video A  A  A  A  A  A bttv info of video resources A  A  A  A  A  A  A  A  A  A  A  (2.4)
> >> @@ -609,7 +610,7 @@ ZONE_DMA, 4 chunks of 2^1*PAGE_SIZE in ZONE_DMA, 101 chunks of 2^4*PAGE_SIZE
> >> A available in ZONE_NORMAL, etc...
> >>
> >> A More information relevant to external fragmentation can be found in
> >> -pagetypeinfo.
> >> +pagetypeinfo and unusable_index
> >>
> >> A > cat /proc/pagetypeinfo
> >> A Page block order: 9
> >> @@ -650,6 +651,16 @@ unless memory has been mlock()'d. Some of the Reclaimable blocks should
> >> A also be allocatable although a lot of filesystem metadata may have to be
> >> A reclaimed to achieve this.
> >>
> >> +> cat /proc/unusable_index
> >> +Node 0, zone A  A  A DMA 0.000 0.000 0.000 0.001 0.005 0.013 0.021 0.037 0.037 0.101 0.230
> >> +Node 0, zone A  Normal 0.000 0.000 0.000 0.001 0.002 0.002 0.005 0.015 0.028 0.028 0.054
> >> +
> >> +The unusable free space index measures how much of the available free
> >> +memory cannot be used to satisfy an allocation of a given size and is a
> >> +value between 0 and 1. The higher the value, the more of free memory is
> >> +unusable and by implication, the worse the external fragmentation is. This
> >> +can be expressed as a percentage by multiplying by 100.
> >> +
> >> A ..............................................................................
> >>
> >> A meminfo:
> >> diff --git a/mm/vmstat.c b/mm/vmstat.c
> >> index 7f760cb..ca42e10 100644
> >> --- a/mm/vmstat.c
> >> +++ b/mm/vmstat.c
> >> @@ -453,6 +453,106 @@ static int frag_show(struct seq_file *m, void *arg)
> >> A  A  A  return 0;
> >> A }
> >>
> >> +
> >> +struct contig_page_info {
> >> + A  A  unsigned long free_pages;
> >> + A  A  unsigned long free_blocks_total;
> >> + A  A  unsigned long free_blocks_suitable;
> >> +};
> >> +
> >> +/*
> >> + * Calculate the number of free pages in a zone, how many contiguous
> >> + * pages are free and how many are large enough to satisfy an allocation of
> >> + * the target size. Note that this function makes to attempt to estimate
> >> + * how many suitable free blocks there *might* be if MOVABLE pages were
> >> + * migrated. Calculating that is possible, but expensive and can be
> >> + * figured out from userspace
> >> + */
> >> +static void fill_contig_page_info(struct zone *zone,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned int suitable_order,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct contig_page_info *info)
> >> +{
> >> + A  A  unsigned int order;
> >> +
> >> + A  A  info->free_pages = 0;
> >> + A  A  info->free_blocks_total = 0;
> >> + A  A  info->free_blocks_suitable = 0;
> >> +
> >> + A  A  for (order = 0; order < MAX_ORDER; order++) {
> >> + A  A  A  A  A  A  unsigned long blocks;
> >> +
> >> + A  A  A  A  A  A  /* Count number of free blocks */
> >> + A  A  A  A  A  A  blocks = zone->free_area[order].nr_free;
> >> + A  A  A  A  A  A  info->free_blocks_total += blocks;
> >
> > ....for what this free_blocks_total is ?
> 
> It's used by fragmentation_index in [06/11].
> 
Ah, I see. thanks.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
