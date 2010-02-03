Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C6CE96B007D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 02:50:25 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o137oMA8013797
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 3 Feb 2010 16:50:22 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 75DD545DE52
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:50:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 46D461EF083
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:50:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B3E6A1DB8042
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:50:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F4C51DB803A
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:50:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Improving OOM killer
In-Reply-To: <201002012302.37380.l.lunak@suse.cz>
References: <201002012302.37380.l.lunak@suse.cz>
Message-Id: <20100203164612.D3AC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  3 Feb 2010 16:50:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Lubos Lunak <l.lunak@suse.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

> =====
> --- linux-2.6.31/mm/oom_kill.c.sav      2010-02-01 22:00:41.614838540 +0100
> +++ linux-2.6.31/mm/oom_kill.c  2010-02-01 22:01:08.773757932 +0100
> @@ -69,7 +69,7 @@ unsigned long badness(struct task_struct
>         /*
>          * The memory size of the process is the basis for the badness.
>          */
> -       points = mm->total_vm;
> +       points = get_mm_rss(mm);
> 
>         /*
>          * After this unlock we can no longer dereference local variable `mm'
> @@ -83,21 +83,6 @@ unsigned long badness(struct task_struct
>                 return ULONG_MAX;
> 
>         /*
> -        * Processes which fork a lot of child processes are likely
> -        * a good choice. We add half the vmsize of the children if they
> -        * have an own mm. This prevents forking servers to flood the
> -        * machine with an endless amount of children. In case a single
> -        * child is eating the vast majority of memory, adding only half
> -        * to the parents will make the child our kill candidate of choice.
> -        */
> -       list_for_each_entry(child, &p->children, sibling) {
> -               task_lock(child);
> -               if (child->mm != mm && child->mm)
> -                       points += child->mm->total_vm/2 + 1;
> -               task_unlock(child);
> -       }
> -
> -       /*
>          * CPU time is in tens of seconds and run time is in thousands
>           * of seconds. There is no particular reason for this other than
>           * that it turned out to work very well in practice.
> =====
> 
>  In other words, use VmRSS for measuring memory usage instead of VmSize, and 
> remove child accumulating.
> 
>  I hope the above is good enough reason for the first change. VmSize includes 
> things like read-only mappings, memory mappings that is actually unused, 
> mappings backed by a file, mappings from video drivers, and so on. VmRSS is 
> actual real memory used, which is what mostly matters here. While it may not 
> be perfect, it is certainly an improvement.
> 
>  The second change should be done on the basis that it does more harm than 
> good. In this specific case, it does not help to identify the source of the 
> problem, and it incorrectly identifies kdeinit as the problem solely on the 
> basis that it spawned many other processes. I think it's already quite hinted 
> that this is a problem by the fact that you had to add a special protection 
> for init - any session manager, process launcher or even xterm used for 
> launching apps is yet another init.
> 
>  I also have problems finding a case where the child accounting would actually 
> help. I mean, in practice, I can certainly come up with something in theory, 
> and this looks to me like a solution to a very synthesized problem. In which 
> realistic case will one process launch a limited number of children, where 
> all of them will consume memory, but just killing the children one by one 
> won't avoid the problem reasonably? This is unlikely to avoid a forkbomb, as 
> in that case the number of children will be the problem. It is not necessary 
> for just one children misbehaving and being restarted, nor will it work 
> there. So what is that supposed to fix, and is it more likely than the case 
> of a process launching several unrelated children?
> 
>  If the children accounting is supposed to handle cases like forked children 
> of Apache, then I suggest it is adjusted only to count children that have 
> been forked from the parent but there has been no exec(). I'm afraid I don't 
> know how to detect that.
> 
> 
>  When running a kernel with these changes applied, I can safely do the 
> above-described case of running parallel doc generation in KDE. No clearly 
> innocent process is selected for killing, the first choice is always an 
> offender.
> 
>  Moreover, the remedy is almost instant, there is only a fraction of second of 
> when the machine is overloaded by the I/O of swapping pages in and out (I do 
> not use swap, but there is a large amount of memory used by read-only 
> mappings of binaries, libraries or various other files that is in the 
> original case rendering the machine unresponsive - I assume this is because 
> the kernel tries to kill an innocent process, but the offenders immediatelly 
> consume anything that is freed, requiring even memory used by code that is to 
> be executed to be swapped in from files again).
> 
>  I consider the patches to be definite improvements, so if they are ok, I will 
> format them as necessary. Now, what is the catch?

Personally, I think your use case represent to typical desktop and Linux
have to works fine on typical desktop use-case. /proc/pid/oom_adj never fit
desktop use-case. In past discussion, I'v agreed with much people. but I haven't
reach to agree with David Rientjes about this topic.

If you want to merge this patch, you need persuade him. I can't help you. sorry.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
