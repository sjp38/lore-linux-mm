Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E194C6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 13:49:41 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id p8so46283603qkh.2
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:49:41 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0099.outbound.protection.outlook.com. [104.47.33.99])
        by mx.google.com with ESMTPS id u28si14039319qkl.160.2017.04.10.10.49.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 10:49:40 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
Date: Mon, 10 Apr 2017 12:49:40 -0500
Message-ID: <8A6309F4-DB76-48FA-BE7F-BF9536A4C4E5@cs.rutgers.edu>
In-Reply-To: <20170410172056.shyx6qzcjglbt5nd@techsingularity.net>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
 <84B5E286-4E2A-4DE0-8351-806D2102C399@cs.rutgers.edu>
 <20170410172056.shyx6qzcjglbt5nd@techsingularity.net>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_61A54B4F-F01F-4F01-86DD-0BE5C19ECEB4_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_61A54B4F-F01F-4F01-86DD-0BE5C19ECEB4_=
Content-Type: text/plain; markup=markdown

On 10 Apr 2017, at 12:20, Mel Gorman wrote:

> On Mon, Apr 10, 2017 at 11:45:08AM -0500, Zi Yan wrote:
>>> While this could be fixed with heavy locking, it's only necessary to
>>> make a copy of the PMD on the stack during change_pmd_range and avoid
>>> races. A new helper is created for this as the check if quite subtle and the
>>> existing similar helpful is not suitable. This passed 154 hours of testing
>>> (usually triggers between 20 minutes and 24 hours) without detecting bad
>>> PMDs or corruption. A basic test of an autonuma-intensive workload showed
>>> no significant change in behaviour.
>>>
>>> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
>>> Cc: stable@vger.kernel.org
>>
>> Does this patch fix the same problem fixed by Kirill's patch here?
>> https://lkml.org/lkml/2017/3/2/347
>>
>
> I don't think so. The race I'm concerned with is due to locks not being
> held and is in a different path.

I do not agree. Kirill's patch is fixing the same race problem but in
zap_pmd_range().

The original autoNUMA code first clears PMD then sets it to protnone entry.
pmd_trans_huge() does not return TRUE because it saw cleared PMD, but
pmd_none_or_clear_bad() later saw the protnone entry and reported it as bad.
Is this the problem you are trying solve?

Kirill's patch will pmdp_invalidate() the PMD entry, which keeps _PAGE_PSE bit,
so pmd_trans_huge() will return TRUE. In this case, it also fixes
your race problem in change_pmd_range().

Let me know if I miss anything.

Thanks.

--
Best Regards
Yan Zi

--=_MailMate_61A54B4F-F01F-4F01-86DD-0BE5C19ECEB4_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJY68W1AAoJEEGLLxGcTqbMIdgH/RRsyhNNbUinSW/L32d21YI/
Reat577JS8Dmk7deMlVvqrsyMb+dnJ6+E1GSsPVF6LJxH0yh660vH5ZSYiLvO484
zHptpTpvPeGvjgHy0HOtFd6dmi/az4z3kScfPeqsOfIqjiwTXshKoz91LEdNBHw6
+i9yYHXbpyLeYaDIohv7XheF82jLQLK3v58aLeWGbAEZH6siSYb+0Yz9dnuNyDTl
2oNhPvDA173O4YgFUrRJstJTRUzhl9pxXJKZ3qbrtiNYGF6kGYshHT7do6JT3XUV
jCj3//0hbe0CAQHE157YV53oKpm5FvtfcHqD7caQzVUwFFOrMJlmu4vAO7NDdz8=
=oD5L
-----END PGP SIGNATURE-----

--=_MailMate_61A54B4F-F01F-4F01-86DD-0BE5C19ECEB4_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
