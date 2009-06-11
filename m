Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A8F46B005D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 07:31:27 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BBWPaY007254
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 20:32:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E28745DE51
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:32:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D21D45DE4F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:32:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DE0CC1DB8037
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:32:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 697FC1DB8046
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:32:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH for mmotm 0/5] introduce swap-backed-file-mapped count and fix vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
In-Reply-To: <20090611105259.GC7302@csn.ul.ie>
References: <20090611194141.6D5C.A69D9226@jp.fujitsu.com> <20090611105259.GC7302@csn.ul.ie>
Message-Id: <20090611200321.6D62.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 20:32:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Thu, Jun 11, 2009 at 07:42:33PM +0900, KOSAKI Motohiro wrote:
> > > On Thu, Jun 11, 2009 at 07:25:09PM +0900, KOSAKI Motohiro wrote:
> > > > Recently, Wu Fengguang pointed out vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
> > > > has underflow problem.
> > > > 
> > > 
> > > Can you drop this aspect of the patchset please? I'm doing a final test
> > > on the scan-avoidance heuristic that incorporates this patch and the
> > > underflow fix. Ram (the tester of the malloc()-stall) confirms the patch
> > > fixes his problem.
> > 
> > OK.
> > insted, I'll join to review your patch :)
> > 
> 
> Thanks. You should have it now. In particular, I'm interested in hearing you
> opinion about patch 1 of the series "Fix malloc() stall in zone_reclaim()
> and bring behaviour more in line with expectations V3" and if addresses;
> 
> 1. Does patch 1 address the problem that first led you to develop the patch
> vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch?

Yes, thanks. my original issue is

1. mem-hog process eat all pages in one node of numa machine.
2. kswapd run and makes many swapcache. 
   it mean increasing NR_FILE_PAGES - NR_FILE_MAPPED.
3. any page allocation invoke zone reclaim, but the zone don't have
   any file-backed page at all.

distro kernel can reproduce easily, but mainline kernel can't so easy.
but I think root cause is remain. it is (NR_FILE_PAGES - NR_FILE_MAPPED)
calculation.


> 2. Do you think patch 1 should merge with and replace
> vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch?

In my personal prefer, your patch seems to have very good description and
rewrite almost part of mine.
Thus replacing is better. Can you please make replacing patch?



> > > > This patch series introduce new vmstat of swap-backed-file-mapped and fix above
> > > > patch by it.
> > 
> 
> I don't think the patch above needs to be fixed by another counter. At
> least, once the underflow was fixed up, it handled the malloc-stall without
> additional counters. If we need to account swap-backed-file-mapped, we need
> another failure case that it addresses to be sure we're doing the right thing.

ok, I drop this.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
