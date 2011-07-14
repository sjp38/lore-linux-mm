Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A281C6B0083
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 00:53:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B9B183EE0C2
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 13:53:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D3EC45DEB8
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 13:53:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 83C9D45DEB5
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 13:53:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 71DB31DB8040
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 13:53:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B0911DB803F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 13:53:52 +0900 (JST)
Date: Thu, 14 Jul 2011 13:46:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-Id: <20110714134634.4a7a15c8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110714044643.GA3203@infradead.org>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
	<1310567487-15367-2-git-send-email-mgorman@suse.de>
	<20110714103801.83e10fdb.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714044643.GA3203@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 14 Jul 2011 00:46:43 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jul 14, 2011 at 10:38:01AM +0900, KAMEZAWA Hiroyuki wrote:
> > > +			/*
> > > +			 * Only kswapd can writeback filesystem pages to
> > > +			 * avoid risk of stack overflow
> > > +			 */
> > > +			if (page_is_file_cache(page) && !current_is_kswapd()) {
> > > +				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
> > > +				goto keep_locked;
> > > +			}
> > > +
> > 
> > 
> > This will cause tons of memcg OOM kill because we have no help of kswapd (now).
> 
> XFS and btrfs already disable writeback from memcg context, as does ext4
> for the typical non-overwrite workloads, and none has fallen apart.
> 
> In fact there's no way we can enable them as the memcg calling contexts
> tend to have massive stack usage.
> 

Hmm, XFS/btrfs adds pages to radix-tree in deep stack ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
