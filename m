Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1E6926B007E
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 20:25:24 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S0PLkq020939
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 09:25:21 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4814945DE70
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:25:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 206CA45DE4D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:25:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A9515E18006
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:25:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 500471DB803E
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:25:20 +0900 (JST)
Date: Wed, 28 Oct 2009 09:22:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
 RSS/swap value for oom_score (Re: Memory overcommit
Message-Id: <20091028092251.8ddd1b20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091027123810.GA22830@random.random>
References: <4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
	<20091027153429.b36866c4.minchan.kim@barrios-desktop>
	<20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
	<20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20091027165612.4122d600.minchan.kim@barrios-desktop>
	<20091027123810.GA22830@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 13:38:10 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Tue, Oct 27, 2009 at 04:56:12PM +0900, Minchan Kim wrote:
> > Thanks for making the patch.
> > Let's hear other's opinion. :)
> 
> total_vm is nearly meaningless, especially on 64bit that reduces the
> mmap load on libs, I tried to change it to something "physical" (rss,
> didn't add swap too) some time ago too, not sure why I didn't manage
> to get it in. Trying again surely sounds good. Accounting swap isn't
> necessarily good, we may be killing a task that isn't accessing memory
> at all. So yes, we free swap but if the task is the "bloater" it's
> unlikely to be all in swap as it did all recent activity that lead to
> the oom. So I'm unsure if swap is good to account here, but surely I
> ack to replace virtual with rss. I would include the whole rss, as the
> file one may also be rendered unswappable if it is accessed in a loop
> refreshing the young bit all the time.
> 
I wonder I'll acccounting swap and export it via /proc/<pid>/??? file.
So, I'll divide this patch into 2 part as swap accounting/oom patch.

Considering amount of swap at oom isn't very bad, I think. But using the
same weight to rss and swap is not good, maybe.

Hmm, maybe
   anon_rss + file_rss/2 + swap_usage/4 + kosaki's time accounting change
can give us some better value. I'll consider what number is logical and
technically correct, again.

I'll prepare series of 2-4? patches.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
