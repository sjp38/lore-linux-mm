Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5720C6B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 22:31:49 -0400 (EDT)
Received: by ywh26 with SMTP id 26so1442120ywh.12
        for <linux-mm@kvack.org>; Wed, 28 Oct 2009 19:31:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
	 <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
	 <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 29 Oct 2009 11:31:47 +0900
Message-ID: <28c262360910281931n57a3792elcf10ce0ff3f59815@mail.gmail.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 29, 2009 at 10:00 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> I'll wait until the next week to post a new patch.
>> We don't need rapid way.
>>
> I wrote above...but for my mental health, this is bug-fixed version.
> Sorry for my carelessness. David, thank you for your review.
> Regards,
> -Kame
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> It's reported that OOM-Killer kills Gnone/KDE at first...
> And yes, we can reproduce it easily.
>
> Now, oom-killer uses mm->total_vm as its base value. But in recent
> applications, there are a big gap between VM size and RSS size.
> Because
> =A0- Applications attaches much dynamic libraries. (Gnome, KDE, etc...)
> =A0- Applications may alloc big VM area but use small part of them.
> =A0 =A0(Java, and multi-threaded applications has this tendency because
> =A0 =A0 of default-size of stack.)
>
> I think using mm->total_vm as score for oom-kill is not good.
> By the same reason, overcommit memory can't work as expected.
> (In other words, if we depends on total_vm, using overcommit more positiv=
e
> =A0is a good choice.)
>
> This patch uses mm->anon_rss/file_rss as base value for calculating badne=
ss.
>
> Following is changes to OOM score(badness) on an environment with 1.6G me=
mory
> plus memory-eater(500M & 1G).
>
> Top 10 of badness score. (The highest one is the first candidate to be ki=
lled)
> Before
> badness program
> 91228 =A0 gnome-settings-
> 94210 =A0 clock-applet
> 103202 =A0mixer_applet2
> 106563 =A0tomboy
> 112947 =A0gnome-terminal
> 128944 =A0mmap =A0 =A0 =A0 =A0 =A0 =A0 =A0<----------- 500M malloc
> 129332 =A0nautilus
> 215476 =A0bash =A0 =A0 =A0 =A0 =A0 =A0 =A0<----------- parent of 2 malloc=
s.
> 256944 =A0mmap =A0 =A0 =A0 =A0 =A0 =A0 =A0<----------- 1G malloc
> 423586 =A0gnome-session
>
> After
> badness
> 1911 =A0 =A0mixer_applet2
> 1955 =A0 =A0clock-applet
> 1986 =A0 =A0xinit
> 1989 =A0 =A0gnome-session
> 2293 =A0 =A0nautilus
> 2955 =A0 =A0gnome-terminal
> 4113 =A0 =A0tomboy
> 104163 =A0mmap =A0 =A0 =A0 =A0 =A0 =A0 <----------- 500M malloc.
> 168577 =A0bash =A0 =A0 =A0 =A0 =A0 =A0 <----------- parent of 2 mallocs
> 232375 =A0mmap =A0 =A0 =A0 =A0 =A0 =A0 <----------- 1G malloc
>
> seems good for me. Maybe we can tweak this patch more,
> but this one will be a good one as a start point.
>
> Changelog: 2009/10/29
> =A0- use get_mm_rss() instead of get_mm_counter()
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Let's start from this.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
