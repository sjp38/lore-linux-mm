Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8DE1800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 19:47:48 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r28so3586631pgu.1
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 16:47:48 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0096.outbound.protection.outlook.com. [104.47.34.96])
        by mx.google.com with ESMTPS id j11si793109pgs.614.2018.01.24.16.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 16:47:47 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
Date: Wed, 24 Jan 2018 19:47:36 -0500
Message-ID: <59F98618-C49F-48A8-BCA1-A8F717888BAA@cs.rutgers.edu>
In-Reply-To: <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
 <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_D1E070BD-92CC-469D-B3B3-2525D7389766_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitin.m.gupta@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Nitin Gupta <nitingupta910@gmail.com>, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_D1E070BD-92CC-469D-B3B3-2525D7389766_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


>
>>> With this change, whenever an application issues MADV_DONTNEED on a
>>> memory region, the region is marked as "space-efficient". For such
>>> regions, a hugepage is not immediately allocated on first write.
>>
>> Kirill didn't like it in the previous version and I do not like this
>> either. You are adding a very subtle side effect which might completel=
y
>> unexpected. Consider userspace memory allocator which uses MADV_DONTNE=
ED
>> to free up unused memory. Now you have put it out of THP usage
>> basically.
>>
>
> Userpsace may want a region to be considered by khugepaged while opting=

> out of hugepage allocation on first touch. Asking userspace memory
> allocators to have to track and reclaim unused parts of a THP allocated=

> hugepage does not seems right, as the kernel can use simple userspace
> hints to avoid allocating extra memory in the first place.
>
> I agree that this patch is adding a subtle side-effect which may take
> some applications by surprise. However, I often see the opposite too:
> for many workloads, disabling THP is the first advise as this aggressiv=
e
> allocation of hugepages on first touch is unexpected and is too
> wasteful. For e.g.:
>
> 1) Disabling THP for TokuDB (Storage engine for MySQL, MariaDB)
> http://www.chriscalender.com/disabling-transparent-hugepages-for-tokudb=
/
>
> 2) Disable THP on MongoDB
> https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/
>
> 3) Disable THP for Couchbase Server
> https://blog.couchbase.com/often-overlooked-linux-os-tweaks/
>
> 4) Redis
> http://antirez.com/news/84
>
>
>> If the memory is used really scarce then we have MADV_NOHUGEPAGE.
>>
>
> It's not really about memory scarcity but a more efficient use of it.
> Applications may want hugepage benefits without requiring any changes t=
o
> app code which is what THP is supposed to provide, while still avoiding=

> memory bloat.
>

I read these links and find that there are mainly two complains:
1. THP causes latency spikes, because direction compaction slows down THP=
 allocation,
2. THP bloats memory footprint when jemalloc uses MADV_DONTNEED to return=
 memory ranges smaller than
   THP size and fails because of THP.

The first complain is not related to this patch.

For second one, at least with recent kernels, MADV_DONTNEED splits THPs a=
nd returns the memory range you
specified in madvise(). Am I missing anything?


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_D1E070BD-92CC-469D-B3B3-2525D7389766_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlppKSgWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzPqKB/9MOBPIl4Q5ZTt6y6NriJc9bIX7
hRF68xpcJPa45wr8hy0gVfiBBQ9q7ifa2Uv7pHDA51rvPrISBt+DnhoCvlLzXYd+
yyirWmBzhLGXu5QPejEcsRf5TuHjdEFWBVkV4pqlUscvDVmMuySpVzPrfqpYVfFu
xTelPpheXH9Yq7jmI1+xzlI6FyPfFLMtrTXbGP/faVzdlfG4NhmgQAYucBS8uuGt
6c0ic2oVqnNaP2XUyT2cnjECQa5STWxcfltIT6dGjMO7/kxDua/E37diACJoKl6L
4RUb09/cBLqlsHSro0WvBlGs3Pn3Vbfb92aNNc8rqh0apXVh+NcUJ9MnB5Tx
=4QFO
-----END PGP SIGNATURE-----

--=_MailMate_D1E070BD-92CC-469D-B3B3-2525D7389766_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
