Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C36946B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 08:30:20 -0500 (EST)
Received: by iwn5 with SMTP id 5so3083985iwn.11
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 05:30:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
	 <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
	 <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
Date: Sun, 1 Nov 2009 22:29:37 +0900
Message-ID: <2f11576a0911010529t688ed152qbb72c87c85869c45@mail.gmail.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com
List-ID: <linux-mm.kvack.org>

> This patch would pick the memory hogging task, "test", first everytime
> just like the current implementation does. =A0It would then prefer Xorg,
> icedove-bin, and ktorrent next as a starting point.
>
> Admittedly, there are other heuristics that the oom killer uses to create
> a badness score. =A0But since this patch is only changing the baseline fr=
om
> mm->total_vm to get_mm_rss(mm), its behavior in this test case do not
> match the patch description.
>
> The vast majority of the other ooms have identical top 8 candidates:
>
> total_vm
> 673222 test
> 195695 krunner
> 168881 plasma-desktop
> 130567 ktorrent
> 127081 knotify4
> 125881 icedove-bin
> 123036 akregator
> 121869 firefox-bin
>
> rss
> 672271 test
> 42192 Xorg
> 30763 firefox-bin
> 13292 icedove-bin
> 10208 ktorrent
> 9260 akregator
> 8859 plasma-desktop
> 7528 krunner
>
> firefox-bin seems much more preferred in this case than total_vm, but Xor=
g
> still ranks very high with this patch compared to the current
> implementation.

Hi David,

I'm very interesting your pointing out. thanks good testing.
So, I'd like to clarify your point a bit.

following are badness list on my desktop environment (x86_64 6GB mem).
it show Xorg have pretty small badness score. Do you know why such
different happen?


score    pid        comm
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
56382   3241    run-mozilla.sh
23345   3289    run-mozilla.sh
21461   3050    gnome-do
20079   2867    gnome-session
14016   3258    firefox
9212    3306    firefox
8468    3115    gnome-do
6902    3325    emacs
6783    3212    tomboy
4865    2968    python
4861    2948    nautilus
4221    1       init
(snip about 100line)
548     2590    Xorg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
