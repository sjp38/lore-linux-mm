Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4E8F86B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 22:22:39 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA43Ma26013907
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 12:22:36 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 49D3745DE50
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 12:22:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 11BD845DE58
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 12:22:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A70071DB8041
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 12:22:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F3FF7E38005
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 12:22:34 +0900 (JST)
Date: Wed, 4 Nov 2009 12:19:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091104121952.07ea695a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911031905390.11790@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org>
	<alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
	<20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com>
	<20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com>
	<4AE97861.1070902@gmail.com>
	<alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
	<20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910300200170.18076@chino.kir.corp.google.com>
	<20091030183638.1125c987.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031240470.29695@chino.kir.corp.google.com>
	<20091104095021.5532e913.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031752180.1187@chino.kir.corp.google.com>
	<20091104111703.b46ae72b.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031905390.11790@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009 19:10:34 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > My point and your point are differnt.
> > 
> >   1. All my concern is "baseline for heuristics"
> >   2. All your concern is "baseline for knob, as oom_adj"
> > 
> > ok ? For selecting victim by the kernel, dynamic value is much more useful.
> > Current behavior of "Random kill" and "Kill multiple processes" are too bad.
> > Considering oom-killer is for what, I think "1" is more important.
> > 
> > But I know what you want, so, I offers new knob which is not affected by RSS
> > as I wrote in previous mail.
> > 
> > Off-topic:
> > As memcg is growing better, using OOM-Killer for resource control should be
> > ended, I think. Maybe Fake-NUMA+cpuset is working well for google system, 
> > but plz consider to use memcg. 
> > 
> 
> I understand what you're trying to do, and I agree with it for most 
> desktop systems.  However, I think that admins should have a very strong 
> influence in what tasks the oom killer kills.  It doesn't really matter if 
> it's via oom_adj or not, and its debatable whether an adjustment on a 
> static heuristic score is in our best interest in the first place.  But we 
> must have an alternative so that our control over oom killing isn't lost.
> 
I'll not go too quickly, so, let's discuss and rewrite patches more, later.
I'll parepare new version in the next week. For this week, I'll post
swap accounting and improve fork-bomb detector.

> I'd also like to open another topic for discussion if you're proposing 
> such sweeping changes: at what point do we allow ~__GFP_NOFAIL allocations 
> to fail even if order < PAGE_ALLOC_COSTLY_ORDER and defer killing 
> anything?  We both agreed that it's not always in the best interest to 
> kill a task so that an allocation can succeed, so we need to define some 
> criteria to simply fail the allocation instead.
> 
Yes, I think allocation itself (> order=0) should fail more before we finally
invoke OOM. It tends to be soft-landing rather than oom-killer.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
