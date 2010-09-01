Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ED61F6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 21:55:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o811tedx013196
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Sep 2010 10:55:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C6D8645DE54
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:55:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F8DF45DE52
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:55:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 681EB1DB805D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:55:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 198461DB803F
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:55:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] vmscan: don't use return value trick when oom_killer_disabled
In-Reply-To: <AANLkTikXfvEVXEyw_5_eJs2v-3J6Xhd=CT9X-0D+GMCA@mail.gmail.com>
References: <20100901092430.9741.A69D9226@jp.fujitsu.com> <AANLkTikXfvEVXEyw_5_eJs2v-3J6Xhd=CT9X-0D+GMCA@mail.gmail.com>
Message-Id: <20100901105232.974F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Sep 2010 10:55:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

Thank you for good commenting!


> I don't like use oom_killer_disabled directly.
> That's because we have wrapper inline functions to handle the
> variable(ex, oom_killer_[disable/enable]).
> It means we are reluctant to use the global variable directly.
> So should we make new function as is_oom_killer_disable?
> 
> I think NO.
> 
> As I read your description, this problem is related to only hibernation.
> Since hibernation freezes all processes(include kswapd), this problem
> happens. Of course, now oom_killer_disabled is used by only
> hibernation. But it can be used others in future(Off-topic : I don't
> want it). Others can use it without freezing processes. Then kswapd
> can set zone->all_unreclaimable and the problem can't happen.
> 
> So I want to use sc->hibernation_mode which is already used
> do_try_to_free_pages instead of oom_killer_disabled.

Unfortunatelly, It's impossible. shrink_all_memory() turn on
sc->hibernation_mode. but other hibernation caller merely call
alloc_pages(). so we don't have any hint.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
