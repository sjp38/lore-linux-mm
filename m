Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 824546B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 22:10:49 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id nA43Afbn010116
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 19:10:41 -0800
Received: from pzk16 (pzk16.prod.google.com [10.243.19.144])
	by spaceape14.eur.corp.google.com with ESMTP id nA43Ab1Z031891
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 19:10:38 -0800
Received: by pzk16 with SMTP id 16so4473929pzk.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 19:10:37 -0800 (PST)
Date: Tue, 3 Nov 2009 19:10:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091104111703.b46ae72b.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911031905390.11790@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com> <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com> <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com> <4AE97861.1070902@gmail.com> <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
 <20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910300200170.18076@chino.kir.corp.google.com> <20091030183638.1125c987.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911031240470.29695@chino.kir.corp.google.com>
 <20091104095021.5532e913.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911031752180.1187@chino.kir.corp.google.com> <20091104111703.b46ae72b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:

> My point and your point are differnt.
> 
>   1. All my concern is "baseline for heuristics"
>   2. All your concern is "baseline for knob, as oom_adj"
> 
> ok ? For selecting victim by the kernel, dynamic value is much more useful.
> Current behavior of "Random kill" and "Kill multiple processes" are too bad.
> Considering oom-killer is for what, I think "1" is more important.
> 
> But I know what you want, so, I offers new knob which is not affected by RSS
> as I wrote in previous mail.
> 
> Off-topic:
> As memcg is growing better, using OOM-Killer for resource control should be
> ended, I think. Maybe Fake-NUMA+cpuset is working well for google system, 
> but plz consider to use memcg. 
> 

I understand what you're trying to do, and I agree with it for most 
desktop systems.  However, I think that admins should have a very strong 
influence in what tasks the oom killer kills.  It doesn't really matter if 
it's via oom_adj or not, and its debatable whether an adjustment on a 
static heuristic score is in our best interest in the first place.  But we 
must have an alternative so that our control over oom killing isn't lost.

I'd also like to open another topic for discussion if you're proposing 
such sweeping changes: at what point do we allow ~__GFP_NOFAIL allocations 
to fail even if order < PAGE_ALLOC_COSTLY_ORDER and defer killing 
anything?  We both agreed that it's not always in the best interest to 
kill a task so that an allocation can succeed, so we need to define some 
criteria to simply fail the allocation instead.

> Old processes are important, younger are not. But as I wrote, I'll drop
> most of patch "6". So, plz forget about this part.
> 
> I'm interested in fork-bomb killer rather than crazy badness calculation, now.
> 

Ok, great.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
