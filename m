Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4EADF8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 05:04:01 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id oAFA3xHg028951
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:03:59 -0800
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by wpaz21.hot.corp.google.com with ESMTP id oAFA3vS0014843
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:03:58 -0800
Received: by pzk32 with SMTP id 32so1216965pzk.14
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:03:57 -0800 (PST)
Date: Mon, 15 Nov 2010 02:03:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2]mm/oom-kill: direct hardware access processes should
 get bonus
In-Reply-To: <20101115095446.BF00.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011150159330.2986@chino.kir.corp.google.com>
References: <20101112104140.DFFF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011141322590.22262@chino.kir.corp.google.com> <20101115095446.BF00.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010, KOSAKI Motohiro wrote:

> > I think in cases of heuristics like this where we obviously want to give 
> > some bonus to CAP_SYS_ADMIN that there is consistency with other bonuses 
> > given elsewhere in the kernel.
> 
> Keep comparision apple to apple. vm_enough_memory() account _virtual_ memory.
> oom-killer try to free _physical_ memory. It's unrelated.
> 

It's not unrelated, the LSM function gives an arbitrary 3% bonus to 
CAP_SYS_ADMIN.  Such threads should also be preferred in the oom killer 
over other threads since they tend to be more important but not an overly 
drastic bias such that they don't get killed when using an egregious 
amount of memory.  So in selecting a small percentage of memory that tends 
to be a significant bias but not overwhelming, I went with the 3% found 
elsewhere in the kernel.  __vm_enough_memory() doesn't have that 
preference for any scientifically calculated reason, it's a heuristic just 
like oom_badness().

> > > CAP_SYS_RAWIO mean the process has a direct hardware access privilege
> > > (eg X.org, RDB). and then, killing it might makes system crash.
> > > 
> > 
> > Then you would want to explicitly filter these tasks from oom kill just as 
> > OOM_SCORE_ADJ_MIN works rather than giving them a memory quantity bonus.
> 
> No. Why does userland recover your mistake?
> 

You just said killing any CAP_SYS_RAWIO task may make the system crash, so 
presuming that you don't want the system to crash, you are suggesting we 
should make these threads completely immune?  That's never been the case 
(and isn't for oom_kill_allocating_task, either), so there's no history 
you can draw from to support your argument.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
