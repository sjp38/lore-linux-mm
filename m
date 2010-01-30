Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA5D76B0047
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 17:53:49 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o0UMrjBb030848
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 14:53:46 -0800
Received: from pzk29 (pzk29.prod.google.com [10.243.19.157])
	by spaceape11.eur.corp.google.com with ESMTP id o0UMrea9005763
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 14:53:41 -0800
Received: by pzk29 with SMTP id 29so3041572pzk.17
        for <linux-mm@kvack.org>; Sat, 30 Jan 2010 14:53:40 -0800 (PST)
Date: Sat, 30 Jan 2010 14:53:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
In-Reply-To: <4B642A40.1020709@gmail.com>
Message-ID: <alpine.DEB.2.00.1001301444480.16189@chino.kir.corp.google.com>
References: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com> <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk> <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com> <20100129163030.1109ce78@lxorguk.ukuu.org.uk>
 <5a0e6098f900aa36993b2b7f2320f927.squirrel@webmail-b.css.fujitsu.com> <alpine.DEB.2.00.1001291258490.2938@chino.kir.corp.google.com> <4B642A40.1020709@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1001301445031.16189@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jan 2010, Vedran Furac wrote:

> > The oom killer has been doing this for years and I haven't noticed a huge 
> > surge in complaints about it killing X specifically because of that code 
> > in oom_kill_process().
> 
> Well you said it yourself, you won't see a surge because "oom killer has
> been doing this *for years*". So you'll have a more/less constant number
> of complains over the years. Just google for: linux, random, kill, memory;
> 

You snipped the code segment where I demonstrated that the selected task 
for oom kill is not necessarily the one chosen to die: if there is a child 
with disjoint memory that is killable, it will be selected instead.  If 
Xorg or sshd is being chosen for kill, then you should investigate why 
that is, but there is nothing random about how the oom killer chooses 
tasks to kill.

The facts that you're completely ignoring are that changing the heuristic 
baseline to rss is not going to prevent Xorg or sshd from being selected 
(in fact, I even showed that it makes Xorg _more_ preferrable when I 
reviewed the patch), and you have complete power of disabling oom killing 
for selected tasks and that trait is inheritable to children.

I agree that we can do a better job than needlessly killing innocent tasks 
when we have a lowmem oom.  I suggested killing current in such a scenario 
since ZONE_DMA memory was not reclaimable (and, soon, not migratable) and 
all memory is pinned for such purposes.  However, saying we need to change 
the baseline for that particular case and completely misinterpret the 
oom_adj values for all system-wide tasks is simply not an option.  And 
when that point is raised, it doesn't help for people to take their ball 
and go home if their motivation is to improve the oom killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
