Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E88CD6B0271
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:29:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q7so1586949pgr.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:29:46 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0119.outbound.protection.outlook.com. [104.47.32.119])
        by mx.google.com with ESMTPS id t12si13183166pgc.603.2017.11.22.04.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 04:29:45 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Date: Wed, 22 Nov 2017 07:29:38 -0500
Message-ID: <59AE7B0B-9E1A-434D-89FF-E4A1ECEFF9A4@cs.rutgers.edu>
In-Reply-To: <896594C0-D9CE-4E95-BCAF-45BAD3E3DA2C@cs.rutgers.edu>
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
 <26CA724E-070E-4D06-B75E-F1880B1F2CF9@cs.rutgers.edu>
 <20171122093510.baxsmzvvid7c7yrq@dhcp22.suse.cz>
 <20171122101422.ny5tyyyje5dhx343@dhcp22.suse.cz>
 <896594C0-D9CE-4E95-BCAF-45BAD3E3DA2C@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_6BAF7575-C03D-45D8-B836-3BC5A8EB324A_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Reale <ar@linux.vnet.ibm.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_6BAF7575-C03D-45D8-B836-3BC5A8EB324A_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 22 Nov 2017, at 7:13, Zi Yan wrote:

> On 22 Nov 2017, at 5:14, Michal Hocko wrote:
>
>> On Wed 22-11-17 10:35:10, Michal Hocko wrote:
>> [...]
>>> Moreover I am not really sure this is really working properly. Just l=
ook
>>> at the split_huge_page. It moves all the tail pages to the LRU list
>>> while migrate_pages has a list of pages to migrate. So we will migrat=
e
>>> the head page and all the rest will get back to the LRU list. What
>>> guarantees that they will get migrated as well.
>>
>> OK, so this is as I've expected. It doesn't work! Some pfn walker base=
d
>> migration will just skip tail pages see madvise_inject_error.
>> __alloc_contig_migrate_range will simply fail on THP page see
>> isolate_migratepages_block so we even do not try to migrate it.
>> do_move_page_to_node_array will simply migrate head and do not care
>> about tail pages. do_mbind splits the page and then fall back to pte
>> walk when thp migration is not supported but it doesn't handle tail
>> pages if the THP migration path is not able to allocate a fresh THP
>> AFAICS. Memory hotplug should be safe because it doesn't skip the whol=
e
>> THP when doing pfn walk.
>>
>> Unless I am missing something here this looks like a huge mess to me.
>
> +Kirill
>
> First, I agree with you that splitting a THP and only migrating its hea=
d page
> is a mess. But what you describe is also the behavior of migrate_page()=

> _before_ THP migration support is added. I thought that was intended.
>
> Look at http://elixir.free-electrons.com/linux/v4.13.15/source/mm/migra=
te.c#L1091,
> unmap_and_move() splits THPs and only migrates the head page in v4.13 b=
efore THP
> migration is added. I think the behavior was introduced since v4.5 (I j=
ust skimmed
> v4.0 to v4.13 code and did not have time to use git blame), before that=
 THPs are
> not migrated but shown as successfully migrated (at least from v4.4=E2=80=
=99s code).

Sorry, I misread v4.4=E2=80=99s code, it also does =E2=80=98splitting a T=
HP and migrating its head page=E2=80=99.
This behavior was there for a long time, at least since v3.0.

The code in unmap_and_move() is:

if (unlikely(PageTransHuge(page)))
		if (unlikely(split_huge_page(page)))
			goto out;

Hope I did not miss anything else.


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_6BAF7575-C03D-45D8-B836-3BC5A8EB324A_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAloVbbIWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzJt+B/9C/D+Y+AcJ1Spx9Skou0BfMo34
E+yJGYSHfnJKF4XdyxZYtAi8ZqmOEJF0SV+pd4991BMAOlZGjFuXcEsujfF0jpIc
7yDKyg5Nr2eZ/iVbIK1H8YisibhBI0fREjh7QlhWaL4hMqaHicRlkYGPioENh45f
l9ocpLi/77XcISI8Es9Q3UcrKJxla1/gxmvqEgzujqroXJJG4muNHh9AExLyobTJ
EyvIkr8WpwzAsr2Sryw2rN5G39vN5+EfdcdZkp/KAguldivxV8MXhO2wousDT2wz
J8LhJwBJWmeQ2Eiaogckfb6Q0Xr6g8PfM8QNYdyWJ6a7Vctg+j4+TYqdIx1f
=IkTE
-----END PGP SIGNATURE-----

--=_MailMate_6BAF7575-C03D-45D8-B836-3BC5A8EB324A_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
