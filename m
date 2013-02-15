Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2F8DE6B007D
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:22:03 -0500 (EST)
From: Seiji Aguchi <seiji.aguchi@hds.com>
Subject: RE: extra free kbytes tunable
Date: Fri, 15 Feb 2013 22:21:58 +0000
Message-ID: <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com>
References: <alpine.DEB.2.02.1302111734090.13090@dflat>
In-Reply-To: <alpine.DEB.2.02.1302111734090.13090@dflat>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dormando <dormando@rydia.net>, Rik van Riel <riel@redhat.com>, Satoru
 Moriya <satoru.moriya@hds.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hughd@google.com" <hughd@google.com>

Rik, Satoru,

Do you have any comments?

Seiji

> -----Original Message-----
> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-owner@vger.=
kernel.org] On Behalf Of dormando
> Sent: Monday, February 11, 2013 9:01 PM
> To: Rik van Riel
> Cc: Randy Dunlap; Satoru Moriya; linux-kernel@vger.kernel.org; linux-mm@k=
vack.org; lwoodman@redhat.com; Seiji Aguchi;
> akpm@linux-foundation.org; hughd@google.com
> Subject: extra free kbytes tunable
>=20
> Hi,
>=20
> As discussed in this thread:
> http://marc.info/?l=3Dlinux-mm&m=3D131490523222031&w=3D2
> (with this cleanup as well: https://lkml.org/lkml/2011/9/2/225)
>=20
> A tunable was proposed to allow specifying the distance between pages_min=
 and the low watermark before kswapd is kicked in to
> free up pages. I'd like to re-open this thread since the patch did not ap=
pear to go anywhere.
>=20
> We have a server workload wherein machines with 100G+ of "free" memory (u=
sed by page cache), scattered but frequent random io
> reads from 12+ SSD's, and 5gbps+ of internet traffic, will frequently hit=
 direct reclaim in a few different ways.
>=20
> 1) It'll run into small amounts of reclaim randomly (a few hundred thousa=
nd).
>=20
> 2) A burst of reads or traffic can cause extra pressure, which kswapd occ=
asionally responds to by freeing up 40g+ of the pagecache all
> at once
> (!) while pausing the system (Argh).
>=20
> 3) A blip in an upstream provider or failover from a peer causes the kern=
el to allocate massive amounts of memory for retransmission
> queues/etc, potentially along with buffered IO reads and (some, but not o=
ften a ton) of new allocations from an application. This
> paired with 2) can cause the box to stall for 15+ seconds.
>=20
> We're seeing this more in 3.4/3.5/3.6, saw it less in 2.6.38. Mass reclai=
ms are more common in newer kernels, but reclaims still happen
> in all kernels without raising min_free_kbytes dramatically.
>=20
> I've found that setting "lowmem_reserve_ratio" to something like "1 1 32"
> (thus protecting the DMA32 zone) causes 2) to happen less often, and is g=
enerally less violent with 1).
>=20
> Setting min_free_kbytes to 15G or more, paired with the above, has been t=
he best at mitigating the issue. This is simply trying to raise
> the distance between the min and low watermarks. With min_free_kbytes set=
 to 15000000, that gives us a whopping 1.8G (!!!) of
> leeway before slamming into direct reclaim.
>=20
> So, this patch is unfortunate but wonderful at letting us reclaim 10G+ of=
 otherwise lost memory. Could we please revisit it?
>=20
> I saw a lot of discussion on doing this automatically, or making kswapd m=
ore efficient to it, and I'd love to do that. Beyond making
> kswapd psychic I haven't seen any better options yet.
>=20
> The issue is more complex than simply having an application warn of an im=
pending allocation, since this can happen via read load on
> disk or from kernel page allocations for the network, or a combination of=
 the two (or three, if you add the app back in).
>=20
> It's going to get worse as we push machines with faster SSD's and bigger =
networks. I'm open to any ideas on how to make kswapd
> more efficient in our case, or really anything at all that works.
>=20
> I have more details, but cut it down as much as I could for this mail.
>=20
> Thanks,
> -Dormando
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n the body of a message to majordomo@vger.kernel.org More
> majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
