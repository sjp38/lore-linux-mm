Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 792E36B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 21:45:55 -0400 (EDT)
Received: by iwn33 with SMTP id 33so8734580iwn.14
        for <linux-mm@kvack.org>; Tue, 31 Aug 2010 18:45:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100901092430.9741.A69D9226@jp.fujitsu.com>
References: <20100901092430.9741.A69D9226@jp.fujitsu.com>
Date: Wed, 1 Sep 2010 10:45:48 +0900
Message-ID: <AANLkTikXfvEVXEyw_5_eJs2v-3J6Xhd=CT9X-0D+GMCA@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] vmscan: don't use return value trick when oom_killer_disabled
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi KOSAKI,

On Wed, Sep 1, 2010 at 9:31 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> M. Vefa Bicakci reported 2.6.35 kernel hang up when hibernation on his
> 32bit 3GB mem machine. (https://bugzilla.kernel.org/show_bug.cgi?id=3D167=
71)
> Also he was bisected first bad commit is below
>
> =A0commit bb21c7ce18eff8e6e7877ca1d06c6db719376e3c
> =A0Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> =A0Date: =A0 Fri Jun 4 14:15:05 2010 -0700
>
> =A0 =A0 vmscan: fix do_try_to_free_pages() return value when priority=3D=
=3D0 reclaim failure
>
> At first impression, this seemed very strange because the above commit on=
ly
> chenged function return value and hibernate_preallocate_memory() ignore
> return value of shrink_all_memory(). But it's related.
>
> Now, page allocation from hibernation code may enter infinite loop if
> the system has highmem.
>
> The reasons are two. 1) hibernate_preallocate_memory() call
> alloc_pages() wrong order 2) vmscan don't care enough OOM case when
> oom_killer_disabled.
>
> This patch only fix (2). Why is oom_killer_disabled so special?
> because when hibernation case, zone->all_unreclaimable never be turned on=
