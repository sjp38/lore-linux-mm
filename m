Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 94FB66B0254
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:56:47 -0400 (EDT)
Received: by qgii95 with SMTP id i95so2807094qgi.2
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 04:56:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t34si30992010qgt.97.2015.07.29.04.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 04:56:46 -0700 (PDT)
Message-ID: <55B8BF73.4060207@redhat.com>
Date: Wed, 29 Jul 2015 13:56:35 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: show proportional swap share of the mapping
References: <1434373614-1041-1-git-send-email-minchan@kernel.org> <55B88FF1.7050502@redhat.com> <20150729102849.GA19352@bgram>
In-Reply-To: <20150729102849.GA19352@bgram>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="euLVffF4KRGBvB1ub0ttdFGmAbOKn6Rdt"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Bongkyu Kim <bongkyu.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Jonathan Corbet <corbet@lwn.net>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--euLVffF4KRGBvB1ub0ttdFGmAbOKn6Rdt
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/29/2015 12:30 PM, Minchan Kim wrote:
> Hi Jerome,
>=20
> On Wed, Jul 29, 2015 at 10:33:53AM +0200, Jerome Marchand wrote:
>> On 06/15/2015 03:06 PM, Minchan Kim wrote:
>>> We want to know per-process workingset size for smart memory manageme=
nt
>>> on userland and we use swap(ex, zram) heavily to maximize memory effi=
ciency
>>> so workingset includes swap as well as RSS.
>>>
>>> On such system, if there are lots of shared anonymous pages, it's
>>> really hard to figure out exactly how many each process consumes
>>> memory(ie, rss + wap) if the system has lots of shared anonymous
>>> memory(e.g, android).
>>>
>>> This patch introduces SwapPss field on /proc/<pid>/smaps so we can ge=
t
>>> more exact workingset size per process.
>>>
>>> Bongkyu tested it. Result is below.
>>>
>>> 1. 50M used swap
>>> SwapTotal: 461976 kB
>>> SwapFree: 411192 kB
>>>
>>> $ adb shell cat /proc/*/smaps | grep "SwapPss:" | awk '{sum +=3D $2} =
END {print sum}';
>>> 48236
>>> $ adb shell cat /proc/*/smaps | grep "Swap:" | awk '{sum +=3D $2} END=
 {print sum}';
>>> 141184
>>
>> Hi Minchan,
>>
>> I just found out about this patch. What kind of shared memory is that?=

>> Since it's android, I'm inclined to think something specific like
>> ashmem. I'm asking because this patch won't help for more common type =
of
>> shared memory. See my comment below.
>=20
> It's normal heap of parent(IOW, MAP_ANON|MAP_PRIVATE memory which is sh=
are
>  by child processes).

Ok. I didn't imagine CoW pages would represent such a big share of
swapped out pages.

>=20
>>
>>>
>>> 2. 240M used swap
>>> SwapTotal: 461976 kB
>>> SwapFree: 216808 kB
>>>
>>> $ adb shell cat /proc/*/smaps | grep "SwapPss:" | awk '{sum +=3D $2} =
END {print sum}';
>>> 230315
>>> $ adb shell cat /proc/*/smaps | grep "Swap:" | awk '{sum +=3D $2} END=
 {print sum}';
>>> 1387744
>>>
>> snip
>>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>>> index 6dee68d013ff..d537899f4b25 100644
>>> --- a/fs/proc/task_mmu.c
>>> +++ b/fs/proc/task_mmu.c
>>> @@ -446,6 +446,7 @@ struct mem_size_stats {
>>>  	unsigned long anonymous_thp;
>>>  	unsigned long swap;
>>>  	u64 pss;
>>> +	u64 swap_pss;
>>>  };
>>> =20
>>>  static void smaps_account(struct mem_size_stats *mss, struct page *p=
age,
>>> @@ -492,9 +493,20 @@ static void smaps_pte_entry(pte_t *pte, unsigned=
 long addr,
>>>  	} else if (is_swap_pte(*pte)) {
>>
>> This won't work for sysV shm, tmpfs and MAP_SHARED | MAP_ANONYMOUS
>> mapping pages which are pte_none when paged out. They're currently not=

>> accounted at all when in swap.
>=20
> This patch doesn't handle those pages because we don't have supported
> thoses pages. IMHO, if someone need it, it should be another patch and
> he can contribute it in future.

Sure.

>=20
> Thanks.
>=20



--euLVffF4KRGBvB1ub0ttdFGmAbOKn6Rdt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVuL95AAoJEHTzHJCtsuoChD0H/jNa3nZvVNcHbF/r3MgOYYP2
5vlLkC4SFksy4jbZ778nKgIgdv51OLSZLCPuPBWzROP4QIbYC0zVWVuTiY7FD5Ph
+fLyf2QhdkZWk6GBfItNkeacxXrUCeleVk32TdB++dqGHKwIFCqjQnrJV8+oonzF
fLMNe8iq28nbrNTRX70RQLvhWMgq3gW27LaafSmln+E6ElnKR0/AoaWh6MeoyJvR
ImoyHMXGSq+MHwKBLmiPASKu2topPsZh1BlinmLqVJs65mnmCXM8ASLqbSUeeAHe
SgCp9HiArVpF8OrmnBYFK2SZKC5PX92l2XlzJ4qmODYRM+74UNRZBOT3NTPcYzc=
=+F1/
-----END PGP SIGNATURE-----

--euLVffF4KRGBvB1ub0ttdFGmAbOKn6Rdt--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
