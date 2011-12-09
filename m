Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 344A36B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 08:41:08 -0500 (EST)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Fri, 9 Dec 2011 21:40:39 +0800
Subject: RE: [PATCH 1/3] slub: set a criteria for slub node partial adding
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B67236EED18@shsmsx502.ccr.corp.intel.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
 <alpine.DEB.2.00.1112020842280.10975@router.home>
 <1323419402.16790.6105.camel@debian>
 <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Eric Dumazet <eric.dumazet@gmail.com>

> > I did some experiments on add_partial judgment against rc4, like to put
> > the slub into node partial head or tail according to free objects, or
> > like Eric's suggest to combine the external parameter, like below:
> >
> >         n->nr_partial++;
> > -       if (tail =3D=3D DEACTIVATE_TO_TAIL)
> > +       if (tail =3D=3D DEACTIVATE_TO_TAIL ||
> > +               page->inuse > page->objects /2)
> >                 list_add_tail(&page->lru, &n->partial);
> >         else
> >                 list_add(&page->lru, &n->partial);
> >
> > But the result is out of my expectation before.
>=20
> I don't think you'll get consistent results for all workloads with
> something like this, some things may appear better and other things may
> appear worse.  That's why I've always disagreed with determining whether
> it should be added to the head or to the tail at the time of deactivation=
:
> you know nothing about frees happening to that slab subsequent to the
> decision you've made.  The only thing that's guaranteed is that you've
> through cache hot objects out the window and potentially increased the
> amount of internally fragmented slabs and/or unnecessarily long partial
> lists.

I said it not my original expectation doesn't mean my data has problem. :)=
=20
Of course any testing may have result variation. But it is benchmark accord=
ingly, and there are lot technical to tuning your testing to make its stand=
 division acceptable, like to sync your system in a clear status, to close =
unnecessary services, to use separate working disks for your testing etc. e=
tc. For this data, like on my SNB-EP machine, (the following data is not st=
ands for Intel, it is just my personal data).=20
4 times result of hackbench on this patch are 5.59, 5.475, 5.47833, 5.504
And more results on original rc4 are from 5.54 to 5.61, the stand division =
of results show is stable and believable on my side. But since in our handr=
eds benchmarks, only hackbench and loopback netperf is sensitive with slub =
change, and since it seems you did some testing on this. I thought you may =
like to do a double confirm with real data.=20

In fact, I also collected the 'perf stat' for cache missing or reference da=
ta, but that wave too much not stabled like hackbench itself.
=20
> Not sure what you're asking me to test, you would like this:
>=20
> 	{
> 	        n->nr_partial++;
> 	-       if (tail =3D=3D DEACTIVATE_TO_TAIL)
> 	-               list_add_tail(&page->lru, &n->partial);
> 	-       else
> 	-               list_add(&page->lru, &n->partial);
> 	+       list_add_tail(&page->lru, &n->partial);
> 	}
>=20
> with the statistics patch above?  I typically run with CONFIG_SLUB_STATS
> disabled since it impacts performance so heavily and I'm not sure what
> information you're looking for with regards to those stats.

NO, when you collect data, please close SLUB_STAT in kernel config.  _to_he=
ad statistics collection patch just tell you, I collected the statistics no=
t include add_partial in early_kmem_cache_node_alloc(). And other places of=
 add_partial were covered. Of course, the kernel with statistic can not be =
used to measure performance.=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
