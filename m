Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2AA6B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 07:23:01 -0400 (EDT)
Received: by qgbb65 with SMTP id b65so115806123qgb.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 04:23:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 198si21607488qhh.41.2015.10.26.04.23.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 04:23:00 -0700 (PDT)
Subject: Re: [PATCH v4 2/4] mm, proc: account for shmem swap in
 /proc/pid/smaps
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
 <1443792951-13944-3-git-send-email-vbabka@suse.cz>
 <alpine.LSU.2.11.1510041806040.15067@eggly.anvils> <5627A397.6090305@suse.cz>
From: Jerome Marchand <jmarchan@redhat.com>
Message-ID: <562E0D08.4020607@redhat.com>
Date: Mon, 26 Oct 2015 12:22:48 +0100
MIME-Version: 1.0
In-Reply-To: <5627A397.6090305@suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="MPHfUuw6Ai8p3dwKDWqpU6HH7AHH6qmEJ"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MPHfUuw6Ai8p3dwKDWqpU6HH7AHH6qmEJ
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/21/2015 04:39 PM, Vlastimil Babka wrote:
> On 10/05/2015 05:01 AM, Hugh Dickins wrote:
>> On Fri, 2 Oct 2015, Vlastimil Babka wrote:

>> As you acknowledge in the commit message, if a file of 100 pages
>> were copied to tmpfs, and 100 tasks map its full extent, but they
>> all mess around with the first 50 pages and take no interest in
>> the last 50, then it's quite likely that that last 50 will get
>> swapped out; then with your patch, 100 tasks are each shown as
>> using 50 pages of swap, when none of them are actually using any.
>=20
> Yeah, but isn't it the same with private memory which was swapped out a=
t
> some point and we don't know if it will be touched or not? The
> difference is in private case we know the process touched it at least
> once, but that can also mean nothing for the future (or maybe it just
> mmapped with MAP_POPULATE and didn't care about half of it).
>=20
> That's basically what I was trying to say in the changelog. I interpret=

> the Swap: value as the amount of swap-in potential, if the process was
> going to access it, which is what the particular customer also expects
> (see below). In that case showing zero is IMHO wrong and inconsistent
> with the anonymous private mappings.

I didn't understand the changelog that way an IMHO it's a pretty
specific interpretation. I've always understood memory accounting as
being primarily the answer to the question: how much resources a
process uses? I guess its meaning as been overloaded with corollaries
that are only true in the most simple non-shared cases, such as yours
or "how much memory would be freed if this process goes away?", but I
don't think it should ever be used as a definition.

I suppose the reason I didn't understand the changelog the way you
intended is because I think that sometimes it's correct to blame a
process for pages it never accessed (and I also believe that
over-accounting is better that under accounting,  but I must admit
that it is a quite arbitrary point of view). For instance, what if a
process has a shared anonymous mapping that includes pages that it
never accessed, but have been populated by an other process that has
already exited or munmaped the range? That process is not to blame for
the appearance of these pages, but it's the only reason why they
stay.

I'll offer a lollipop to anyone who comes up with a simple consistent
model on how to account shmem pages for all the possible cases, a
"Grand Unified Theory of Memory Accounting" so to speak.

> Other non-perfect solutions that come to mind:
>=20
> 1) For private mappings, count only the swapents. "Swap:" is no longer
> showing full swap-in potential though.
> 2) For private mappings, do not count swapents. Ditto.
> 3) Provide two separate counters. The user won't know how much they
> overlap, though.
>=20
> From these I would be inclined towards 3) as being more universal,
> although then it's no longer a simple "we're fixing a Swap: 0 value
> which is wrong", but closer to original Jerome's versions, which IIRC
> introduced several shmem-specific counters.

You remember correctly. Given all the controversy around shmem
accounting, maybe it would indeed be better to leave existing
counters, that are relatively well defined and understood, untouched
and add specific counters to mess around instead.

Thanks,
Jerome


--MPHfUuw6Ai8p3dwKDWqpU6HH7AHH6qmEJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWLg0IAAoJEHTzHJCtsuoC3t4IALLwNYFPiAiS0OO5U8ea70QA
qbosmcLZ1JjIoPxXCsJ0IZ+4wPUXRW7c0tYVsJ09JUcS6ohUJOyOv2SYVT6rge5h
/0TXeQaakyvP3CQhrAwKX7a5afnuL/xpGCzNBAp9RaSXbihecY81djMJKnIarvca
H46bxBnLl2VBWNmUc9/SXaekkY//fgyGY1yvZszk0bqMUjEm1KD0gfA9dTMU0yZR
vL39NW1u6gYvrH7z825wW+lCcx4a5FROg3zd+Scv2yO6JF9ls4GFsPl112CL2ud0
6vDSq6i1O8OXWUSakHqjzzmVMtF427neNe3tRrW0TBu2lts3oTT3VV0h7IsU7Hc=
=ZDhz
-----END PGP SIGNATURE-----

--MPHfUuw6Ai8p3dwKDWqpU6HH7AHH6qmEJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
