Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACE36B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 12:45:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s82so33187320pfk.3
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 09:45:10 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0138.outbound.protection.outlook.com. [104.47.38.138])
        by mx.google.com with ESMTPS id j63si14080294pfg.107.2017.04.10.09.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 09:45:08 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
Date: Mon, 10 Apr 2017 11:45:08 -0500
Message-ID: <84B5E286-4E2A-4DE0-8351-806D2102C399@cs.rutgers.edu>
In-Reply-To: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_7FD4DB26-5006-461D-8017-F272CC7B83F5_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_7FD4DB26-5006-461D-8017-F272CC7B83F5_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 10 Apr 2017, at 4:48, Mel Gorman wrote:

> A user reported a bug against a distribution kernel while running
> a proprietary workload described as "memory intensive that is not
> swapping" that is expected to apply to mainline kernels. The workload
> is read/write/modifying ranges of memory and checking the contents. The=
y
> reported that within a few hours that a bad PMD would be reported follo=
wed
> by a memory corruption where expected data was all zeros.  A partial re=
port
> of the bad PMD looked like
>
> [ 5195.338482] ../mm/pgtable-generic.c:33: bad pmd ffff8888157ba008(000=
002e0396009e2)
> [ 5195.341184] ------------[ cut here ]------------
> [ 5195.356880] kernel BUG at ../mm/pgtable-generic.c:35!
> ....
> [ 5195.410033] Call Trace:
> [ 5195.410471]  [<ffffffff811bc75d>] change_protection_range+0x7dd/0x93=
0
> [ 5195.410716]  [<ffffffff811d4be8>] change_prot_numa+0x18/0x30
> [ 5195.410918]  [<ffffffff810adefe>] task_numa_work+0x1fe/0x310
> [ 5195.411200]  [<ffffffff81098322>] task_work_run+0x72/0x90
> [ 5195.411246]  [<ffffffff81077139>] exit_to_usermode_loop+0x91/0xc2
> [ 5195.411494]  [<ffffffff81003a51>] prepare_exit_to_usermode+0x31/0x40=

> [ 5195.411739]  [<ffffffff815e56af>] retint_user+0x8/0x10
>
> Decoding revealed that the PMD was a valid prot_numa PMD and the bad PM=
D
> was a false detection. The bug does not trigger if automatic NUMA balan=
cing
> or transparent huge pages is disabled.
>
> The bug is due a race in change_pmd_range between a pmd_trans_huge and
> pmd_nond_or_clear_bad check without any locks held. During the pmd_tran=
s_huge
> check, a parallel protection update under lock can have cleared the PMD=

> and filled it with a prot_numa entry between the transhuge check and th=
e
> pmd_none_or_clear_bad check.
>
> While this could be fixed with heavy locking, it's only necessary to
> make a copy of the PMD on the stack during change_pmd_range and avoid
> races. A new helper is created for this as the check if quite subtle an=
d the
> existing similar helpful is not suitable. This passed 154 hours of test=
ing
> (usually triggers between 20 minutes and 24 hours) without detecting ba=
d
> PMDs or corruption. A basic test of an autonuma-intensive workload show=
ed
> no significant change in behaviour.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Cc: stable@vger.kernel.org

Does this patch fix the same problem fixed by Kirill's patch here?
https://lkml.org/lkml/2017/3/2/347

--
Best Regards
Yan Zi

--=_MailMate_7FD4DB26-5006-461D-8017-F272CC7B83F5_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJY67aUAAoJEEGLLxGcTqbMFWoH/0hqzDkuUbG27mhz9YoSKBzN
ReV7Mmjuqwwmfyp9iHM5XYlsSZAIWc0VlKm3q7OL6sPjXXq4rTXDkLoksELd8z9q
Fyxoouwa1Y7IpkZjwHWgKwR8QPFdEBR/fekak8bkM52oI4yHa4/xupItt9etQBM4
TPbSnW4aa8fFy6NihjTybC5+1sXpDxH1jCcv8L5gcSStIWI07HHw9Tl5oVKeoXGx
rhd15cPwMYlknSFJ4tZIj4Dv+z9/PexGUs+P7qSLVO7Fngf/w5FstTxgSiO04FcI
HpwojB7rE/1wM+Fnn5GxjfXl7JOV4w8pnHq+4mRk9edC0dkWfGfa8VDECZcNXls=
=Xgr1
-----END PGP SIGNATURE-----

--=_MailMate_7FD4DB26-5006-461D-8017-F272CC7B83F5_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
