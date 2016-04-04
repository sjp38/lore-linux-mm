Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A21836B0273
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 09:17:27 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id zm5so144528521pac.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:17:27 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id xe1si453255pab.53.2016.04.04.06.17.26
        for <linux-mm@kvack.org>;
        Mon, 04 Apr 2016 06:17:26 -0700 (PDT)
Date: Mon, 4 Apr 2016 15:17:18 +0200
From: John Einar Reitan <john.reitan@foss.arm.com>
Subject: Re: [PATCH v3 00/16] Support non-lru page migration
Message-ID: <20160404131718.GA18963@e106921-lin.trondheim.arm.com>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="sm4nu43k4a2Rpi4c"
Content-Disposition: inline
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 30, 2016 at 04:11:59PM +0900, Minchan Kim wrote:
> Recently, I got many reports about perfermance degradation
> in embedded system(Android mobile phone, webOS TV and so on)
> and failed to fork easily.
>=20
> The problem was fragmentation caused by zram and GPU driver
> pages. Their pages cannot be migrated so compaction cannot
> work well, either so reclaimer ends up shrinking all of working
> set pages. It made system very slow and even to fail to fork
> easily.
>=20
> Other pain point is that they cannot work with CMA.
> Most of CMA memory space could be idle(ie, it could be used
> for movable pages unless driver is using) but if driver(i.e.,
> zram) cannot migrate his page, that memory space could be
> wasted. In our product which has big CMA memory, it reclaims
> zones too exccessively although there are lots of free space
> in CMA so system was very slow easily.
>=20
> To solve these problem, this patch try to add facility to
> migrate non-lru pages via introducing new friend functions
> of migratepage in address_space_operation and new page flags.
>=20
> 	(isolate_page, putback_page)
> 	(PG_movable, PG_isolated)
>=20
> For details, please read description in
> "mm/compaction: support non-lru movable page migration".

Thanks, this mirrors what we see with the ARM Mali GPU drivers too.

One thing with the current design which worries me is the potential
for multiple calls due to many separated pages being migrated.
On GPUs (or any other device) which has an IOMMU and L2 cache, which
isn't coherent with the CPU, we must do L2 cache flush & invalidation
per page. I guess batching pages isn't easily possible?


--sm4nu43k4a2Rpi4c
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQGcBAABCAAGBQJXAmlZAAoJEPmPNPdCQ4pIlBwL/1pxZRdGGS+YVXOWnKmLrVhR
LwzyVmu02A7lMgHXoAMGHuWaH06mGRLfwgjU56fi2JnLeNkHR/wpR95gGckvS8zd
xQmogKXU4ZE8xbqqft6qwxv3IE+mGkwCPMGrLVjvgfKR0/iJ7ojQYN9fhoV1Z3br
Pn0/lhMdOqo1jnHHmMDp9PD6s32l3SdnISfjHXF72fSA5u4Uv/kITReSyRgaWQSB
efJjZjM7QPPHomeUcy1u/ZdbJYI5FRnZpaNJMGuCX8d7hnlIu1WS7zdlJzhMs3qi
mzU5/49J/eoycEadTFJD9VsvKKO0W5GpPP03A2PEHcsiGv3mEqjsnomNNCBLfebO
2bT8pMYR3VV7/+W/DjEOvMvlWCrq01uxuJIcjJVpoC3Wh6aMJW8fX1Po8RZQIfRb
+en68y8EocFXu1oevCEP2jBUmBpd/uXzLUStbHDbijDH3G53PBBsv8msFpm9HIfM
Ice5LUXN2cBJcmwD0KwZwn9a2SUoy/NQesE50nBfSA==
=0/aR
-----END PGP SIGNATURE-----

--sm4nu43k4a2Rpi4c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
