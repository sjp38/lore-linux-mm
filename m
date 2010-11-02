Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1497E8D0001
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 15:34:23 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id oA2JYLsJ006982
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 12:34:21 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by hpaq7.eem.corp.google.com with ESMTP id oA2JY95m029947
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 12:34:19 -0700
Received: by pwj3 with SMTP id 3so2152027pwj.5
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 12:34:19 -0700 (PDT)
Date: Tue, 2 Nov 2010 12:34:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH]oom-kill: direct hardware access processes should get
 bonus
In-Reply-To: <1288707894.19865.1.camel@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1011021228590.20105@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain> <alpine.DEB.2.00.1011012008160.9383@chino.kir.corp.google.com> <1288707894.19865.1.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Nov 2010, Figo.zhang wrote:

> > Which applications are you referring to that cannot gracefully exit if 
> > killed?
> 
> like Xorg server, if xorg server be killed, the gnome desktop will be
> crashed.
> 

Right, but you didn't explicitly prohibit such applications from being 
killed, so that suggests that doing so may be inconvenient but doesn't 
incur something like corruption or data loss, which is what I would 
consider "unstable" or "inconsistent" state.

We're trying to avoid any additional heuristics from being introduced for 
specific usecases, even for Xorg.  That ensures that the heuristic remains 
as predictable as possible and frees a large amount of memory.  If Xorg is 
being killed first instead of a true memory hogger, then it seems like a 
forkbomb scenario instead; could you please post your kernel log so that 
we can diagnose that issue seperately?

> > CAP_SYS_RAWIO had a much more dramatic impact in the previous heuristic to 
> > such a point that it would often allow memory hogging tasks to elude the 
> > oom killer at the expense of innocent tasks.  I'm not sure this is the 
> > best way to go.
> 
> is it some experiments for demonstration the  CAP_SYS_RAWIO will elude
> the oom killer?
> 

The old heuristic would allow it to elude the oom killer because it would 
divide the score by four if a task had the capability, which is a much 
more drastic "bonus" than you suggest here.  That would reduce the score 
for the memory hogging task significantly enough that we killed tons of 
innocent tasks instead before eventually killing the task that was leaking 
memory but failed to be identified because it had CAP_SYS_RAWIO.  I'm 
trying to avoid any such repeats.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
