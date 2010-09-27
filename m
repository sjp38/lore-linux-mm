Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 16A276B0047
	for <linux-mm@kvack.org>; Sun, 26 Sep 2010 22:04:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8R24uTk000815
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 27 Sep 2010 11:04:56 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B1BAA45DE54
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:04:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ED2D45DE51
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:04:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 694EF1DB8043
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:04:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A8D91DB803C
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:04:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for file/email/web servers
In-Reply-To: <20100921100522.be252b3d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100916184240.3BC9.A69D9226@jp.fujitsu.com> <20100921100522.be252b3d.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20100927110417.6B34.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 27 Sep 2010 11:04:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, robm@fastmail.fm, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> On Thu, 16 Sep 2010 19:01:32 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Yes, sadly intel motherboard turn on zone_reclaim_mode by default. and
> > current zone_reclaim_mode doesn't fit file/web server usecase ;-)
> > 
> > So, I've created new proof concept patch. This doesn't disable zone_reclaim
> > at all. Instead, distinguish for file cache and for anon allocation and
> > only file cache doesn't use zone-reclaim.
> > 
> > That said, high-end hpc user often turn on cpuset.memory_spread_page and
> > they avoid this issue. But, why don't we consider avoid it by default?
> > 
> > 
> > Rob, I wonder if following patch help you. Could you please try it?
> > 
> > 
> > Subject: [RFC] vmscan: file cache doesn't use zone_reclaim by default
> > 
> 
> Hm, can't we use migration of file caches rather than pageout in
> zone_reclaim_mode ? Doent' it fix anything ?

Doesn't.

Two problem. 1) Migration makes copy. then it's slower than zone_reclaim=0
2) Migration is only effective if target node has much free pages. but it
is not generic assumption.

For this case, zone_reclaim_mode=0 is best. my patch works as second best.
your one works as third.

If you have more concern, please let us know it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
