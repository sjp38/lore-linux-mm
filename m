Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EAE826B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 09:49:19 -0500 (EST)
Received: by fxm20 with SMTP id 20so425841fxm.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 06:49:17 -0800 (PST)
Subject: Re: [PATCH v2]mm/oom-kill: direct hardware access processes should
 get bonus
From: "Figo.zhang" <figo1802@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1011091307240.7730@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain>
	 <1289305468.10699.2.camel@localhost.localdomain>
	 <alpine.DEB.2.00.1011091307240.7730@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Nov 2010 22:48:16 +0800
Message-ID: <1289400496.10699.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: lkml <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-11-09 at 13:16 -0800, David Rientjes wrote:
> On Tue, 9 Nov 2010, Figo.zhang wrote:
> 
> >  
> > the victim should not directly access hardware devices like Xorg server,
> > because the hardware could be left in an unpredictable state, although 
> > user-application can set /proc/pid/oom_score_adj to protect it. so i think
> > those processes should get 3% bonus for protection.
> > 
> 
> The logic here is wrong: if killing these tasks can leave hardware in an 
> unpredictable state (and that state is presumably harmful), then they 
> should be completely immune from oom killing since you're still leaving 
> them exposed here to be killed.

we let the processes with hardware access get bonus for protection. the
goal is not select them to be killed as possible.


> 
> So the question that needs to be answered is: why do these threads deserve 
> to use 3% more memory (not >4%) than others without getting killed?  If 
> there was some evidence that these threads have a certain quantity of 
> memory they require as a fundamental attribute of CAP_SYS_RAWIO, then I 
> have no objection, but that's going to be expressed in a memory quantity 
> not a percentage as you have here.
> 
> The CAP_SYS_ADMIN heuristic has a background: it is used in the oom killer 
> because we have used the same 3% in __vm_enough_memory() for a long time 
> and we want consistency amongst the heuristics.  Adding additional bonuses 
> with arbitrary values like 3% of memory for things like CAP_SYS_RAWIO 
> makes the heuristic less predictable and moves us back toward the old 
> heuristic which was almost entirely arbitrary.


yes, i think it is be better those processes which be protection maybe
divided the badness score by 4, like old heuristic.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
