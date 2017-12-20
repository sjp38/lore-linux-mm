Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35EA66B0069
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:35:18 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 184so9291853oii.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 21:35:18 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id t194si4972808oih.344.2017.12.19.21.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 21:35:17 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration
 improvements
Date: Wed, 20 Dec 2017 05:33:36 +0000
Message-ID: <95ba8db3-f8aa-528a-db4b-80f9d2ba9d2b@ah.jp.nec.com>
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171215093309.GU16951@dhcp22.suse.cz>
In-Reply-To: <20171215093309.GU16951@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <DD1D303CCF6243499F3A2F72B69DC94D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>


On 12/15/2017 06:33 PM, Michal Hocko wrote:
> Naoya,
> this has passed Mike's review (thanks for that!), you have mentioned
> that you can pass this through your testing machinery earlier. While
> I've done some testing already I would really appreciate if you could
> do that as well. Review would be highly appreciated as well.

Sorry for my slow response. I reviewed/tested this patchset and looks
good to me overall.

I have one comment on the code path from mbind(2).
The callback passed to migrate_pages() in do_mbind() (i.e. new_page())
calls alloc_huge_page_noerr() which currently doesn't call SetPageHugeTempo=
rary(),
so hugetlb migration fails when h->surplus_huge_page >=3D h->nr_overcommit_=
huge_pages.

I don't think this is a bug, but it would be better if mbind(2) works
more similarly with other migration callers like move_pages(2)/migrate_page=
s(2).

Thanks,
Naoya Horiguchi


>=20
> Thanks!
>=20
> On Mon 04-12-17 15:01:12, Michal Hocko wrote:
>> Hi,
>> this is a follow up for [1] for the allocation API and [2] for the
>> hugetlb migration. It wasn't really easy to split those into two
>> separate patch series as they share some code.
>>
>> My primary motivation to touch this code is to make the gigantic pages
>> migration working. The giga pages allocation code is just too fragile
>> and hacked into the hugetlb code now. This series tries to move giga
>> pages closer to the first class citizen. We are not there yet but having
>> 5 patches is quite a lot already and it will already make the code much
>> easier to follow. I will come with other changes on top after this sees
>> some review.
>>
>> The first two patches should be trivial to review. The third patch
>> changes the way how we migrate huge pages. Newly allocated pages are a
>> subject of the overcommit check and they participate surplus accounting
>> which is quite unfortunate as the changelog explains. This patch doesn't
>> change anything wrt. giga pages.
>> Patch #4 removes the surplus accounting hack from
>> __alloc_surplus_huge_page.  I hope I didn't miss anything there and a
>> deeper review is really due there.
>> Patch #5 finally unifies allocation paths and giga pages shouldn't be
>> any special anymore. There is also some renaming going on as well.
>>
>> Shortlog
>> Michal Hocko (5):
>>       mm, hugetlb: unify core page allocation accounting and initializat=
ion
>>       mm, hugetlb: integrate giga hugetlb more naturally to the allocati=
on path
>>       mm, hugetlb: do not rely on overcommit limit during migration
>>       mm, hugetlb: get rid of surplus page accounting tricks
>>       mm, hugetlb: further simplify hugetlb allocation API
>>
>> Diffstat:
>>  include/linux/hugetlb.h |   3 +
>>  mm/hugetlb.c            | 305 +++++++++++++++++++++++++++--------------=
-------
>>  mm/migrate.c            |   3 +-
>>  3 files changed, 175 insertions(+), 136 deletions(-)
>>
>>
>> [1] http://lkml.kernel.org/r/20170622193034.28972-1-mhocko@kernel.org
>> [2] http://lkml.kernel.org/r/20171122152832.iayefrlxbugphorp@dhcp22.suse=
.cz
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
