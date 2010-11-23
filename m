Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ECAFF6B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:17:00 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7GwRM028365
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:16:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A4AF545DE4C
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E10B45DE4F
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B8C61DB8015
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CA87A1DB8017
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2]mm/oom-kill: direct hardware access processes should get bonus
In-Reply-To: <alpine.DEB.2.00.1011150159330.2986@chino.kir.corp.google.com>
References: <20101115095446.BF00.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011150159330.2986@chino.kir.corp.google.com>
Message-Id: <20101123154843.7B8D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:16:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 15 Nov 2010, KOSAKI Motohiro wrote:
> 
> > > I think in cases of heuristics like this where we obviously want to give 
> > > some bonus to CAP_SYS_ADMIN that there is consistency with other bonuses 
> > > given elsewhere in the kernel.
> > 
> > Keep comparision apple to apple. vm_enough_memory() account _virtual_ memory.
> > oom-killer try to free _physical_ memory. It's unrelated.
> > 
> 
> It's not unrelated, the LSM function gives an arbitrary 3% bonus to 
> CAP_SYS_ADMIN.  

Unrelated. LSM _is_ security module. and It only account virtual memory.


> Such threads should also be preferred in the oom killer 
> over other threads since they tend to be more important but not an overly 
> drastic bias such that they don't get killed when using an egregious 
> amount of memory.  So in selecting a small percentage of memory that tends 
> to be a significant bias but not overwhelming, I went with the 3% found 
> elsewhere in the kernel.  __vm_enough_memory() doesn't have that 
> preference for any scientifically calculated reason, it's a heuristic just 
> like oom_badness().

__vm_enough_memory() only gurard to memory overcommiting. And it doesn't
have any recover way. We expect admin should recover their HAND. In the
other hand, oom-killer _is_ automatic recover way. It's no need admin's 
hand. That's the reason why CAP_ADMIN is important or not.




> > > > CAP_SYS_RAWIO mean the process has a direct hardware access privilege
> > > > (eg X.org, RDB). and then, killing it might makes system crash.
> > > > 
> > > 
> > > Then you would want to explicitly filter these tasks from oom kill just as 
> > > OOM_SCORE_ADJ_MIN works rather than giving them a memory quantity bonus.
> > 
> > No. Why does userland recover your mistake?
> > 
> 
> You just said killing any CAP_SYS_RAWIO task may make the system crash, so 
> presuming that you don't want the system to crash, you are suggesting we 
> should make these threads completely immune?  That's never been the case 
> (and isn't for oom_kill_allocating_task, either), so there's no history 
> you can draw from to support your argument.

No. I only require YOU have to investigate userland usecase BEFORE making
change.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
