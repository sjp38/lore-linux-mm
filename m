Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC940C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 08:42:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CEA320830
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 08:42:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CEA320830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 123406B0005; Fri, 13 Sep 2019 04:42:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AC546B0006; Fri, 13 Sep 2019 04:42:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB5F76B0007; Fri, 13 Sep 2019 04:42:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0071.hostedemail.com [216.40.44.71])
	by kanga.kvack.org (Postfix) with ESMTP id C24426B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 04:42:47 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 567FD1F845
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 08:42:47 +0000 (UTC)
X-FDA: 75929256774.16.list83_182eec515ad16
X-HE-Tag: list83_182eec515ad16
X-Filterd-Recvd-Size: 6015
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 08:42:46 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D181628;
	Fri, 13 Sep 2019 01:42:44 -0700 (PDT)
Received: from [10.162.41.125] (p8cg001049571a15.blr.arm.com [10.162.41.125])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A21F43F59C;
	Fri, 13 Sep 2019 01:42:34 -0700 (PDT)
Subject: Re: [PATCH] mm/pgtable/debug: Fix test validating architecture page
 table helpers
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
 Dan Williams <dan.j.williams@intel.com>, linux-s390@vger.kernel.org,
 Jason Gunthorpe <jgg@ziepe.ca>, x86@kernel.org,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Vlastimil Babka <vbabka@suse.cz>, linux-snps-arc@lists.infradead.org,
 Kees Cook <keescook@chromium.org>, Mark Brown <broonie@kernel.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Thomas Gleixner <tglx@linutronix.de>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 linux-arm-kernel@lists.infradead.org,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
 Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Vineet Gupta <vgupta@synopsys.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 "David S. Miller" <davem@davemloft.net>
References: <1892b37d1fd9a4ed39e76c4b999b6556077201c0.1568355752.git.christophe.leroy@c-s.fr>
 <527dd29d-45fa-4d83-1899-6cbf268dd749@arm.com>
 <e2b42446-7f91-83f1-ac12-08dff75c4d35@c-s.fr>
 <cb226b56-ff20-3136-7ffb-890657e56870@c-s.fr>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bdf7f152-d093-1691-4e96-77da7eb9e20a@arm.com>
Date: Fri, 13 Sep 2019 14:12:45 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <cb226b56-ff20-3136-7ffb-890657e56870@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/13/2019 12:41 PM, Christophe Leroy wrote:
>=20
>=20
> Le 13/09/2019 =C3=A0 09:03, Christophe Leroy a =C3=A9crit=C2=A0:
>>
>>
>> Le 13/09/2019 =C3=A0 08:58, Anshuman Khandual a =C3=A9crit=C2=A0:
>>> On 09/13/2019 11:53 AM, Christophe Leroy wrote:
>>>> Fix build failure on powerpc.
>>>>
>>>> Fix preemption imbalance.
>>>>
>>>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
>>>> ---
>>>> =C2=A0 mm/arch_pgtable_test.c | 3 +++
>>>> =C2=A0 1 file changed, 3 insertions(+)
>>>>
>>>> diff --git a/mm/arch_pgtable_test.c b/mm/arch_pgtable_test.c
>>>> index 8b4a92756ad8..f2b3c9ec35fa 100644
>>>> --- a/mm/arch_pgtable_test.c
>>>> +++ b/mm/arch_pgtable_test.c
>>>> @@ -24,6 +24,7 @@
>>>> =C2=A0 #include <linux/swap.h>
>>>> =C2=A0 #include <linux/swapops.h>
>>>> =C2=A0 #include <linux/sched/mm.h>
>>>> +#include <linux/highmem.h>
>>>
>>> This is okay.
>>>
>>>> =C2=A0 #include <asm/pgalloc.h>
>>>> =C2=A0 #include <asm/pgtable.h>
>>>> @@ -400,6 +401,8 @@ static int __init arch_pgtable_tests_init(void)
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d_clear_tests(p4dp);
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pgd_clear_tests(mm, pgdp);
>>>> +=C2=A0=C2=A0=C2=A0 pte_unmap(ptep);
>>>> +
>>>
>>> Now the preemption imbalance via pte_alloc_map() path i.e
>>>
>>> pte_alloc_map() -> pte_offset_map() -> kmap_atomic()
>>>
>>> Is not this very much powerpc 32 specific or this will be applicable
>>> for all platform which uses kmap_XXX() to map high memory ?
>>>
>>
>> See https://elixir.bootlin.com/linux/v5.3-rc8/source/include/linux/hig=
hmem.h#L91
>>
>> I think it applies at least to all arches using the generic implementa=
tion.
>>
>> Applies also to arm:
>> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/arm/mm/highmem.c=
#L52
>>
>> Applies also to mips:
>> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/mips/mm/highmem.=
c#L47
>>
>> Same on sparc:
>> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/sparc/mm/highmem=
.c#L52
>>
>> Same on x86:
>> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/x86/mm/highmem_3=
2.c#L34
>>
>> I have not checked others, but I guess it is like that for all.
>>
>=20
>=20
> Seems like I answered too quickly. All kmap_atomic() do preempt_disable=
(), but not all pte_alloc_map() call kmap_atomic().
>=20
> However, for instance ARM does:
>=20
> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/arm/include/asm/p=
gtable.h#L200
>=20
> And X86 as well:
>=20
> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/x86/include/asm/p=
gtable_32.h#L51
>=20
> Microblaze also:
>=20
> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/microblaze/includ=
e/asm/pgtable.h#L495

All the above platforms checks out to be using k[un]map_atomic(). I am wo=
ndering whether
any of the intermediate levels will have similar problems on any these 32=
 bit platforms
or any other platforms which might be using generic k[un]map_atomic(). Th=
ere can be many
permutations here.

	p4dp =3D p4d_alloc(mm, pgdp, vaddr);
	pudp =3D pud_alloc(mm, p4dp, vaddr);
	pmdp =3D pmd_alloc(mm, pudp, vaddr);

Otherwise pte_alloc_map()/pte_unmap() looks good enough which will atleas=
t take care of
a known failure.

