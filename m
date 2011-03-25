Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8647D8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 20:10:48 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 232983EE0B6
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 09:10:44 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B62245DE92
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 09:10:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E761245DE91
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 09:10:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D7998E08002
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 09:10:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95087E08001
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 09:10:43 +0900 (JST)
Date: Fri, 25 Mar 2011 09:04:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] forkbomb killer
Message-Id: <20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110324105222.GA2625@barrios-desktop>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Thu, 24 Mar 2011 19:52:22 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi Kame,
> 
Hi.

> On Thu, Mar 24, 2011 at 06:22:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > I tested with several forkbomb cases and this patch seems work fine.
> > 
> > Maybe some more 'heuristics' can be added....but I think this simple
> > one works enough. Any comments are welcome.
> 
> Sorry for the late review. Recently I dont' have enough time to review patches.
> Even I didn't start to review this series but I want to review this series.
> It's one of my interest features. :)
> 
> But before digging in code, I would like to make a consensus to others to 
> need this feature. Let's Cc others.
> 
> What I think is that about "cost(frequent case) VS effectiveness(very rare case)"
> as you expected. :)
> 
> 1. At least, I don't meet any fork-bomb case for a few years. My primary linux usage
> is just desktop and developement enviroment, NOT server. Only thing I have seen is
> just ltp or intentional fork-bomb test like hackbench. AFAIR, ltp case was fixed
> a few years ago. Although it happens suddenly, reboot in desktop isn't critical 
> as much as server's one.
> 

Personally, I've met forkbombs several times by typing "make -j" .....by mistake.

I met a forkbomb on production system by buggy script, once.
That happens because
 1. $PATH includes "."
 2. a programmer write a scirpt "date" and call "date" in the script.

Maybe this is a one of typical case of forkbomb. I needed to dig crashdump to find
fragile of page-caches and see what happens...But, I guess, if appearent forkbomb
happens, the issue will not be sent to my team because we're 2nd line support team 
and 1st line should block it ;).

So, I'm not sure how many forkbombs happens in server world in a year. But I guess
forkbomb still happens in many development systems because there is no guard
against it.


> 2. I don't know server enviroment but I think applications executing on server
> are selected by admin carefully. So virus program like fork-bomb is unlikely in there.
> (Maybe I am wrong. You know than me).
> If some normal program becomes fork-bomb unexpectedly, it's critical.
> Admin should select application with much testing very carefully. But I don't know
> the reality. :(
> 

Yes, admin selects applications carefully. There is no 100% protection by human's hand.


> Of course, although he did such efforts, he could meet OOM hang situation. 
> In the case, he can't avoid rebooting. Sad. But for helping him, should we pay cost 
> in normal situation?(Again said, I didn't start looking at your code so 
> I can't expect the cost but at least it's more than as-is).
> It could help developing many virus program and to make careless admins.
> 
> It's just my private opinion. 
> I don't have enough experience so I hope listen other's opinions 
> about generic fork-bomb killer, not memcg.
> 
> I don't intend to ignore your effort but justify your and my effort rightly.
> 

To me, the fact "the system _can_ be broken by a normal user program" is the most
terrible thing. With Andrey's case or make -j, a user doesn't need to be an admin.
I believe it's worth to pay costs.
(and I made this function configurable and can be turned off by sysfs.)

And while testing Andrey's case, I used KVM finaly becasue cost of rebooting was small.
My development server is on other building and I need to push server's button
to reboot it when forkbomb happens ;)
In some environement, cost of rebooting is not small even if it's a development system.


Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
