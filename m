Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 9084B6B004F
	for <linux-mm@kvack.org>; Sun, 25 Dec 2011 05:22:15 -0500 (EST)
Message-ID: <1324808519.29243.8.camel@hakkenden.homenet>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
From: "Nikolay S." <nowhere@hakkenden.ath.cx>
Date: Sun, 25 Dec 2011 14:21:59 +0400
In-Reply-To: <CAJd=RBDa4LT1gbh6zPx+bzoOtSUeX=puJe6DVC-WyKoF4nw-dg@mail.gmail.com>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	 <20111221095249.GA28474@tiehlicka.suse.cz> <20111221225512.GG23662@dastard>
	 <1324630880.562.6.camel@rybalov.eng.ttk.net>
	 <20111223102027.GB12731@dastard>
	 <1324638242.562.15.camel@rybalov.eng.ttk.net>
	 <20111223204503.GC12731@dastard>
	 <CAJd=RBDa4LT1gbh6zPx+bzoOtSUeX=puJe6DVC-WyKoF4nw-dg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

=D0=92 =D0=92=D1=81., 25/12/2011 =D0=B2 17:09 +0800, Hillf Danton =D0=BF=D0=
=B8=D1=88=D0=B5=D1=82:
> On Sat, Dec 24, 2011 at 4:45 AM, Dave Chinner <david@fromorbit.com> wrote=
:
> [...]
> >
> > Ok, it's not a shrink_slab() problem - it's just being called ~100uS
> > by kswapd. The pattern is:
> >
> >        - reclaim 94 (batches of 32,32,30) pages from iinactive list
> >          of zone 1, node 0, prio 12
> >        - call shrink_slab
> >                - scan all caches
> >                - all shrinkers return 0 saying nothing to shrink
> >        - 40us gap
> >        - reclaim 10-30 pages from inactive list of zone 2, node 0, prio=
 12
> >        - call shrink_slab
> >                - scan all caches
> >                - all shrinkers return 0 saying nothing to shrink
> >        - 40us gap
> >        - isolate 9 pages from LRU zone ?, node ?, none isolated, none f=
reed
> >        - isolate 22 pages from LRU zone ?, node ?, none isolated, none =
freed
> >        - call shrink_slab
> >                - scan all caches
> >                - all shrinkers return 0 saying nothing to shrink
> >        40us gap
> >
> > And it just repeats over and over again. After a while, nid=3D0,zone=3D=
1
> > drops out of the traces, so reclaim only comes in batches of 10-30
> > pages from zone 2 between each shrink_slab() call.
> >
> > The trace starts at 111209.881s, with 944776 pages on the LRUs. It
> > finishes at 111216.1 with kswapd going to sleep on node 0 with
> > 930067 pages on the LRU. So 7 seconds to free 15,000 pages (call it
> > 2,000 pages/s) which is awfully slow....
> >
> Hi all,
>=20
> In hope, the added debug info is helpful.
>=20
> Hillf
> ---
>=20
> --- a/mm/memcontrol.c	Fri Dec  9 21:57:40 2011
> +++ b/mm/memcontrol.c	Sun Dec 25 17:08:14 2011
> @@ -1038,7 +1038,11 @@ void mem_cgroup_lru_del_list(struct page
>  		memcg =3D root_mem_cgroup;
>  	mz =3D page_cgroup_zoneinfo(memcg, page);
>  	/* huge page split is done under lru_lock. so, we have no races. */
> -	MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 << compound_order(page);
> +	if (WARN_ON_ONCE(MEM_CGROUP_ZSTAT(mz, lru) <
> +				(1 << compound_order(page))))
> +		MEM_CGROUP_ZSTAT(mz, lru) =3D 0;
> +	else
> +		MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 << compound_order(page);
>  }
>=20
>  void mem_cgroup_lru_del(struct page *page)

Hello,

Uhm.., is this patch against 3.2-rc4? I can not apply it. There's no
mem_cgroup_lru_del_list(), but void mem_cgroup_del_lru_list(). Should I
place changes there?

And also, -rc7 is here. May the problem be addressed as part of some
ongoing work? Is there any reason to try -rc7 (the problem requires
several days of uptime to become obvious)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
