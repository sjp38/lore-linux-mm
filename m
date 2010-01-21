Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C92CF6B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 18:52:23 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0LNqFKc002695
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Jan 2010 08:52:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E9D9845DE4D
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:52:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CC6D245DE50
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:52:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 924531DB803B
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:52:14 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D4D21DB803C
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:52:14 +0900 (JST)
Date: Fri, 22 Jan 2010 08:48:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100122084856.600b2dd5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1264087124.1818.15.camel@barrios-desktop>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<1264087124.1818.15.camel@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Jan 2010 00:18:44 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Kame. 
> 
> On Thu, 2010-01-21 at 14:59 +0900, KAMEZAWA Hiroyuki wrote:
> > A patch for avoiding oom-serial-killer at lowmem shortage.
> > Patch is onto mmotm-2010/01/15 (depends on mm-count-lowmem-rss.patch)
> > Tested on x86-64/SMP + debug module(to allocated lowmem), works well.
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > One cause of OOM-Killer is memory shortage in lower zones.
> > (If memory is enough, lowmem_reserve_ratio works well. but..)
> > 
> > In lowmem-shortage oom-kill, oom-killer choses a vicitim process
> > on their vm size. But this kills a process which has lowmem memory
> > only if it's lucky. At last, there will be an oom-serial-killer.
> > 
> > Now, we have per-mm lowmem usage counter. We can make use of it
> > to select a good? victim.
> > 
> > This patch does
> >   - add CONSTRAINT_LOWMEM to oom's constraint type.
> >   - pass constraint to __badness()
> >   - change calculation based on constraint. If CONSTRAINT_LOWMEM,
> >     use low_rss instead of vmsize.
> 
> As far as low memory, it would be better to consider lowmem counter.
> But as you know, {vmsize VS rss} is debatable topic.
> Maybe someone doesn't like this idea. 
> 
About lowmem, vmsize never work well.

> So don't we need any test result at least?
My test result was very artificial, so I didn't attach the result.

 - Before this patch, sshd was killed at first.
 - After this patch, memory consumer of low-rss was killed.

> If we don't have this patch, it happens several innocent process
> killing. but we can't prevent it by this patch. 
> 
I can't catch what you mean.

> Sorry for bothering you.
> 

Hmm, boot option or CONFIG ? (CONFIG_OOMKILLER_EXTENSION ?)

I'm now writing fork-bomb detector again and want to remove current
"gathering child's vm_size" heuristics. I'd like to put that under
the same config, too.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
