Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02505C3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:28:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C53612339D
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:28:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C53612339D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57E7B6B0003; Wed,  4 Sep 2019 01:28:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52DE76B0006; Wed,  4 Sep 2019 01:28:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4449B6B0007; Wed,  4 Sep 2019 01:28:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id 255CC6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 01:28:47 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C7A87A2D3
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:28:46 +0000 (UTC)
X-FDA: 75896108652.22.pear51_86890384f6a0e
X-HE-Tag: pear51_86890384f6a0e
X-Filterd-Recvd-Size: 4885
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:28:44 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6AF87344;
	Tue,  3 Sep 2019 22:28:43 -0700 (PDT)
Received: from [10.162.41.129] (p8cg001049571a15.blr.arm.com [10.162.41.129])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6D8A73F718;
	Tue,  3 Sep 2019 22:31:03 -0700 (PDT)
Subject: Re: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
To: "Justin He (Arm Technology China)" <Justin.He@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Peter Zijlstra <peterz@infradead.org>,
 Dave Airlie <airlied@redhat.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Thomas Hellstrom <thellstrom@vmware.com>,
 Souptick Joarder <jrdr.linux@gmail.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <20190904005831.153934-1-justin.he@arm.com>
 <fd22d787-3240-fe42-3ca3-9e8a98f86fce@arm.com>
 <961889b3-ef08-2ee9-e3a1-6aba003f47c1@arm.com>
 <DB7PR08MB3082E820B4871F1D1552BF34F7B80@DB7PR08MB3082.eurprd08.prod.outlook.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <1b7aa74b-c6a7-0406-2802-8cf639e35bf0@arm.com>
Date: Wed, 4 Sep 2019 10:58:47 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <DB7PR08MB3082E820B4871F1D1552BF34F7B80@DB7PR08MB3082.eurprd08.prod.outlook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/04/2019 10:27 AM, Justin He (Arm Technology China) wrote:
> Hi Anshuman, thanks for the comments, see below please
>=20
>> -----Original Message-----
>> From: Anshuman Khandual <anshuman.khandual@arm.com>
>> Sent: 2019=E5=B9=B49=E6=9C=884=E6=97=A5 12:38
>> To: Justin He (Arm Technology China) <Justin.He@arm.com>; Andrew
>> Morton <akpm@linux-foundation.org>; Matthew Wilcox
>> <willy@infradead.org>; J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>; R=
alph
>> Campbell <rcampbell@nvidia.com>; Jason Gunthorpe <jgg@ziepe.ca>;
>> Peter Zijlstra <peterz@infradead.org>; Dave Airlie <airlied@redhat.com=
>;
>> Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>; Thomas Hellstrom
>> <thellstrom@vmware.com>; Souptick Joarder <jrdr.linux@gmail.com>;
>> linux-mm@kvack.org; linux-kernel@vger.kernel.org
>> Subject: Re: [PATCH] mm: fix double page fault on arm64 if PTE_AF is
>> cleared
>>
>>
>>
>> On 09/04/2019 08:49 AM, Anshuman Khandual wrote:
>>>  		/*
>>>  		 * This really shouldn't fail, because the page is there
>>>  		 * in the page tables. But it might just be unreadable,
>>>  		 * in which case we just give up and fill the result with
>>> -		 * zeroes.
>>> +		 * zeroes. If PTE_AF is cleared on arm64, it might
>>> +		 * cause double page fault here. so makes pte young here
>>>  		 */
>>> +		if (!pte_young(vmf->orig_pte)) {
>>> +			entry =3D pte_mkyoung(vmf->orig_pte);
>>> +			if (ptep_set_access_flags(vmf->vma, vmf->address,
>>> +				vmf->pte, entry, vmf->flags &
>> FAULT_FLAG_WRITE))
>>> +				update_mmu_cache(vmf->vma, vmf-
>>> address,
>>> +						vmf->pte);
>>> +		}
>>
>> This looks correct where it updates the pte entry with PTE_AF which
>> will prevent a subsequent page fault. But I think what we really need
>> here is to make sure 'uaddr' is mapped correctly at vma->pte. Probably
>> a generic function arch_map_pte() when defined for arm64 should check
>> CPU version and ensure continuance of PTE_AF if required. The comment
>> above also need to be updated saying not only the page should be there
>> in the page table, it needs to mapped appropriately as well.
>=20
> I agree that a generic interface here is needed but not the arch_map_pt=
e().
> In this case, I thought all the pgd/pud/pmd/pte had been set correctly =
except
> for the PTE_AF bit.
> How about arch_hw_access_flag()?

Sure, go ahead. I just meant 'map' to include not only the PFN but also
appropriate HW attributes not cause a page fault.

> If non-arm64, arch_hw_access_flag() =3D=3D true

The function does not need to return anything. Dummy default definition
in generic MM will do nothing when arch does not override.

> If arm64 with hardware-managed access flag supported, =3D=3D true
> else =3D=3D false?

On arm64 with hardware-managed access flag supported, it will do nothing.
But in case its not supported the above mentioned pte update as in the
current proposal needs to be executed. The details should hide in arch
specific override.

