Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DE37E6B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 04:32:09 -0400 (EDT)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id n9T8W5qO008640
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 08:32:05 GMT
Received: from pwi18 (pwi18.prod.google.com [10.241.219.18])
	by spaceape7.eur.corp.google.com with ESMTP id n9T8W1Pf015466
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 01:32:02 -0700
Received: by pwi18 with SMTP id 18so1363746pwi.16
        for <linux-mm@kvack.org>; Thu, 29 Oct 2009 01:32:01 -0700 (PDT)
Date: Thu, 29 Oct 2009 01:31:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com> <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
 <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009, KAMEZAWA Hiroyuki wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> It's reported that OOM-Killer kills Gnone/KDE at first...
> And yes, we can reproduce it easily.
> 
> Now, oom-killer uses mm->total_vm as its base value. But in recent
> applications, there are a big gap between VM size and RSS size.
> Because
>   - Applications attaches much dynamic libraries. (Gnome, KDE, etc...)
>   - Applications may alloc big VM area but use small part of them.
>     (Java, and multi-threaded applications has this tendency because
>      of default-size of stack.)
> 
> I think using mm->total_vm as score for oom-kill is not good.
> By the same reason, overcommit memory can't work as expected.
> (In other words, if we depends on total_vm, using overcommit more positive
>  is a good choice.)
> 
> This patch uses mm->anon_rss/file_rss as base value for calculating badness.
> 
> Following is changes to OOM score(badness) on an environment with 1.6G memory
> plus memory-eater(500M & 1G).
> 
> Top 10 of badness score. (The highest one is the first candidate to be killed)
> Before
> badness program
> 91228	gnome-settings-
> 94210	clock-applet
> 103202	mixer_applet2
> 106563	tomboy
> 112947	gnome-terminal
> 128944	mmap              <----------- 500M malloc
> 129332	nautilus
> 215476	bash              <----------- parent of 2 mallocs.
> 256944	mmap              <----------- 1G malloc
> 423586	gnome-session
> 
> After
> badness 
> 1911	mixer_applet2
> 1955	clock-applet
> 1986	xinit
> 1989	gnome-session
> 2293	nautilus
> 2955	gnome-terminal
> 4113	tomboy
> 104163	mmap             <----------- 500M malloc.
> 168577	bash             <----------- parent of 2 mallocs
> 232375	mmap             <----------- 1G malloc
> 
> seems good for me. Maybe we can tweak this patch more,
> but this one will be a good one as a start point.
> 

This appears to actually prefer X more than total_vm in Vedran's test 
case.  He cited http://pastebin.com/f3f9674a0 in 
http://marc.info/?l=linux-kernel&m=125678557002888.

There are 12 ooms in this log, which has /proc/sys/vm/oom_dump_tasks 
enabled.  It shows the difference between the top total_vm candidates vs. 
the top rss candidates.

total_vm
708945 test
195695 krunner
168881 plasma-desktop
130567 ktorrent
127081 knotify4
125881 icedove-bin
123036 akregator
118641 kded4

rss
707878 test
42201 Xorg
13300 icedove-bin
10209 ktorrent
9277 akregator
8878 plasma-desktop
7546 krunner
4532 mysqld

This patch would pick the memory hogging task, "test", first everytime 
just like the current implementation does.  It would then prefer Xorg, 
icedove-bin, and ktorrent next as a starting point.

Admittedly, there are other heuristics that the oom killer uses to create 
a badness score.  But since this patch is only changing the baseline from 
mm->total_vm to get_mm_rss(mm), its behavior in this test case do not 
match the patch description.

The vast majority of the other ooms have identical top 8 candidates:

total_vm
673222 test
195695 krunner
168881 plasma-desktop
130567 ktorrent
127081 knotify4
125881 icedove-bin
123036 akregator
121869 firefox-bin

rss
672271 test
42192 Xorg
30763 firefox-bin
13292 icedove-bin
10208 ktorrent
9260 akregator
8859 plasma-desktop
7528 krunner

firefox-bin seems much more preferred in this case than total_vm, but Xorg 
still ranks very high with this patch compared to the current 
implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
