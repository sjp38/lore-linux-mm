Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EB2DA6B0047
	for <linux-mm@kvack.org>; Sun, 26 Sep 2010 22:11:44 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8R2BgSx014382
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Sep 2010 11:11:42 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 58BBF45DE59
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:11:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D13145DE55
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:11:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B31E1DB8061
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:11:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E13BB1DB8051
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:11:39 +0900 (JST)
Date: Mon, 27 Sep 2010 11:06:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
Message-Id: <20100927110628.9bc97ea7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100927110417.6B34.A69D9226@jp.fujitsu.com>
References: <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
	<20100921100522.be252b3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100927110417.6B34.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: robm@fastmail.fm, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Sep 2010 11:04:54 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Thu, 16 Sep 2010 19:01:32 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > Yes, sadly intel motherboard turn on zone_reclaim_mode by default. and
> > > current zone_reclaim_mode doesn't fit file/web server usecase ;-)
> > > 
> > > So, I've created new proof concept patch. This doesn't disable zone_reclaim
> > > at all. Instead, distinguish for file cache and for anon allocation and
> > > only file cache doesn't use zone-reclaim.
> > > 
> > > That said, high-end hpc user often turn on cpuset.memory_spread_page and
> > > they avoid this issue. But, why don't we consider avoid it by default?
> > > 
> > > 
> > > Rob, I wonder if following patch help you. Could you please try it?
> > > 
> > > 
> > > Subject: [RFC] vmscan: file cache doesn't use zone_reclaim by default
> > > 
> > 
> > Hm, can't we use migration of file caches rather than pageout in
> > zone_reclaim_mode ? Doent' it fix anything ?
> 
> Doesn't.
> 
> Two problem. 1) Migration makes copy. then it's slower than zone_reclaim=0
> 2) Migration is only effective if target node has much free pages. but it
> is not generic assumption.
> 
> For this case, zone_reclaim_mode=0 is best. my patch works as second best.
> your one works as third.
> 

Hmm. I'm not sure whether it's "slower" or not. And Migraion doesn't
assume target node because it can use zonelist fallback.

I'm just has concerns that kicked-out pages will be paged-in soon.

But ok, maybe complicated.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
