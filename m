Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F0EB06B004F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 21:12:06 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R1CFGh022645
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 May 2009 10:12:16 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4849145DE4E
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:12:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FDC045DE55
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:12:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A3B161DB8040
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:12:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EB3E91DB8043
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:12:13 +0900 (JST)
Date: Wed, 27 May 2009 10:10:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Problem with oom-killer in memcg
Message-Id: <20090527101039.f9de2229.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A1BBEB3.1010701@hitachi.com>
References: <4A1BBEB3.1010701@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Satoru Moriya <satoru.moriya.br@hitachi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 19:04:35 +0900
Satoru Moriya <satoru.moriya.br@hitachi.com> wrote:

> Hi all,
> 
> When I tested memcg, I ran into a problem which causes system hang.
> 
> This is what I did.
> - make a cgroup named important for memory
> - add a process named big_memory into it
>   - big_memory uses a lot of memory(allocates memory repeatedly)
>   - big_memory's oom_adj is set to -17
> - after a while, the system will hang
> 
> Judging from syslog and outputs of console, I think we are in the busy
> loop below at that time.
> 1. oom-killer tries to kill big_memory because of memory shortage
> 2. oom-killer fails to kill big_memory because of oom_adj = -17
> 
> I think it's not good thing that troubles in cgroups affect 
> all over the system. 
> 
How many cpus are you using ?

> Further hardware and software details are found below.
> Please let me know if I should provide more information etc.
> 
> Regards,
> 

I think Balbir (and other people) is planning to add "oom handler" for memcg
or oom handler cgroup. But we need more study.

I assume that you use x86. If so, current bahavior is a bit complicated.

do_page_fault()
   -> allocate and charge memory account
         -> memcg's oom kill is called
              -> no progress.
User says "don't use OOM Kill" but no other way than "OOM Kill"

We don't have much choices here..
   - kill in force ?
   - add some sleep ?
   - freeze cgroup under OOM ? (this seems not easy)
   - Ask admin to increase size of memory limit ?

Thank you for reporting, but I can't think of quick fix right now.
I'll remember this in my TO-DO List.

Sorry.
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
