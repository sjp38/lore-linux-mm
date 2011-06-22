Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 77BCD900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:22:25 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p5MNML6J022309
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:22:22 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by wpaz37.hot.corp.google.com with ESMTP id p5MNLvYf020073
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:22:20 -0700
Received: by pzd13 with SMTP id 13so1077670pzd.11
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:22:20 -0700 (PDT)
Date: Wed, 22 Jun 2011 16:22:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/6] oom: don't kill random process
In-Reply-To: <4E01C88E.3070806@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1106221617280.11759@chino.kir.corp.google.com>
References: <4E01C7D5.3060603@jp.fujitsu.com> <4E01C88E.3070806@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Wed, 22 Jun 2011, KOSAKI Motohiro wrote:

> CAI Qian reported oom-killer killed all system daemons in his
> system at first if he ran fork bomb as root. The problem is,
> current logic give them bonus of 3% of system ram. Example,
> he has 16GB machine, then root processes have ~500MB oom
> immune. It bring us crazy bad result. _all_ processes have
> oom-score=1 and then, oom killer ignore process memroy usage
> and kill random process. This regression is caused by commit
> a63d83f427 (oom: badness heuristic rewrite).
> 

Isn't it better to give admin processes a proportional bonus instead of a 
strict 3% bonus?  I suggested 1% per 10% of memory used earlier and I 
think it would work quite well as an alternative to this.  The highest 
bonus that would actually make any differences in which thread to kill 
would be 5% when an admin process is using 50% of memory: in that case, 
another non-admin thread would have to be using >45% of memory to be 
killed instead.

Would you be satisfied with something like

	points -= (points * 10 / totalpages);

be better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
