Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 799FF6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 17:35:56 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id s5so25549564qkd.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:35:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h75si10136062qhc.86.2016.02.25.14.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 14:35:55 -0800 (PST)
Message-ID: <1456439750.15821.97.camel@redhat.com>
Subject: Re: [RFC v5 0/3] mm: make swapin readahead to gain more thp
 performance
From: Rik van Riel <riel@redhat.com>
Date: Thu, 25 Feb 2016 17:35:50 -0500
In-Reply-To: <alpine.LSU.2.11.1602242301040.6947@eggly.anvils>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
	 <20150914144106.ee205c3ae3f4ec0e5202c9fe@linux-foundation.org>
	 <alpine.LSU.2.11.1602242301040.6947@eggly.anvils>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-074UBnQQ639I/tHqz/QM"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com


--=-074UBnQQ639I/tHqz/QM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-02-24 at 23:36 -0800, Hugh Dickins wrote:
>=C2=A0
> Doesn't this imply that __collapse_huge_page_swapin() will initiate
> all
> the necessary swapins for a THP, then (given the
> FAULT_FLAG_ALLOW_RETRY)
> not wait for them to complete, so khugepaged will give up on that
> extent
> and move on to another; then after another full circuit of all the
> mms
> it needs to examine, it will arrive back at this extent and build a
> THP
> from the swapins it arranged last time.
>=20
> Which may work well when a system transitions from busy+swappingout
> to idle+swappingin, but isn't that rather a special case?=C2=A0 It feels
> (meaning, I've not measured at all) as if the inbetween busyish case
> will waste a lot of I/O and memory on swapins that have to be
> discarded
> again before khugepaged has made its sedate way back to slotting them
> in.
>=C2=A0

There may be a fairly simple way to prevent
that from becoming an issue.

When khugepaged wakes up, it can check the
PGSWPOUT or even the PGSTEAL_* stats for
the system, and skip swapin readahead if
there was swapout activity (or any page
reclaim activity?) since the time it last
ran.

That way the swapin readahead will do
its thing when transitioning from
busy + swapout to idle + swapin, but not
while the system is under permanent memory
pressure.

Am I forgetting anything obvious?

Is this too aggressive?

Not aggressive enough?

Could PGPGOUT + PGSWPOUT be a useful
in-between between just PGSWPOUT or
PGSTEAL_*?

--=C2=A0
All rights reversed

--=-074UBnQQ639I/tHqz/QM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWz4HGAAoJEM553pKExN6DDK4H/3bbdh3MuvAyY/KD/HtKXDqw
9bz98E5L6kjgaSkCUaZmC3jq3U4BoBATu169W+aQTyikMgyoPXuBzkhEf3aeryEx
vYfA10y9UD02WbxW0rk6RAChFdk5OWLSGz57JHK2a+mPn36Vjiz9XaSPkBpiHP7z
CylmEliSeIElGzNdbIqIgrR5ZJKHdezIxmo9V0oq3U3z4b1+rLvBHrzdPOrLKxpQ
KsPwUn2uk8ski6LTrMoBuFdOoDbXotOABXZgrAzJuTrqA8Z/gLhhuwBerUq0N8YW
zKnBniX6SDSXCmiqSonl1kAoTmLGL73saDqnul9F8GRDSgW1k3Z99sf2ORmzgYE=
=rGAk
-----END PGP SIGNATURE-----

--=-074UBnQQ639I/tHqz/QM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
