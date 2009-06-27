Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BF0126B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 11:50:44 -0400 (EDT)
Received: by gxk3 with SMTP id 3so4612336gxk.14
        for <linux-mm@kvack.org>; Sat, 27 Jun 2009 08:52:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090627125412.GA1667@cmpxchg.org>
References: <3901.1245848839@redhat.com> <20090624023251.GA16483@localhost>
	 <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com>
	 <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com>
	 <20090618095729.d2f27896.akpm@linux-foundation.org>
	 <7561.1245768237@redhat.com> <26537.1246086769@redhat.com>
	 <20090627125412.GA1667@cmpxchg.org>
Date: Sun, 28 Jun 2009 00:52:20 +0900
Message-ID: <2f11576a0906270852h520fef19p50b77fd441065f67@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Howells <dhowells@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "riel@redhat.com" <riel@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> Here is the patch in question:
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7592d8e..879d034 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1570,7 +1570,7 @@ static void shrink_zone(int priority, struct zone *=
zone,
> =A0 =A0 =A0 =A0 * Even if we did not try to evict anon pages at all, we w=
ant to
> =A0 =A0 =A0 =A0 * rebalance the anon lru active/inactive ratio.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc))
> + =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_active_list(SWAP_CLUSTER_MAX, zone,=
 sc, priority, 0);
>
> =A0 =A0 =A0 =A0throttle_vm_writeout(sc->gfp_mask);
>
> When this was discussed, I think we missed that nr_swap_pages can
> actually get zero on swap systems as well and this should have been
> total_swap_pages - otherwise we also stop balancing the two anon lists
> when swap is _full_ which was not the intention of this change at all.
>
> [ There is another one hiding in shrink_zone() that does the same - it
> was moved from get_scan_ratio() and is pretty old but we still kept
> the inactive/active ratio halfway sane without MinChan's patch. ]
>
> This is from your OOM-run dmesg, David:
>
> =A0Adding 32k swap on swapfile22. =A0Priority:-21 extents:1 across:32k
> =A0Adding 32k swap on swapfile23. =A0Priority:-22 extents:1 across:32k
> =A0Adding 32k swap on swapfile24. =A0Priority:-23 extents:3 across:44k
> =A0Adding 32k swap on swapfile25. =A0Priority:-24 extents:1 across:32k
>
> So we actually have swap? =A0Or are those removed again before the OOM?

[grep to ltp source file]

ltp/testcases/kernel/syscalls/swapon/swapon03.c makes a lot of swap,
but it was removed when the test exit.

Then, When OOM happed, David's system don't have any swap. I don't think
your patch strike the target, unfortunately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
