Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E2FB08D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 15:55:14 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id oAFKtAxE028651
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 12:55:10 -0800
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by kpbe14.cbf.corp.google.com with ESMTP id oAFKt388017216
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 12:55:08 -0800
Received: by pzk4 with SMTP id 4so373661pzk.39
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 12:55:03 -0800 (PST)
Date: Mon, 15 Nov 2010 12:54:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Revert oom rewrite series
In-Reply-To: <20101115105735.0f9c1a22@lxorguk.ukuu.org.uk>
Message-ID: <alpine.DEB.2.00.1011151243460.8167@chino.kir.corp.google.com>
References: <1289402093.10699.25.camel@localhost.localdomain> <1289402666.10699.28.camel@localhost.localdomain> <20101114141913.E019.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011141330120.22262@chino.kir.corp.google.com> <4CE0A87E.1030304@leadcoretech.com>
 <alpine.DEB.2.00.1011150204060.2986@chino.kir.corp.google.com> <20101115105735.0f9c1a22@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Figo.zhang" <zhangtianfei@leadcoretech.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010, Alan Cox wrote:

> > The goal was to make the oom killer heuristic as predictable as possible 
> > and to kill the most memory-hogging task to avoid having to recall it and 
> > needlessly kill several tasks.
> 
> Meta question - why is that a good thing. In a desktop environment it's
> frequently wrong, in a server environment it is often wrong. We had this
> before where people spend months fiddling with the vm and make it work
> slightly differently and it suits their workload, then other workloads go
> downhill. Then the cycle repeats.
> 

Most of the arbitrary heuristics were removed from oom_badness(), things 
like nice level, runtime, CAP_SYS_RESOURCE, etc., so that we only consider 
the rss and swap usage of each application in comparison to each other 
when deciding which task to kill.  We give root tasks a 3% bonus since 
they tend to be more important to the productivity or uptime of the 
machine, which did exist -- albeit with a more dramatic impact -- in the 
old heursitic.

You'll find that the new heuristic always kills the task consuming the 
most amount of rss unless influenced by userspace via the tunables (or 
within 3% of root tasks).

We always want to kill the most memory-hogging task because it avoids 
needlessly killing additional tasks when we must immediately recall the 
oom killer because we continue to allocate memory.  If that task happens 
to be of vital importance to userspace, then the user has full control 
over tuning the oom killer priorities in such circumstances.

> > You have full control over disabling a task from being considered with 
> > oom_score_adj just like you did with oom_adj.  Since oom_adj is 
> > deprecated for two years, you can even use the old interface until then.
> 
> Which changeset added it to the Documentation directory as deprecated ?
> 

51b1bd2a was the actual change that deprecated it, which was a direct 
follow-up to a63d83f4 which actually obsoleted it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
