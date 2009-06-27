Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 87EDA6B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 09:48:53 -0400 (EDT)
Received: by yxe38 with SMTP id 38so2274744yxe.12
        for <linux-mm@kvack.org>; Sat, 27 Jun 2009 06:50:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090627125412.GA1667@cmpxchg.org>
References: <3901.1245848839@redhat.com> <20090624023251.GA16483@localhost>
	 <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com>
	 <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com>
	 <20090618095729.d2f27896.akpm@linux-foundation.org>
	 <7561.1245768237@redhat.com> <26537.1246086769@redhat.com>
	 <20090627125412.GA1667@cmpxchg.org>
Date: Sat, 27 Jun 2009 22:50:25 +0900
Message-ID: <28c262360906270650v6c276591u417d64573ecfba29@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Howells <dhowells@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi, Hannes.

On Sat, Jun 27, 2009 at 9:54 PM, Johannes Weiner<hannes@cmpxchg.org> wrote:
> On Sat, Jun 27, 2009 at 08:12:49AM +0100, David Howells wrote:
>>
>> I've managed to bisect things to find the commit that causes the OOMs. =
=C2=A0It's:
>>
>> =C2=A0 =C2=A0 =C2=A0 commit 69c854817566db82c362797b4a6521d0b00fe1d8
>> =C2=A0 =C2=A0 =C2=A0 Author: MinChan Kim <minchan.kim@gmail.com>
>> =C2=A0 =C2=A0 =C2=A0 Date: =C2=A0 Tue Jun 16 15:32:44 2009 -0700
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vmscan: prevent shrinking of active a=
non lru list in case of no swap space V3
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrink_zone() can deactivate active a=
non pages even if we don't have a
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 swap device. =C2=A0Many embedded prod=
ucts don't have a swap device. =C2=A0So the
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 deactivation of anon pages is unneces=
sary.
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 This patch prevents unnecessary deact=
ivation of anon lru pages. =C2=A0But, it
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 don't prevent aging of anon pages to =
swap out.
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Signed-off-by: Minchan Kim <minchan.k=
im@gmail.com>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Acked-by: KOSAKI Motohiro <kosaki.mot=
ohiro@jp.fujitsu.com>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Cc: Johannes Weiner <hannes@cmpxchg.o=
rg>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Acked-by: Rik van Riel <riel@redhat.c=
om>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Signed-off-by: Andrew Morton <akpm@li=
nux-foundation.org>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Signed-off-by: Linus Torvalds <torval=
ds@linux-foundation.org>
>>
>> This exhibits the problem. =C2=A0The previous commit:
>>
>> =C2=A0 =C2=A0 =C2=A0 commit 35282a2de4e5e4e173ab61aa9d7015886021a821
>> =C2=A0 =C2=A0 =C2=A0 Author: Brice Goglin <Brice.Goglin@ens-lyon.org>
>> =C2=A0 =C2=A0 =C2=A0 Date: =C2=A0 Tue Jun 16 15:32:43 2009 -0700
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 migration: only migrate_prep() once p=
er move_pages()
>>
>> survives 16 iterations of the LTP syscall testsuite without exhibiting t=
he
>> problem.
>
> Here is the patch in question:
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7592d8e..879d034 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1570,7 +1570,7 @@ static void shrink_zone(int priority, struct zone *=
zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Even if we did not try to evict anon pages =
at all, we want to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * rebalance the anon lru active/inactive rati=
o.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (inactive_anon_is_low(zone, sc))
> + =C2=A0 =C2=A0 =C2=A0 if (inactive_anon_is_low(zone, sc) && nr_swap_page=
s > 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_active_list=
(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0throttle_vm_writeout(sc->gfp_mask);
>
> When this was discussed, I think we missed that nr_swap_pages can
> actually get zero on swap systems as well and this should have been
> total_swap_pages - otherwise we also stop balancing the two anon lists
> when swap is _full_ which was not the intention of this change at all.

At that time we considered it so that we didn't prevent anon list
aging for background reclaim.
Do you think it is not enough ?



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
