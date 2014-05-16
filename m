Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 06AA56B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 13:33:46 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so2857384pbc.24
        for <linux-mm@kvack.org>; Fri, 16 May 2014 10:33:46 -0700 (PDT)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id po3si316499pbb.3.2014.05.16.10.33.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 May 2014 10:33:45 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so2877229pbc.23
        for <linux-mm@kvack.org>; Fri, 16 May 2014 10:33:45 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2] mm, compaction: properly signal and act upon lock and need_sched() contention
In-Reply-To: <1400233673-11477-1-git-send-email-vbabka@suse.cz>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1400233673-11477-1-git-send-email-vbabka@suse.cz>
Date: Fri, 16 May 2014 10:33:35 -0700
Message-ID: <xa1tsio9fx1s.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, May 16 2014, Vlastimil Babka wrote:
> Compaction uses compact_checklock_irqsave() function to periodically chec=
k for
> lock contention and need_resched() to either abort async compaction, or to
> free the lock, schedule and retake the lock. When aborting, cc->contended=
 is
> set to signal the contended state to the caller. Two problems have been
> identified in this mechanism.
>
> First, compaction also calls directly cond_resched() in both scanners whe=
n no
> lock is yet taken. This call either does not abort async compaction, or s=
et
> cc->contended appropriately. This patch introduces a new compact_should_a=
bort()
> function to achieve both. In isolate_freepages(), the check frequency is
> reduced to once by SWAP_CLUSTER_MAX pageblocks to match what the migration
> scanner does in the preliminary page checks. In case a pageblock is found
> suitable for calling isolate_freepages_block(), the checks within there a=
re
> done on higher frequency.
>
> Second, isolate_freepages() does not check if isolate_freepages_block()
> aborted due to contention, and advances to the next pageblock. This viola=
tes
> the principle of aborting on contention, and might result in pageblocks n=
ot
> being scanned completely, since the scanning cursor is advanced. This pat=
ch
> makes isolate_freepages_block() check the cc->contended flag and abort.
>
> In case isolate_freepages() has already isolated some pages before aborti=
ng
> due to contention, page migration will proceed, which is OK since we do n=
ot
> want to waste the work that has been done, and page migration has own che=
cks
> for contention. However, we do not want another isolation attempt by eith=
er
> of the scanners, so cc->contended flag check is added also to
> compaction_alloc() and compact_finished() to make sure compaction is abor=
ted
> right after the migration.
>
> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
> v2: update struct compact_control comment (per Naoya Horiguchi)
>     rename to compact_should_abort() and add comments (per David Rientjes)
>     add cc->contended checks in compaction_alloc() and compact_finished()
>     (per Joonsoo Kim)
>     reduce frequency of checks in isolate_freepages()=20
>
--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJTdkvvAAoJECBgQBJQdR/0o3MP/Rj0r/oRm/6Otfqz2rlcqW2g
36HpqwRC0R2Mmmk7VN4IofX9GuhDUCjlQYUfKIVIapOhqm+N3buepLv2V6/Zv0KA
KJllXOp310O2VO9KwtSpOK7K82HLPzGi/QrCRFt1Wc+0C2PJB8cIjn+myDdcCvTl
eAR6GosGCpla72wLkuwxc6tmbMZ54Bzhrv2mE+hMdSnkmmV/gnSAFNzT1yhfDpJZ
4/0FZs4KkqHWy9BnpxOWwiAsa3/r4G0KjHGRAdp61iv/wTUeL0QG57v7kWsFBi1b
YrFstvmO4fXTvoGnCPf2GeWu1Y5qillXMptP3BK7Qjv058NDBeCP6rWUxii9Eu7F
meYXmet2fmBHcIKmdrZsYQ5dcDulKeAv1ATNvU6rQ6JW4Ov/oigMbylPTNlsZ2Nw
+vohZqm9sgpa628BwiTX1O3hv/0YG/QxWa36EezFFfIQLo09TwXYreLMy5bggpjX
AJXW1pxY1RRDA1CRsPTRTmduIikxUYAHhSsCCLPrT2xMPuz9D+5PaCHf80XjuicQ
JEA88a4BvNy7AMfUfgJriKFGpg+yY3gyGmftZAI5zwlrcwzWcAbkdfyykVJO9DRT
hQjasihW31OlVofl+QtmjwokcGaJzGc2TfetP7v/XeJQvTcb6/6Qh4oF2ZqoUzVY
e77JD7YNElAQRi2PFpzN
=FZ3h
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
