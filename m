Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48C2A6B0700
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 10:34:12 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 67so3513601qkj.18
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 07:34:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a24-v6sor8531800qtj.43.2018.11.09.07.34.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 07:34:11 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
Date: Fri, 09 Nov 2018 10:34:07 -0500
Message-ID: <EEBCAF4D-138C-4CF7-B4B7-C55F1192A026@cs.rutgers.edu>
In-Reply-To: <20181109131128.GE23260@techsingularity.net>
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
 <20181109131128.GE23260@techsingularity.net>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_16C263ED-FC1F-46C8-ADD9-BAA932760252_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Anthony Yznaga <anthony.yznaga@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_16C263ED-FC1F-46C8-ADD9-BAA932760252_=
Content-Type: text/plain

On 9 Nov 2018, at 8:11, Mel Gorman wrote:

> On Fri, Nov 09, 2018 at 03:13:18PM +0300, Kirill A. Shutemov wrote:
>> On Thu, Nov 08, 2018 at 10:48:58PM -0800, Anthony Yznaga wrote:
>>> The basic idea as outlined by Mel Gorman in [2] is:
>>>
>>> 1) On first fault in a sufficiently sized range, allocate a huge page
>>>    sized and aligned block of base pages.  Map the base page
>>>    corresponding to the fault address and hold the rest of the pages in
>>>    reserve.
>>> 2) On subsequent faults in the range, map the pages from the reservation.
>>> 3) When enough pages have been mapped, promote the mapped pages and
>>>    remaining pages in the reservation to a huge page.
>>> 4) When there is memory pressure, release the unused pages from their
>>>    reservations.
>>
>> I haven't yet read the patch in details, but I'm skeptical about the
>> approach in general for few reasons:
>>
>> - PTE page table retracting to replace it with huge PMD entry requires
>>   down_write(mmap_sem). It makes the approach not practical for many
>>   multi-threaded workloads.
>>
>>   I don't see a way to avoid exclusive lock here. I will be glad to
>>   be proved otherwise.
>>
>
> That problem is somewhat fundamental to the mmap_sem itself and
> conceivably it could be alleviated by range-locking (if that gets
> completed). The other thing to bear in mind is the timing. If the
> promotion is in-place due to reservations, there isn't the allocation
> overhead and the hold times *should* be short.
>

Is it possible to convert all these PTEs to migration entries during
the promotion and replace them with a huge PMD entry afterwards?
AFAIK, migrating pages does not require holding a mmap_sem.
Basically, it will act like migrating 512 base pages to a THP without
actually doing the page copy.

--
Best Regards
Yan Zi

--=_MailMate_16C263ED-FC1F-46C8-ADD9-BAA932760252_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlvlqO8WHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzOsMCACj3xPbOIFF7BqEziJHcPZ1C6vI
vTSqfLtiihNb8cPqNbZa9tds6lYuGVW5dVopevbhcNbi5pQ39ZYKbPGFOTMCzcQ/
8k5wuMR8kJkA2RYrD8dN+3UrEChxEB0r35GH92X9kvwbS9Aqtp/G3ECqBBIInLq3
QeV+XpqQHydQvLhAN33dzxC7ounHlYTKaEEl5Ca6aD6/6A5YtYKEuGeNwZeP7aHk
jzts84ic+pNFXfodgp+pTLwwG37Kne/NB3QwuFmC5Oe5Y9lnjywYk9TlUjdZjVuk
98VW/c3EKRiIKkbabm61ZgtWdzCdpbEzj+GkvTIISluChzsg3WsrgywgBCXI
=9Ao+
-----END PGP SIGNATURE-----

--=_MailMate_16C263ED-FC1F-46C8-ADD9-BAA932760252_=--
