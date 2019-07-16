Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00AFFC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 00:38:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9936420880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 00:38:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="LUCe3kDU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9936420880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF5056B0003; Mon, 15 Jul 2019 20:38:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7DCC6B0008; Mon, 15 Jul 2019 20:38:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D44C06B000A; Mon, 15 Jul 2019 20:38:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE0736B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 20:38:10 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b75so15022786ywh.8
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 17:38:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=ofrUZPeHN8eLZ9OqaICadscElKqWN6p7kWys0JZTuhA=;
        b=mn8XBWdQJu/pkZjR+SXgiIzCCjFt/NwQzgfZI5/4CnEu+6tuSrjwcFtdgpUcIcODrh
         VbGwOpObL6AR7aIIKY9HdlgYzj1IlqJWm6zKyxlXctiwje84nnX55tXHcjOuJ+yFaKij
         E5vNAj5zwULRlbcfFTKi24kxrbV5QNAwfgp8HbZAjlqW6Auy7NxDdre7azB7dfp2Tdu4
         m5bQQHdOgTikmoMvkrj7oiwA2B/4z2dTckaI51RkulQS2tAnLjmiS1qGve8jZSenbdZn
         HoiUjeKR9Orq2P8sfuTK6GdgorKkCT85yEJFFnfQYmUcTqgFT1g5egWjrm8gkVi8fTrN
         +INQ==
X-Gm-Message-State: APjAAAWFXvUSAi1nWvh+WJAAW9GNhm+hGVRZLdzq8/MI3PO4Yk/Rnw5X
	fKadlhdLkDKnoiPRw2Ye619wWUksL4+hjbn0SWJRyLBeWTUAzxIHQ2Z8GolOrO75/eqcrIK5N2h
	F20Bxk+fY7tOhiQx9mzgcTWF+wGDncdnA/K/Q5f0hnBYH4lx/INimBnvQ+F/NVr8DUw==
X-Received: by 2002:a81:f012:: with SMTP id p18mr16017386ywm.375.1563237490342;
        Mon, 15 Jul 2019 17:38:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCT5ESFQdknFZ5yF1ol9LXhW5nX5RL5wcpM2ncrrLaV1+0cbthg0Aa0K7IkeCzGJuDc2OD
X-Received: by 2002:a81:f012:: with SMTP id p18mr16017350ywm.375.1563237489475;
        Mon, 15 Jul 2019 17:38:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563237489; cv=none;
        d=google.com; s=arc-20160816;
        b=GtlpVXRiZQTSd125npz7iomOg018NvDIULCmcd3hhxLzzmTpH+l/orkbDPtqYY47HN
         BiKTmxwb0yCrMdfBa7EUuHzTHsTBCww/hVPIEEwISw9u5KA2tjSr2YwwQQSMSfT60FzC
         NBCb7JxhRxV4T/YecRcNl1hdPS3yvdwLU4X7dYUSZSt6FJD2xBO9Vdr0uFyk2qm8LKDV
         sRc4adqREEc7XUj1SA4/jJixhbMyaFIVKdJI0KuPMHl4gp+kn6AjruzvkY58ZNDPvJj9
         +ZOydSRiV27svmYyP11EsTNE0N/kpgUZoeuPM77xq5HhGtemJhETt9WUGocJacFTfCVh
         T5eA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=ofrUZPeHN8eLZ9OqaICadscElKqWN6p7kWys0JZTuhA=;
        b=gCNHQPGLqXlpkHZAyVTSAt6rs3dJnCMJqa3WD/1jk/vG9dYTm2vRlSXpLqTsZoVn+T
         WFk96/JWcOXzMFRf2pEGz2X6o1U3cEoYlGzuFPxktLZUEzmJBeIVlpKzjC0drK+43s7T
         Fmrgcv+K+q7I8BxM3EHjCoErpnIeRQ+OrkvihFTAcZ4Pm9ui41O06+TtvCkstuE9OL/A
         aVEjcSW3g4ixUekHE21aLZrIPJGmhITRjuPCM1/MnzHR/QsGkHgeqzihBZXNC4OTm4Mu
         9i4HcfNtkBBJQQ9W+uFRZEihRzxJdpsRnHXMRt32phmwxsq0Mm4ZJIp5x08N7MnmNXOx
         BzwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=LUCe3kDU;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id i69si7248567ywg.316.2019.07.15.17.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 17:38:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=LUCe3kDU;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2d1c6e0000>; Mon, 15 Jul 2019 17:38:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 15 Jul 2019 17:38:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 15 Jul 2019 17:38:08 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 16 Jul
 2019 00:38:04 +0000
Subject: Re: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
To: John Hubbard <jhubbard@nvidia.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>,
	Jason Gunthorpe <jgg@mellanox.com>
References: <20190709223556.28908-1-rcampbell@nvidia.com>
 <20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
 <05fffcad-cf5e-8f0c-f0c7-6ffbd2b10c2e@nvidia.com>
 <20190715150031.49c2846f4617f30bca5f043f@linux-foundation.org>
 <0ee5166a-26cd-a504-b9db-cffd082ecd38@nvidia.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <8dd86951-f8b0-75c2-d738-5080343e5dc5@nvidia.com>
