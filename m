Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF4A78E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 22:32:10 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id t81so22789358yba.19
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 19:32:10 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u187-v6si32628726ybf.401.2019.01.02.19.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 19:32:09 -0800 (PST)
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103015654.GB15619@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <785af237-eb67-c304-595d-9080a2f48102@nvidia.com>
Date: Wed, 2 Jan 2019 19:32:08 -0800
MIME-Version: 1.0
In-Reply-To: <20190103015654.GB15619@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>

On 1/2/19 5:56 PM, Jerome Glisse wrote:
> On Wed, Jan 02, 2019 at 04:21:26PM -0800, Matthew Wilcox wrote:
>>
>> One of the paths in follow_pte_pmd() initialised the mmu_notifier_range
>> incorrectly.
>>
>> Signed-off-by: Matthew Wilcox <willy@infradead.org>
>> Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_rang=
e_start/end calls v2")
>> Tested-by: Dave Chinner <dchinner@redhat.com>
>=20
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 2dd2f9ab57f4..21a650368be0 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -4078,8 +4078,8 @@ static int __follow_pte_pmd(struct mm_struct *mm, =
unsigned long address,
>>  		goto out;
>> =20
>>  	if (range) {
>> -		range->start =3D address & PAGE_MASK;
>> -		range->end =3D range->start + PAGE_SIZE;
>> +		mmu_notifier_range_init(range, mm, address & PAGE_MASK,
>> +				     (address & PAGE_MASK) + PAGE_SIZE);
>>  		mmu_notifier_invalidate_range_start(range);
>>  	}
>>  	ptep =3D pte_offset_map_lock(mm, pmd, address, ptlp);
>=20

Looks correct to me, as well.

Having the range struct declared in separate places from the mmu_notifier_r=
ange_init()
calls is not great. But I'm not sure I see a way to make it significantly c=
leaner, given
that __follow_pte_pmd uses the range pointer as a way to decide to issue th=
e mmn calls.


thanks,
--=20
John Hubbard
NVIDIA
