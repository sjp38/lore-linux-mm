Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D1A1C6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:16:18 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id oA9LGGxm022980
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 13:16:16 -0800
Received: from pvg6 (pvg6.prod.google.com [10.241.210.134])
	by kpbe16.cbf.corp.google.com with ESMTP id oA9LFvrH002240
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 13:16:14 -0800
Received: by pvg6 with SMTP id 6so551292pvg.9
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 13:16:14 -0800 (PST)
Date: Tue, 9 Nov 2010 13:16:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2]mm/oom-kill: direct hardware access processes should
 get bonus
In-Reply-To: <1289305468.10699.2.camel@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1011091307240.7730@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain> <1289305468.10699.2.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010, Figo.zhang wrote:

>  
> the victim should not directly access hardware devices like Xorg server,
> because the hardware could be left in an unpredictable state, although 
> user-application can set /proc/pid/oom_score_adj to protect it. so i think
> those processes should get 3% bonus for protection.
> 

The logic here is wrong: if killing these tasks can leave hardware in an 
unpredictable state (and that state is presumably harmful), then they 
should be completely immune from oom killing since you're still leaving 
them exposed here to be killed.

So the question that needs to be answered is: why do these threads deserve 
to use 3% more memory (not >4%) than others without getting killed?  If 
there was some evidence that these threads have a certain quantity of 
memory they require as a fundamental attribute of CAP_SYS_RAWIO, then I 
have no objection, but that's going to be expressed in a memory quantity 
not a percentage as you have here.

The CAP_SYS_ADMIN heuristic has a background: it is used in the oom killer 
because we have used the same 3% in __vm_enough_memory() for a long time 
and we want consistency amongst the heuristics.  Adding additional bonuses 
with arbitrary values like 3% of memory for things like CAP_SYS_RAWIO 
makes the heuristic less predictable and moves us back toward the old 
heuristic which was almost entirely arbitrary.

Now before KOSAKI-san comes out and says the old heuristic considered 
CAP_SYS_RAWIO and the new one does not so it _must_ be a regression: the 
old heuristic also divided the badness score by 4 for that capability as a 
completely arbitrary value (just like 3% is here).  Other traits like 
runtime and nice levels were also removed from the heuristic.  What needs 
to be shown is that CAP_SYS_RAWIO requires additional memory just to run 
or we should neglect to free 3% of memory, which could be gigabytes, 
because it has this trait.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
