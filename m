Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D458A6B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 11:01:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e199so2529414pfh.7
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 08:01:39 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0103.outbound.protection.outlook.com. [104.47.42.103])
        by mx.google.com with ESMTPS id n62si179709pfb.86.2017.07.19.08.01.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 08:01:38 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v9 06/10] mm: thp: check pmd migration entry in common
 path
Date: Wed, 19 Jul 2017 11:01:33 -0400
Message-ID: <DBF3E4FD-6CC8-41E3-8C20-466645BAFF7C@cs.rutgers.edu>
In-Reply-To: <20170719080212.GB26779@dhcp22.suse.cz>
References: <20170717193955.20207-1-zi.yan@sent.com>
 <20170717193955.20207-7-zi.yan@sent.com>
 <20170719080212.GB26779@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_B7607DC4-C4BD-4CC7-9C63-FB670B57C6D1_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_B7607DC4-C4BD-4CC7-9C63-FB670B57C6D1_=
Content-Type: text/plain

On 19 Jul 2017, at 4:02, Michal Hocko wrote:

> On Mon 17-07-17 15:39:51, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> If one of callers of page migration starts to handle thp,
>> memory management code start to see pmd migration entry, so we need
>> to prepare for it before enabling. This patch changes various code
>> point which checks the status of given pmds in order to prevent race
>> between thp migration and the pmd-related works.
>
> I am sorry to nitpick on the changelog but the patch is scary large and
> it would deserve much better description. What are those "various code
> point" and how do you "prevent race". How can we double check that none
> of them were missed?

Thanks for pointing this out.

Let me know if the following new description looks good to you:


When THP migration is being used, memory management code needs to handle
pmd migration entries properly. This patch uses !pmd_present() or is_swap_pmd()
(depending on whether pmd_none() needs separate code or not) to
check pmd migration entries at the places where a pmd entry is present.

Since pmd-related code uses split_huge_page(), split_huge_pmd(), pmd_trans_huge(),
pmd_trans_unstable(), or pmd_none_or_trans_huge_or_clear_bad(),
this patch:
1. adds pmd migration entry split code in split_huge_pmd(),
2. takes care of pmd migration entries whenever pmd_trans_huge() is present,
3. makes pmd_none_or_trans_huge_or_clear_bad() pmd migration entry aware.
Since split_huge_page() uses split_huge_pmd() and pmd_trans_unstable() is equivalent
to pmd_none_or_trans_huge_or_clear_bad(), we do not change them.

Until this commit, a pmd entry should be:
1. pointing to a pte page,
2. is_swap_pmd(),
3. pmd_trans_huge(),
4. pmd_devmap(), or
5. pmd_none().

--
Best Regards
Yan Zi

--=_MailMate_B7607DC4-C4BD-4CC7-9C63-FB670B57C6D1_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZb3ROAAoJEEGLLxGcTqbMnM0IAIJk5fInIsfn5Ix/cfwDR1kS
qt6scndZCaMoR+rEIRk8fcX4pwyXnWIW4LH1xl9w/+p6iYfWaCxellSeE5OHgiRL
HGe3IJXfpTWOQfd8lT+qJbWWvNAOv7O12yBiF6IBu+kI3gI/syPAPjdHVmFTXM0a
ds3IMwuc4d347SqKCbEbEndOSExa87IE6pcMKMtqvUxike3p1PJHdl0kIcki+iEV
w2MhyAtvXJviZ+FKYsqGGvh8GgbND+HgC0d9+52QZ5hdoTUXyupQ9pPFk03eM6mw
1iT8JdLI670sSGUQ6Fj45Jl9ljDxzrM8UUJMZrEj5MCLzZ07fxWikbS3NFsBkGE=
=mylc
-----END PGP SIGNATURE-----

--=_MailMate_B7607DC4-C4BD-4CC7-9C63-FB670B57C6D1_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
