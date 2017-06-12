Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02C506B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 00:28:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d5so5587381pfe.2
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 21:28:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j1sor3570762pld.6.2017.06.11.21.28.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Jun 2017 21:28:36 -0700 (PDT)
Date: Mon, 12 Jun 2017 12:28:32 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170612042832.GA7429@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170608122318.31598-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
In-Reply-To: <20170608122318.31598-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>movable_node kernel parameter allows to make hotplugable NUMA
>nodes to put all the hotplugable memory into movable zone which
>allows more or less reliable memory hotremove.  At least this
>is the case for the NUMA nodes present during the boot (see
>find_zone_movable_pfns_for_nodes).
>

When movable_node is enabled, we would have overlapped zones, right?
To be specific, only ZONE_MOVABLE could have memory ranges belongs to other
zones.

This looks a little different in the whole ZONE design.

>This is not the case for the memory hotplug, though.
>
>	echo online > /sys/devices/system/memory/memoryXYZ/status
>
>will default to a kernel zone (usually ZONE_NORMAL) unless the
>particular memblock is already in the movable zone range which is not
            ^^^

Here is memblock or a memory_block?

>the case normally when onlining the memory from the udev rule context
>for a freshly hotadded NUMA node. The only option currently is to have a

So the semantic you want to change here is to make the memory_block in
ZONE_MOVABLE when movable_node is enabled.

Besides this, movable_node is enabled, what other requirements? Like, this
memory_block should next to current ZONE_MOVABLE ? or something else?

>special udev rule to echo online_movable to all memblocks belonging to
>such a node which is rather clumsy. Not the mention this is inconsistent
                                         ^^^

Hmm... "Not to mentions" looks more understandable.

BTW, I am not a native speaker. If this usage is correct, just ignore this
comment.

>as well because what ended up in the movable zone during the boot will
>end up in a kernel zone after hotremove & hotadd without special care.
>
>It would be nice to reuse memblock_is_hotpluggable but the runtime
>hotplug doesn't have that information available because the boot and
>hotplug paths are not shared and it would be really non trivial to
>make them use the same code path because the runtime hotplug doesn't
>play with the memblock allocator at all.
>
>Teach move_pfn_range that MMOP_ONLINE_KEEP can use the movable zone if
>movable_node is enabled and the range doesn't overlap with the existing
>normal zone. This should provide a reasonable default onlining strategy.
>
>Strictly speaking the semantic is not identical with the boot time
>initialization because find_zone_movable_pfns_for_nodes covers only the
>hotplugable range as described by the BIOS/FW. From my experience this
>is usually a full node though (except for Node0 which is special and
>never goes away completely). If this turns out to be a problem in the
>real life we can tweak the code to store hotplug flag into memblocks
>but let's keep this simple now.
>

Let me try to understand your purpose of this change.

If a memblock has MEMBLOCK_HOTPLU set, it would be in ZONE_MOVABLE during
bootup. While a hotplugged memory_block would be in ZONE_NORMAL without
special care.

So you want to make sure when movable_node is enabled, the hotplugged
memory_block would be in ZONE_MOVABLE. Is this correct?

One more thing is do we have MEMBLOCK_HOTPLU for a hotplugged memory_block?

>Signed-off-by: Michal Hocko <mhocko@suse.com>
>---
>

--=20
Wei Yang
Help you, Help me

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZPhhwAAoJEKcLNpZP5cTd6gcQAJWNUicqVhEHH4o+F6ZC5Ly7
SpW0zoYfqbGlLBzMOFP0E8KXSkUZ77QfidzrsiFSD9sCYtKf0JEnxwODbHrdg1m4
RM3EddbHXxGYkQpbIEAAdCWTcSJRSFRZUWE/glSHdtMHc8dqK3eHltYNGPRoPrFX
eAk/6A4Zi2kQkzGMkemw3AEac1fWOfvDRbxGejO1nSRkiPLQdsbvyc6QVqtRuAoX
gSOxUQ4zy6flNQMOgeoZi0ylUjwBcktbSkP39NgzhMUpTABdBzv3jf8TBgEwCbQa
mh/RmrouUKKDPIy9w4eLTMlco4sT4aTDbZYRtdlSZ35YkN9eakWqBIXxVNfgNwxG
4uedGuUztHrk/12SZm7ihU92+R11kyIWGcovNlpASjSexbbTipWRWQA1vdCUXg8s
LGet5y4xHU9fibFyQTB2IOo8xdxTvdjYYzi3Yz0h0+DEiRJP8h4lhpFqiS0veKLE
ALDiF7NAP/7kqYW8k41DCG/qvwHRZzCKidrhwqffx4FEmLkSmqfT5lyfnabIB66s
fTSOUivrP49kVocvDLqNXTLdGsFz1UbgbaoPg18Q5iSggK4R3TacbzmllKJRK2ul
mAvvGZQLpo6s1wkhrXVVedccBvXTgpblZMUSwxs4EC4xnh7b63pm9HRAdY1+gzUb
zkQVWhQH+CYQUVHvtRK2
=Dq6P
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