Date: Mon, 15 Jul 2019 17:38:04 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <0ee5166a-26cd-a504-b9db-cffd082ecd38@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563237486; bh=ofrUZPeHN8eLZ9OqaICadscElKqWN6p7kWys0JZTuhA=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=LUCe3kDURX1xDPj2CwtN0jMKxVWQAyodV2+L1dwfQqHya3HI/sRDK9smEEbPHb0Ff
	 2mWdkD7daq3TlbcP/jPe/QgeLnCmv9MR87AAkK0rYBBLcIdpFz4CVSHPw8Pj6GRf6Z
	 IsVXfYeACcGxnhFyFKkMkmeyzkxVhsMH50pb9rd/qVbK1HzDYSmTjAkqk1jBUST8+s
	 2AA/JJqG6pnvYbOD/effu13h7Q1Yki3WPB2j7nXgiRUYRwqMM6Q2wIoo0HKj7bbmw+
	 lUEQZzcW3IcuLSZC5BOnC8Zm7Y3LCNf520ktUCMVxdFiPfHnYvX4upKEIQxU1HFATa
	 ar0051SC/Q4nA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/15/19 4:34 PM, John Hubbard wrote:
> On 7/15/19 3:00 PM, Andrew Morton wrote:
>> On Tue, 9 Jul 2019 18:24:57 -0700 Ralph Campbell <rcampbell@nvidia.com> =
wrote:
>>
>>>
>>> On 7/9/19 5:28 PM, Andrew Morton wrote:
>>>> On Tue, 9 Jul 2019 15:35:56 -0700 Ralph Campbell <rcampbell@nvidia.com=
> wrote:
>>>>
>>>>> When migrating a ZONE device private page from device memory to syste=
m
>>>>> memory, the subpage pointer is initialized from a swap pte which comp=
utes
>>>>> an invalid page pointer. A kernel panic results such as:
>>>>>
>>>>> BUG: unable to handle page fault for address: ffffea1fffffffc8
>>>>>
>>>>> Initialize subpage correctly before calling page_remove_rmap().
>>>>
>>>> I think this is
>>>>
>>>> Fixes:  a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVIC=
E page in migration")
>>>> Cc: stable
>>>>
>>>> yes?
>>>>
>>>
>>> Yes. Can you add this or should I send a v2?
>>
>> I updated the patch.  Could we please have some review input?
>>
>>
>> From: Ralph Campbell <rcampbell@nvidia.com>
>> Subject: mm/hmm: fix bad subpage pointer in try_to_unmap_one
>>
>> When migrating a ZONE device private page from device memory to system
>> memory, the subpage pointer is initialized from a swap pte which compute=
s
>> an invalid page pointer. A kernel panic results such as:
>>
>> BUG: unable to handle page fault for address: ffffea1fffffffc8
>>
>> Initialize subpage correctly before calling page_remove_rmap().
>>
>> Link: http://lkml.kernel.org/r/20190709223556.28908-1-rcampbell@nvidia.c=
om
>> Fixes: a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE p=
age in migration")
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>> Cc: Jason Gunthorpe <jgg@mellanox.com>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>>   mm/rmap.c |    1 +
>>   1 file changed, 1 insertion(+)
>>
>> --- a/mm/rmap.c~mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one
>> +++ a/mm/rmap.c
>> @@ -1476,6 +1476,7 @@ static bool try_to_unmap_one(struct page
>>   			 * No need to invalidate here it will synchronize on
>>   			 * against the special swap migration pte.
>>   			 */
>> +			subpage =3D page;
>>   			goto discard;
>>   		}
>>  =20
>=20
> Hi Ralph and everyone,
>=20
> While the above prevents a crash, I'm concerned that it is still not
> an accurate fix. This fix leads to repeatedly removing the rmap, against =
the
> same struct page, which is odd, and also doesn't directly address the
> root cause, which I understand to be: this routine can't handle migrating
> the zero page properly--over and back, anyway. (We should also mention mo=
re
> about how this is triggered, in the commit description.)
>=20
> I'll take a closer look at possible fixes (I have to step out for a bit) =
soon,
> but any more experienced help is also appreciated here.
>=20
> thanks,

I'm not surprised at the confusion. It took me quite awhile to=20
understand how migrate_vma() works with ZONE_DEVICE private memory.
The big point to be aware of is that when migrating a page to
device private memory, the source page's page->mapping pointer
is copied to the ZONE_DEVICE struct page and the page_mapcount()
is increased. So, the kernel sees the page as being "mapped"
but the page table entry as being is_swap_pte() so the CPU will fault
if it tries to access the mapped address.
So yes, the source anon page is unmapped, DMA'ed to the device,
and then mapped again. Then on a CPU fault, the zone device page
is unmapped, DMA'ed to system memory, and mapped again.
The rmap_walk() is used to clear the temporary migration pte so
that is another important detail of how migrate_vma() works.
At the moment, only single anon private pages can migrate to
device private memory so there are no subpages and setting it to "page"
should be correct for now. I'm looking at supporting migration of
transparent huge pages but that is a work in progress.
Let me know how much of all that you think should be in the change log.
Getting an Acked-by from Jerome would be nice too.

I see Christoph Hellwig got confused by this too [1].
I have a patch to clear page->mapping when freeing ZONE_DEVICE private
struct pages which I'll send out soon.
I'll probably also add some comments to struct page to include the
above info and maybe remove the _zd_pad_1 field.

[1] 740d6310ed4cd5c78e63 ("mm: don't clear ->mapping in hmm_devmem_free")

