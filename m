Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9486B026B
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:13:45 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s18so16077616pge.19
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:13:45 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0135.outbound.protection.outlook.com. [104.47.40.135])
        by mx.google.com with ESMTPS id r79si14798808pfa.337.2017.11.22.04.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 04:13:44 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Date: Wed, 22 Nov 2017 07:13:37 -0500
Message-ID: <896594C0-D9CE-4E95-BCAF-45BAD3E3DA2C@cs.rutgers.edu>
In-Reply-To: <20171122101422.ny5tyyyje5dhx343@dhcp22.suse.cz>
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
 <26CA724E-070E-4D06-B75E-F1880B1F2CF9@cs.rutgers.edu>
 <20171122093510.baxsmzvvid7c7yrq@dhcp22.suse.cz>
 <20171122101422.ny5tyyyje5dhx343@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_66197C31-204F-46A9-BE3F-00FC02203FBA_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Reale <ar@linux.vnet.ibm.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_66197C31-204F-46A9-BE3F-00FC02203FBA_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 22 Nov 2017, at 5:14, Michal Hocko wrote:

> On Wed 22-11-17 10:35:10, Michal Hocko wrote:
> [...]
>> Moreover I am not really sure this is really working properly. Just lo=
ok
>> at the split_huge_page. It moves all the tail pages to the LRU list
>> while migrate_pages has a list of pages to migrate. So we will migrate=

>> the head page and all the rest will get back to the LRU list. What
>> guarantees that they will get migrated as well.
>
> OK, so this is as I've expected. It doesn't work! Some pfn walker based=

> migration will just skip tail pages see madvise_inject_error.
> __alloc_contig_migrate_range will simply fail on THP page see
> isolate_migratepages_block so we even do not try to migrate it.
> do_move_page_to_node_array will simply migrate head and do not care
> about tail pages. do_mbind splits the page and then fall back to pte
> walk when thp migration is not supported but it doesn't handle tail
> pages if the THP migration path is not able to allocate a fresh THP
> AFAICS. Memory hotplug should be safe because it doesn't skip the whole=

> THP when doing pfn walk.
>
> Unless I am missing something here this looks like a huge mess to me.

+Kirill

First, I agree with you that splitting a THP and only migrating its head =
page
is a mess. But what you describe is also the behavior of migrate_page()
_before_ THP migration support is added. I thought that was intended.

Look at http://elixir.free-electrons.com/linux/v4.13.15/source/mm/migrate=
=2Ec#L1091,
unmap_and_move() splits THPs and only migrates the head page in v4.13 bef=
ore THP
migration is added. I think the behavior was introduced since v4.5 (I jus=
t skimmed
v4.0 to v4.13 code and did not have time to use git blame), before that T=
HPs are
not migrated but shown as successfully migrated (at least from v4.4=E2=80=
=99s code).

Naoya and I had a discussion on this =E2=80=98splitting a THP and migrati=
ng its head page=E2=80=99 before.
We think we should try to spilt the THP and migrate all its subpages. I d=
id not have
time to get the code out yet.

I am traveling today, so I may not be able to do anything useful. I will =
be on a break
for a month and will not have good accesses to any machines. I can try to=
 fix
this =E2=80=98splitting a THP and migrating its head page=E2=80=99 after =
that.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_66197C31-204F-46A9-BE3F-00FC02203FBA_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAloVafEWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzMVeB/0aNK6coLK1hGrpCAwF+q8KF9d3
QDDO+QqE3MiMYYXRx3HGyfP+jH48b5kps43zVRWSCKCsdDd4IbtSpxIoRXn8kyrm
bwdtO5ug8cnxnOS0ijb06TqufJZKoUkU2jPpglzpoMpLugn2hZAW+pL8jmCFqW9g
BoNxe6md7MyJ0tyK8KcooSm7ZCAuL3TDAdHE8MXbaSMuDPaR4zmOAnQF4VDxf071
ktEz1Mn+KcCyIwIoFLo4u1f/hoAlGtKUu7NtaGEGN1MadeXwvJTTahcg3V8KapYk
V/jcWUYfx0Rzsm25Zv4Nry569OnPFlYnocOjzax1J/0HoOAwtFjs8WmzTv89
=qqTS
-----END PGP SIGNATURE-----

--=_MailMate_66197C31-204F-46A9-BE3F-00FC02203FBA_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
