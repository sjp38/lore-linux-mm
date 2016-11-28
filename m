Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 462E66B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:22:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so214408351pfk.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:22:53 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0122.outbound.protection.outlook.com. [104.47.34.122])
        by mx.google.com with ESMTPS id z19si8772706pgj.173.2016.11.28.07.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 07:22:52 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 0/5] Parallel hugepage migration optimization
Date: Mon, 28 Nov 2016 10:22:45 -0500
Message-ID: <B5954713-0912-40E6-898E-BF4A05B7E5CB@cs.rutgers.edu>
In-Reply-To: <9cf7f4c6-6dde-9dbb-cf93-7874437a442d@gmail.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
 <9cf7f4c6-6dde-9dbb-cf93-7874437a442d@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_637746C7-C397-4CC8-B358-3C32989FF3D2_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com

--=_MailMate_637746C7-C397-4CC8-B358-3C32989FF3D2_=
Content-Type: text/plain

On 24 Nov 2016, at 18:59, Balbir Singh wrote:

> On 23/11/16 03:25, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> Hi all,
>>
>> This patchset boosts the hugepage migration throughput and helps THP migration
>> which is added by Naoya's patches: https://lwn.net/Articles/705879/.
>>
>> Motivation
>> ===============================
>>
>> In x86, 4KB page migrations are underutilizing the memory bandwidth compared
>> to 2MB THP migrations. I did some page migration benchmarking on a two-socket
>> Intel Xeon E5-2640v3 box, which has 23.4GB/s bandwidth, and discover
>> there are big throughput gap, ~3x, between 4KB and 2MB page migrations.
>>
>> Here are the throughput numbers for different page sizes and page numbers:
>>         | 512 4KB pages | 1 2MB THP  |  1 4KB page
>> x86_64  |  0.98GB/s     |  2.97GB/s  |   0.06GB/s
>>
>> As Linux currently use single-threaded page migration, the throughput is still
>> much lower than the hardware bandwidth, 2.97GB/s vs 23.4GB/s. So I parallelize
>> the copy_page() part of THP migration with workqueue and achieve 2.8x throughput.
>>
>> Here are the throughput numbers of 2MB page migration:
>>            |  single-threaded   | 8-thread
>> x86_64 2MB |    2.97GB/s        | 8.58GB/s
>>
>
> Whats the impact on CPU utilization? Is there a huge impact?
>
> Balbir Singh.

It depends on the throughput we can achieve.

For single-threaded copy, the current routine, it takes one CPU 2MB/(2.97GB/s) = 657.6 us
to copy one 2MB page.

For 8-thread copy, it take 8 CPUs 2MB/(8.58GB/s) = 227.6 us to copy one 2MB page.

If we have 8 idle CPUs, I think it worths using them.

I am going to add code to check idle_cpu() in the system before doing the copy.
If no idle CPUs are present, I can fall back to single-threaded copy.


--
Best Regards
Yan Zi

--=_MailMate_637746C7-C397-4CC8-B358-3C32989FF3D2_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYPEvFAAoJEEGLLxGcTqbMEb8H/2rCChgp11A8SwJhTkt0BFPO
mgusZsNgrSK7Wi2q+j2ZOkoLidSD+1Mh5N8wFrqVs9LCFiKvfQXIlllrVpze9yIU
nTd0c3BQjS7eD2fNSx1oCFSIMaUIgtr0qPq0SaVLVq5ho9k/OxSoTk7F0f6iAhKc
wdb8naUMqUcTFhs0YslzbSRGZNLZQ7cz4QVkR67T6g9uKxYC1NXafyQciP1cpPjc
cBuqhj7j5Ps3mHpthmmyCixn7r298ROZ00HsKrE1bEFHsRNF0VGMtzvl3rE49T61
BN7FMPnZ7YVsCOq6j5L6vUe6UqH4k+TFHm6udIUa4eQNjYaf7S8YVqWrA96gfYM=
=wM2C
-----END PGP SIGNATURE-----

--=_MailMate_637746C7-C397-4CC8-B358-3C32989FF3D2_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
