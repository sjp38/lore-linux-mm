Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8476B016A
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 20:17:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 05F343EE0B6
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:17:02 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E130745DEB3
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:17:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C6FDF45DEA6
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:17:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B86951DB803C
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:17:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 837431DB8037
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:17:01 +0900 (JST)
Date: Thu, 1 Sep 2011 09:09:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: skip scanning active lists based on individual
 size
Message-Id: <20110901090931.c0721216.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAEwNFnBSg71QoLZbOqZbXK3fGEGneituU3PmiYTAw1VM3KcwcQ@mail.gmail.com>
References: <20110831090850.GA27345@redhat.com>
	<CAEwNFnBSg71QoLZbOqZbXK3fGEGneituU3PmiYTAw1VM3KcwcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 31 Aug 2011 19:13:34 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Aug 31, 2011 at 6:08 PM, Johannes Weiner <jweiner@redhat.com> wrote:
> > Reclaim decides to skip scanning an active list when the corresponding
> > inactive list is above a certain size in comparison to leave the
> > assumed working set alone while there are still enough reclaim
> > candidates around.
> >
> > The memcg implementation of comparing those lists instead reports
> > whether the whole memcg is low on the requested type of inactive
> > pages, considering all nodes and zones.
> >
> > This can lead to an oversized active list not being scanned because of
> > the state of the other lists in the memcg, as well as an active list
> > being scanned while its corresponding inactive list has enough pages.
> >
> > Not only is this wrong, it's also a scalability hazard, because the
> > global memory state over all nodes and zones has to be gathered for
> > each memcg and zone scanned.
> >
> > Make these calculations purely based on the size of the two LRU lists
> > that are actually affected by the outcome of the decision.
> >
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Cc: Balbir Singh <bsingharora@gmail.com>
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> I can't understand why memcg is designed for considering all nodes and zones.
> Is it a mistake or on purpose?

It's purpose. memcg just takes care of the amount of pages.
Them, any performance numbers ?


But, hmm, this change may be good for softlimit and your work.

I'll ack when you add performance numbers in changelog.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
