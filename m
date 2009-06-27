Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F95A6B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 08:07:40 -0400 (EDT)
Received: by gxk3 with SMTP id 3so4410783gxk.14
        for <linux-mm@kvack.org>; Sat, 27 Jun 2009 05:07:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <26537.1246086769@redhat.com>
References: <20090624023251.GA16483@localhost>
	 <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com>
	 <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com>
	 <20090618095729.d2f27896.akpm@linux-foundation.org>
	 <7561.1245768237@redhat.com> <3901.1245848839@redhat.com>
	 <26537.1246086769@redhat.com>
Date: Sat, 27 Jun 2009 21:07:52 +0900
Message-ID: <28c262360906270507i2df73c25ye70b10739df3db1f@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

HI, David.

First of all, Thanks for your effort to find out cause.

Unfortunately, I don't have followed your problem.
I guess you met OOM problem with no swap device. right ?

My patch shouldn't have affect yours.
The patch's motivation is following as.

"If our system have no swap device, we can't reclaim anon pages.
 So, anon pages's moving in anon lru list is unnecessary."

If we don't call shrink_active_list in shrink_zone's tail,
it can affect reclaim_stat->recent_[rotated|scanned].

Then it can affect number of pages for scanning in anon lru list.
But, Look at shrink_zone.

If we don't have swap device,  we never scan anon lru list forcely.
(anon lru's percent is always zero)

Nonetheless, OOM happen.

Hmm..
Could I show your oops and show_mem information, please ?

Rik, Kosaki, What do you think ?

On Sat, Jun 27, 2009 at 4:12 PM, David Howells<dhowells@redhat.com> wrote:
>
> I've managed to bisect things to find the commit that causes the OOMs. =
=C2=A0It's:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0commit 69c854817566db82c362797b4a6521d0b00fe1d=
8
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Author: MinChan Kim <minchan.kim@gmail.com>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Date: =C2=A0 Tue Jun 16 15:32:44 2009 -0700
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vmscan: prevent shrinking of act=
ive anon lru list in case of no swap space V3
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_zone() can deactivate act=
ive anon pages even if we don't have a
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0swap device. =C2=A0Many embedded=
 products don't have a swap device. =C2=A0So the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0deactivation of anon pages is un=
necessary.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This patch prevents unnecessary =
deactivation of anon lru pages. =C2=A0But, it
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0don't prevent aging of anon page=
s to swap out.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Signed-off-by: Minchan Kim <minc=
han.kim@gmail.com>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Acked-by: KOSAKI Motohiro <kosak=
i.motohiro@jp.fujitsu.com>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Cc: Johannes Weiner <hannes@cmpx=
chg.org>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Acked-by: Rik van Riel <riel@red=
hat.com>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Signed-off-by: Andrew Morton <ak=
pm@linux-foundation.org>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Signed-off-by: Linus Torvalds <t=
orvalds@linux-foundation.org>
>
> This exhibits the problem. =C2=A0The previous commit:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0commit 35282a2de4e5e4e173ab61aa9d7015886021a82=
1
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Author: Brice Goglin <Brice.Goglin@ens-lyon.or=
g>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Date: =C2=A0 Tue Jun 16 15:32:43 2009 -0700
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0migration: only migrate_prep() o=
nce per move_pages()
>
> survives 16 iterations of the LTP syscall testsuite without exhibiting th=
e
> problem.
>
> David
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
