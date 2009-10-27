Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 00B086B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:39:05 -0400 (EDT)
Date: Tue, 27 Oct 2009 18:39:07 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
 RSS/swap value for oom_score (Re: Memory overcommit
In-Reply-To: <20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910271821130.11372@sister.anvils>
References: <hav57c$rso$1@ger.gmane.org> <hb2cfu$r08$2@ger.gmane.org>
 <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com>
 <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com>
 <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
 <2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
 <20091027153429.b36866c4.minchan.kim@barrios-desktop>
 <20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
 <28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
 <20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009, KAMEZAWA Hiroyuki wrote:
> Now, oom-killer's score uses mm->total_vm as its base value.
> But, in these days, applications like GUI program tend to use
> much shared libraries and total_vm grows too high even when
> pages are not fully mapped.
> 
> For example, running a program "mmap" which allocates 1 GBbytes of
> anonymous memory, oom_score top 10 on system will be..
> 
>  score  PID     name
>  89924	3938	mixer_applet2
>  90210	3942	tomboy
>  94753	3936	clock-applet
>  101994	3919	pulseaudio
>  113525	4028	gnome-terminal
>  127340	1	init
>  128177	3871	nautilus
>  151003	11515	bash
>  256944	11653	mmap <-----------------use 1G of anon
>  425561	3829	gnome-session
> 
> No one believes gnome-session is more guilty than "mmap".
> 
> Instead of total_vm, we should use anon/file/swap usage of a process, I think.
> This patch adds mm->swap_usage and calculate oom_score based on
>   anon_rss + file_rss + swap_usage.
> Considering usual applications, this will be much better information than
> total_vm. After this patch, the score on my desktop is
> 
> score   PID     name
> 4033	3176	gnome-panel
> 4077	3113	xinit
> 4526	3190	python
> 4820	3161	gnome-settings-
> 4989	3289	gnome-terminal
> 7105	3271	tomboy
> 8427	3177	nautilus
> 17549	3140	gnome-session
> 128501	3299	bash
> 256106	3383	mmap
> 
> This order is not bad, I think.
> 
> Note: This adss new counter...then new cost is added.

I've often thought we ought to supply such a swap_usage statistic;
and show it in /proc/pid/statsomething, presumably VmSwap in
/proc/pid/status, even an additional field on the end of statm.

A slight new cost, yes: doesn't matter at the swapping end, but
would slightly impact fork and exit - I do hope we can afford it,
because I think it should have been available all along.

I've not checked your patch in detail; but I do agree that basing
OOM (physical memory) decisions on total_vm (virtual memory) has
seemed weird, so it's well worth trying this approach.  Whether swap
should be included along with rss isn't quite clear to me: I'm not
saying you're wrong, not at all, just that it's not quite obvious.

I've several observations to make about bad OOM kill decisions,
but it's probably better that I make them in the original
"Memory overcommit" thread, rather than divert this thread.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
