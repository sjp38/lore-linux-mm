Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A50E86B0071
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 20:09:51 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M19mfX018275
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Jan 2010 10:09:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B4BE645DE6E
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:09:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 91E1245DE60
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:09:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F29E11DB8040
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:09:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D6271DB803B
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:09:43 +0900 (JST)
Date: Fri, 22 Jan 2010 10:06:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100122100628.593f3394.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361001211640w4ff6d61mdf682fa706ab61e@mail.gmail.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<1264087124.1818.15.camel@barrios-desktop>
	<20100122084856.600b2dd5.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001211640w4ff6d61mdf682fa706ab61e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Jan 2010 09:40:17 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Jan 22, 2010 at 8:48 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 22 Jan 2010 00:18:44 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> Hi, Kame.
> >>
> >> On Thu, 2010-01-21 at 14:59 +0900, KAMEZAWA Hiroyuki wrote:
> >> > A patch for avoiding oom-serial-killer at lowmem shortage.
> >> > Patch is onto mmotm-2010/01/15 (depends on mm-count-lowmem-rss.patch)
> >> > Tested on x86-64/SMP + debug module(to allocated lowmem), works well.
> >> >
> >> > ==
> >> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> >
> >> > One cause of OOM-Killer is memory shortage in lower zones.
> >> > (If memory is enough, lowmem_reserve_ratio works well. but..)
> >> >
> >> > In lowmem-shortage oom-kill, oom-killer choses a vicitim process
> >> > on their vm size. But this kills a process which has lowmem memory
> >> > only if it's lucky. At last, there will be an oom-serial-killer.
> >> >
> >> > Now, we have per-mm lowmem usage counter. We can make use of it
> >> > to select a good? victim.
> >> >
> >> > This patch does
> >> > A  - add CONSTRAINT_LOWMEM to oom's constraint type.
> >> > A  - pass constraint to __badness()
> >> > A  - change calculation based on constraint. If CONSTRAINT_LOWMEM,
> >> > A  A  use low_rss instead of vmsize.
> >>
> >> As far as low memory, it would be better to consider lowmem counter.
> >> But as you know, {vmsize VS rss} is debatable topic.
> >> Maybe someone doesn't like this idea.
> >>
> > About lowmem, vmsize never work well.
> >
> 
> Tend to agree with you.
> I am just worried about "vmsize lovers".
> 
> You removed considering vmsize totally.
> In case of LOWMEM, lowcount considering make sense.
> But never considering vmsize might be debatable.
> 
> So personllay, I thouhg we could add more weight lowcount
> in case of LOWMEM. But I chaged my mind.
> I think it make OOM heurisic more complated without big benefit.
> 
thanks. I don't want patch-drop again, either :)

> Simple is best.
> 
> >> So don't we need any test result at least?
> > My test result was very artificial, so I didn't attach the result.
> >
> > A - Before this patch, sshd was killed at first.
> > A - After this patch, memory consumer of low-rss was killed.
> 
> Okay. You already anwsered my question by Balbir's reply.
> I had a question it's real problem and how often it happens.
> 
> >
> >> If we don't have this patch, it happens several innocent process
> >> killing. but we can't prevent it by this patch.
> >>
> > I can't catch what you mean.
> 
> I just said your patch's benefit.
> 
> >> Sorry for bothering you.
> >>
> >
> > Hmm, boot option or CONFIG ? (CONFIG_OOMKILLER_EXTENSION ?)
> >
> > I'm now writing fork-bomb detector again and want to remove current
> > "gathering child's vm_size" heuristics. I'd like to put that under
> > the same config, too.
> 
> Totally, I don't like CONFIG option for that.
> But vmsize lovers also don't want to change current behavior.
> So it's desirable until your fork-form detector become mature and
> prove it's good.
> 
Hmm, Okay, I'll add some. Kosaki told me sysctl is better. I'll check
how it looks.

> One more questions about below.
> 
> +       if (constraint != CONSTRAINT_LOWMEM) {
> +               list_for_each_entry(child, &p->children, sibling) {
> +                       task_lock(child);
> +                       if (child->mm != mm && child->mm)
> +                               points += child->mm->total_vm/2 + 1;
> +                       task_unlock(child);
> +               }
> 
> Why didn't you consider child's lowmem counter in case of LOWMEM?
> 
Assume process A, B, C, D. B and C are children of A.
 
  A (low_rss = 0)
  B (low_rss = 20)
  C (low_rss = 20)
  D (low_rss = 20)

When we caluculate A's socre by above logic, A's score may be greater than
B and C, D. We do targetted oom-kill as sniper, not as genocider. So, ignoreing
children here is better, I think.
I'll add some explanation to changelog.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
