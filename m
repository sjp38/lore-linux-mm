Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1BB6B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 06:13:36 -0400 (EDT)
Received: by yib2 with SMTP id 2so488691yib.14
        for <linux-mm@kvack.org>; Wed, 31 Aug 2011 03:13:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110831090850.GA27345@redhat.com>
References: <20110831090850.GA27345@redhat.com>
Date: Wed, 31 Aug 2011 19:13:34 +0900
Message-ID: <CAEwNFnBSg71QoLZbOqZbXK3fGEGneituU3PmiYTAw1VM3KcwcQ@mail.gmail.com>
Subject: Re: [patch] memcg: skip scanning active lists based on individual size
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 31, 2011 at 6:08 PM, Johannes Weiner <jweiner@redhat.com> wrote:
> Reclaim decides to skip scanning an active list when the corresponding
> inactive list is above a certain size in comparison to leave the
> assumed working set alone while there are still enough reclaim
> candidates around.
>
> The memcg implementation of comparing those lists instead reports
> whether the whole memcg is low on the requested type of inactive
> pages, considering all nodes and zones.
>
> This can lead to an oversized active list not being scanned because of
> the state of the other lists in the memcg, as well as an active list
> being scanned while its corresponding inactive list has enough pages.
>
> Not only is this wrong, it's also a scalability hazard, because the
> global memory state over all nodes and zones has to be gathered for
> each memcg and zone scanned.
>
> Make these calculations purely based on the size of the two LRU lists
> that are actually affected by the outcome of the decision.
>
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <bsingharora@gmail.com>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I can't understand why memcg is designed for considering all nodes and zones.
Is it a mistake or on purpose?
Maybe Kame or Balbir can answer it.

Anyway, this change does make sense to me.

Nitpick: Please remove inactive_ratio in Documentation/cgroups/memory.txt.
I think it would be better to separate it into another patch.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
