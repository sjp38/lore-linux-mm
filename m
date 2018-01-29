Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 674666B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 18:39:09 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id s22so8376557pfh.21
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 15:39:09 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0114.outbound.protection.outlook.com. [104.47.40.114])
        by mx.google.com with ESMTPS id 15si7203794pfa.303.2018.01.29.15.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 15:39:08 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
Date: Mon, 29 Jan 2018 18:39:01 -0500
Message-ID: <07425013-A7A9-4BB8-8FAA-9581D966A29B@cs.rutgers.edu>
In-Reply-To: <20180129143522.68a5332ae80d28461441a6be@linux-foundation.org>
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-2-mhocko@kernel.org>
 <8ECFD324-D8A0-47DC-A6FD-B9F7D29445DC@cs.rutgers.edu>
 <20180129143522.68a5332ae80d28461441a6be@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_82629931-A273-4C60-BCE9-285C5743D4F6_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_82629931-A273-4C60-BCE9-285C5743D4F6_=
Content-Type: text/plain; markup=markdown

On 29 Jan 2018, at 17:35, Andrew Morton wrote:

> On Mon, 29 Jan 2018 17:06:14 -0500 "Zi Yan" <zi.yan@cs.rutgers.edu> wrote:
>
>> I discover that this patch does not hold mmap_sem while migrating pages in
>> do_move_pages_to_node().
>>
>> A simple fix below moves mmap_sem from add_page_for_migration()
>> to the outmost do_pages_move():
>
> I'm not surprised.  Why does do_move_pages_to_node() need mmap_sem
> and how is a reader to discover that fact???

do_move_pages_to_node() calls migrate_pages(), which requires down_read(&mmap_sem).

In the outmost do_pages_move(), both add_page_for_migration() and
do_move_pages_to_node() inside it need to hold read lock of mmap_sem.

Do we need to add comments for both functions?

--
Best Regards
Yan Zi

--=_MailMate_82629931-A273-4C60-BCE9-285C5743D4F6_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJab7CWAAoJEEGLLxGcTqbMSAgH/2/8yCgR0MfGqZ4rDG4zFlZo
RTL+u7K/cqT3ATheAn2OUrFXIN1PvYnQMtWTZlxD3/UwwiVAVNBjOPgvNfsH8pBU
wYpUhLZelY+7eDh76w1gjbXX3mLj8aw/G6iElT9Bn+E2rpdNAGEWIVpRvlCfJhuC
namOqKF0O6XmmnInbkjtDpjts2i7I4MRmGF68uHMDUVC22V/rAkG58frdd8ebpi+
2tjh46d8VftAkNSldAppmhh1CuQzrrrCqmy7cKWh93mmsMCN6ulVjduONZUr9Wu+
8yWLrK/2imgApk30vcR6avcG63uqUylvzzBNg8z+5za0WLu+oFrxhicpf3jaHL0=
=PsUi
-----END PGP SIGNATURE-----

--=_MailMate_82629931-A273-4C60-BCE9-285C5743D4F6_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
