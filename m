Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F283E6B0044
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 20:29:30 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBB1TSiJ001133
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Dec 2009 10:29:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1248845DE58
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 10:29:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A513D45DE4E
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 10:29:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6981D1DB805D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 10:29:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 02ABFE1800F
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 10:29:27 +0900 (JST)
Date: Fri, 11 Dec 2009 10:26:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
Message-Id: <20091211102629.4fe1ac43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262360912101725ydb0a0d9i12a91c1d4fe57672@mail.gmail.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360912101640y4b90db76w61a7a5dab5f8e796@mail.gmail.com>
	<20091211095159.6472a009.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360912101725ydb0a0d9i12a91c1d4fe57672@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Fri, 11 Dec 2009 10:25:03 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Dec 11, 2009 at 9:51 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 11 Dec 2009 09:40:07 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >> >A static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
> >> > A {
> >> > - A  A  A  return (unsigned long)atomic_long_read(&(mm)->counters[member]);
> >> > + A  A  A  long ret;
> >> > + A  A  A  /*
> >> > + A  A  A  A * Because this counter is loosely synchronized with percpu cached
> >> > + A  A  A  A * information, it's possible that value gets to be minus. For user's
> >> > + A  A  A  A * convenience/sanity, avoid returning minus.
> >> > + A  A  A  A */
> >> > + A  A  A  ret = atomic_long_read(&(mm)->counters[member]);
> >> > + A  A  A  if (unlikely(ret < 0))
> >> > + A  A  A  A  A  A  A  return 0;
> >> > + A  A  A  return (unsigned long)ret;
> >> > A }
> >>
> >> Now, your sync point is only task switching time.
> >> So we can't show exact number if many counting of mm happens
> >> in short time.(ie, before context switching).
> >> It isn't matter?
> >>
> > I think it's not a matter from 2 reasons.
> >
> > 1. Now, considering servers which requires continuous memory usage monitoring
> > as ps/top, when there are 2000 processes, "ps -elf" takes 0.8sec.
> > Because system admins know that gathering process information consumes
> > some amount of cpu resource, they will not do that so frequently.(I hope)
> >
> > 2. When chains of page faults occur continously in a period, the monitor
> > of memory usage just see a snapshot of current numbers and "snapshot of what
> > moment" is at random, always. No one can get precise number in that kind of situation.
> >
> 
> Yes. I understand that.
> 
> But we did rss updating as batch until now.
> It was also stale. Just only your patch make stale period longer.
> Hmm. I hope people don't expect mm count is precise.
> 
I hope so, too...

> I saw the many people believed sanpshot of mm counting is real in
> embedded system.
> They want to know the exact memory usage in system.
> Maybe embedded system doesn't use SPLIT_LOCK so that there is no regression.
> 
> At least, I would like to add comment "It's not precise value." on
> statm's Documentation.

Ok, I'll will do.

> Of course, It's off topic.  :)
> 
> Thanks for commenting. Kame.

Thank you for review.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
