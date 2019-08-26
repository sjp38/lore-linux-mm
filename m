Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEEACC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 17:30:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97DCC20874
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 17:30:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="aLr5JbFy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97DCC20874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 249E26B05C5; Mon, 26 Aug 2019 13:30:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D2DA6B05C9; Mon, 26 Aug 2019 13:30:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09A266B05CA; Mon, 26 Aug 2019 13:30:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id D73F16B05C5
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:30:49 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 83A51181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 17:30:49 +0000 (UTC)
X-FDA: 75865269018.03.car64_5e69ea8a74750
X-HE-Tag: car64_5e69ea8a74750
X-Filterd-Recvd-Size: 4615
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 17:30:48 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d6417480002>; Mon, 26 Aug 2019 10:30:48 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 26 Aug 2019 10:30:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 26 Aug 2019 10:30:47 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 26 Aug
 2019 17:30:46 +0000
Subject: Re: [PATCH] mm/migrate: initialize pud_entry in migrate_vma()
To: Vlastimil Babka <vbabka@suse.cz>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton
	<akpm@linux-foundation.org>
References: <20190719233225.12243-1-rcampbell@nvidia.com>
 <0d639edf-9f96-c170-4920-d64c2891d35d@suse.cz>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <dcadcd98-e9b4-2b4e-8a9f-5a1ef0ece0d5@nvidia.com>
Date: Mon, 26 Aug 2019 10:30:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <0d639edf-9f96-c170-4920-d64c2891d35d@suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL111.nvidia.com (172.20.187.18) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566840648; bh=wgJD6Csy/s6yr4UYxieJmYbxqUj/d5mbZ6ONdDZ3WhI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=aLr5JbFymgRG9vRzfe1Hbp8+2BZTFtY3t76OzLIP/HV/mKdZMv0dk32Dopf8kv8Mf
	 I+2RnPrashuxzsKe5d1FnGYg2LOfele0EkIwTR2oO3orHb0fHC8RLRhxknZ1d0e+b3
	 f/2Wvm2zEzppEMeE2AXrz/MKsv40syocN2kkWTJzszN7ZVL6rfKoWD9/eOBb2i2GSL
	 JPnrXWl+DT0LO9nYpoKT7pbyVgtEH+5HcMl5VwDXY3V89x4IyZC/HDyVGnNxWVHqu/
	 YBuiO2c9y0J7uyZPIzSGUTdodU/os6UGzZXKG3UGaQ7asTj3p4P1KUFOUlX2M+EveK
	 ED/Jpu20djarQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/26/19 8:11 AM, Vlastimil Babka wrote:
> On 7/20/19 1:32 AM, Ralph Campbell wrote:
>> When CONFIG_MIGRATE_VMA_HELPER is enabled, migrate_vma() calls
>> migrate_vma_collect() which initializes a struct mm_walk but
>> didn't initialize mm_walk.pud_entry. (Found by code inspection)
>> Use a C structure initialization to make sure it is set to NULL.
>>
>> Fixes: 8763cb45ab967 ("mm/migrate: new memory migration helper for use w=
ith
>> device memory")
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>=20
> So this bug can manifest by some garbage address on stack being called, r=
ight? I
> wonder, how comes it didn't actually happen yet?

Right.
Probably because HMM isn't widely being used in production yet.

>=20
>> ---
>>   mm/migrate.c | 17 +++++++----------
>>   1 file changed, 7 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 515718392b24..a42858d8e00b 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -2340,16 +2340,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>>   static void migrate_vma_collect(struct migrate_vma *migrate)
>>   {
>>   	struct mmu_notifier_range range;
>> -	struct mm_walk mm_walk;
>> -
>> -	mm_walk.pmd_entry =3D migrate_vma_collect_pmd;
>> -	mm_walk.pte_entry =3D NULL;
>> -	mm_walk.pte_hole =3D migrate_vma_collect_hole;
>> -	mm_walk.hugetlb_entry =3D NULL;
>> -	mm_walk.test_walk =3D NULL;
>> -	mm_walk.vma =3D migrate->vma;
>> -	mm_walk.mm =3D migrate->vma->vm_mm;
>> -	mm_walk.private =3D migrate;
>> +	struct mm_walk mm_walk =3D {
>> +		.pmd_entry =3D migrate_vma_collect_pmd,
>> +		.pte_hole =3D migrate_vma_collect_hole,
>> +		.vma =3D migrate->vma,
>> +		.mm =3D migrate->vma->vm_mm,
>> +		.private =3D migrate,
>> +	};
>>  =20
>>   	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm_walk.mm=
,
>>   				migrate->start,
>>
>=20

