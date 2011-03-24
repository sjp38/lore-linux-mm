Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3028F8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 06:52:33 -0400 (EDT)
Received: by iwl42 with SMTP id 42so13211517iwl.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 03:52:30 -0700 (PDT)
Date: Thu, 24 Mar 2011 19:52:22 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 0/4] forkbomb killer
Message-ID: <20110324105222.GA2625@barrios-desktop>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

Hi Kame,

On Thu, Mar 24, 2011 at 06:22:40PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> Cleaned up and fixed unclear logics. and removed RFC.
> Maybe this version is easy to be read.
> 
> 
> When we see forkbomb, it tends can be a fatal one.
> 
>  When A user makes a forkbomb (and sometimes reaches ulimit....
>    In this case, 
>    - If the system is not in OOM, the admin may be able to kill all threads by
>      hand..but forkbomb may be faster than pkill() by admin.
>    - If the system is in OOM, the admin needs to reboot system.
>      OOM killer is slow than forkbomb.
> 
> So, I think forkbomb killer is appreciated. It's better than reboot.
> 
> At implementing forkbomb killer, one of difficult case is like this
> 
> # forkbomb(){ forkbomb|forkbomb & } ; forkbomb
> 
> With this, parent tasks will exit() before the system goes under OOM.
> So, it's difficult to know the whole image of forkbomb.
> 
> This patch introduce a subsystem to track mm's history and records it
> even after the task exit. (It will be flushed periodically.)
> 
> I tested with several forkbomb cases and this patch seems work fine.
> 
> Maybe some more 'heuristics' can be added....but I think this simple
> one works enough. Any comments are welcome.

Sorry for the late review. Recently I dont' have enough time to review patches.
Even I didn't start to review this series but I want to review this series.
It's one of my interest features. :)

But before digging in code, I would like to make a consensus to others to 
need this feature. Let's Cc others.

What I think is that about "cost(frequent case) VS effectiveness(very rare case)"
as you expected. :)

1. At least, I don't meet any fork-bomb case for a few years. My primary linux usage
is just desktop and developement enviroment, NOT server. Only thing I have seen is
just ltp or intentional fork-bomb test like hackbench. AFAIR, ltp case was fixed
a few years ago. Although it happens suddenly, reboot in desktop isn't critical 
as much as server's one.

2. I don't know server enviroment but I think applications executing on server
are selected by admin carefully. So virus program like fork-bomb is unlikely in there.
(Maybe I am wrong. You know than me).
If some normal program becomes fork-bomb unexpectedly, it's critical.
Admin should select application with much testing very carefully. But I don't know
the reality. :(

Of course, although he did such efforts, he could meet OOM hang situation. 
In the case, he can't avoid rebooting. Sad. But for helping him, should we pay cost 
in normal situation?(Again said, I didn't start looking at your code so 
I can't expect the cost but at least it's more than as-is).
It could help developing many virus program and to make careless admins.

It's just my private opinion. 
I don't have enough experience so I hope listen other's opinions 
about generic fork-bomb killer, not memcg.

I don't intend to ignore your effort but justify your and my effort rightly.

Thanks for your effort, Kame. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
