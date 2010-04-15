Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6BCF26B01E3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 05:41:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F9ffAh026336
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 18:41:42 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ABDD445DE55
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 18:41:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 757EA45DE50
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 18:41:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 484691DB8042
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 18:41:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA3E41DB803E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 18:41:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if current is kswapd
In-Reply-To: <20100415093214.GV2493@dastard>
References: <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org> <20100415093214.GV2493@dastard>
Message-Id: <20100415183425.D19E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 18:41:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Suleiman Souhlal <ssouhlal@freebsd.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>

> On Thu, Apr 15, 2010 at 01:05:57AM -0700, Suleiman Souhlal wrote:
> > 
> > On Apr 14, 2010, at 9:11 PM, KOSAKI Motohiro wrote:
> > 
> > >Now, vmscan pageout() is one of IO throuput degression source.
> > >Some IO workload makes very much order-0 allocation and reclaim
> > >and pageout's 4K IOs are making annoying lots seeks.
> > >
> > >At least, kswapd can avoid such pageout() because kswapd don't
> > >need to consider OOM-Killer situation. that's no risk.
> > >
> > >Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > What's your opinion on trying to cluster the writes done by pageout,
> > instead of not doing any paging out in kswapd?
> 
> XFS already does this in ->writepage to try to minimise the impact
> of the way pageout issues IO. It helps, but it is still not as good
> as having all the writeback come from the flusher threads because
> it's still pretty much random IO.

I havent review such patch yet. then, I'm talking about generic thing.
pageout() doesn't only writeout file backed page, but also write
swap backed page. so, filesystem optimization nor flusher thread
doesn't erase pageout clusterring worth.


> And, FWIW, it doesn't solve the stack usage problems, either. In
> fact, it will make them worse as write_one_page() puts another
> struct writeback_control on the stack...

Correct. we need to avoid double writeback_control on stack.
probably, we need to divide pageout() some piece.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
