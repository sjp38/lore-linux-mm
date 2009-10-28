Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 04EF16B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:08:10 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S688oh012173
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 15:08:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BC99D45DE55
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:08:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5496E45DE52
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:08:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 25A80E08001
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:08:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A74CE1DB8038
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:08:06 +0900 (JST)
Date: Wed, 28 Oct 2009 15:05:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org>
	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910271843510.11372@sister.anvils>
	<alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com>
	<4AE78B8F.9050201@gmail.com>
	<alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
	<4AE792B8.5020806@gmail.com>
	<alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
	<20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 22:13:44 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Yep:
> 
> [97137.724965] 917504 pages RAM
> [97137.724967] 69721 pages reserved
> 
> (917504 - 69721) * 4K = ~3.23G
> 
> > Then, considering the pmap kosaki shows,
> > I guess killed ones had big total_vm but has not much real rss,
> > and no helps for oom.
> > 
> 
> echo 1 > /proc/sys/vm/oom_dump_tasks can confirm that.
> 
yes.

> The bigger issue is making the distinction between killing a rogue task 
> that is using much more memory than expected (the supposed current 
> behavior, influenced from userspace by /proc/pid/oom_adj), and killing the 
> task with the highest rss. 

All kernel engineers know "than expected or not" can be never known to the kernel.
So, oom_adj workaround is used now. (by some special users.)
OOM Killer itself is also a workaround, too.
"No kill" is the best thing but we know there are tend to be memory-leaker on bad
systems and all systems in this world are not perfect.

In the kernel view, there is no difference between rogue one and highest rss one.
As heuristics, "time" is used now. But it's not very trustable.

> The latter is definitely desired if we are 
> allocating tons of memory but reduces the ability of the user to influence 
> the badness score.
> 

Yes, some more trustable values other than vmsize/rss/time are appriciated.
I wonder recent memory consumption speed can be an another key value.

Anyway, current bahavior of "killing X" is a bad thing.
We need some fixes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
