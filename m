Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 791AD8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 01:17:06 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2EF393EE0BC
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:17:03 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1374545DE5D
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:17:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EEADA45DE58
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:17:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E044AE18001
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:17:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F73EE08003
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:17:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
In-Reply-To: <4D767D43.5020802@gmail.com>
References: <20110308120615.7EB9.A69D9226@jp.fujitsu.com> <4D767D43.5020802@gmail.com>
Message-Id: <20110309145457.0400.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  9 Mar 2011 15:17:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: avagin@gmail.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> On 03/08/2011 06:06 AM, KOSAKI Motohiro wrote:
> >>>> Hmm.. Although it solves the problem, I think it's not a good idea that
> >>>> depends on false alram and give up the retry.
> >>>
> >>> Any alternative proposals?  We should get the livelock fixed if possible..
> >>
> >> I agree with Minchan and can't think this is a real fix....
> >> Andrey, I'm now trying your fix and it seems your fix for oom-killer,
> >> 'skip-zombie-process' works enough good for my environ.
> >>
> >> What is your enviroment ? number of cpus ? architecture ? size of memory ?
> >
> > me too. 'skip-zombie-process V1' work fine. and I didn't seen this patch
> > improve oom situation.
> >
> > And, The test program is purely fork bomb. Our oom-killer is not silver
> > bullet for fork bomb from very long time ago. That said, oom-killer send
> > SIGKILL and start to kill the victim process. But, it doesn't prevent
> > to be created new memory hogging tasks. Therefore we have no gurantee
> > to win process exiting and creating race.
> 
> I think a live-lock is a bug, even if it's provoked by fork bomds.
> 
> And now I want say some words about zone->all_unreclaimable. I think 
> this flag is "conservative". It is set when situation is bad and it's 
> unset when situation get better. If we have a small number of 
> reclaimable  pages, the situation is still bad. What do you mean, when 
> say that kernel is alive? If we have one reclaimable page, is the kernel 
> alive? Yes, it can work, it will generate many page faults and do 
> something, but anyone say that it is more dead than alive.
> 
> Try to look at it from my point of view. The patch will be correct and 
> the kernel will be more alive.
> 
> Excuse me, If I'm mistaken...

Hi, 

Hmmm...
If I could observed your patch, I did support your opinion. but I didn't. so, now I'm 
curious why we got the different conclusion. tommorow, I'll try to construct a test 
environment to reproduce your system.

Unfortunatelly, zone->all_unreclamable is unreliable value while hibernation processing.
Then I doubt current your patch is enough acceptable. but I'm not against to make alternative
if we can observe the same phenomenon.

At minimum, I also dislike kernel hang up issue.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
