Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E3EC4CEC5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 07:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D0B120717
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 07:03:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Lo9C+SEB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D0B120717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2A386B0005; Fri, 13 Sep 2019 03:03:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDABE6B0006; Fri, 13 Sep 2019 03:03:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCA3A6B0007; Fri, 13 Sep 2019 03:03:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0009.hostedemail.com [216.40.44.9])
	by kanga.kvack.org (Postfix) with ESMTP id BB4486B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 03:03:51 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 55B0520BE1
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:03:51 +0000 (UTC)
X-FDA: 75929007462.28.jar81_218ec6a9cae30
X-HE-Tag: jar81_218ec6a9cae30
X-Filterd-Recvd-Size: 5996
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:03:50 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46V6776BP6z9vKH5;
	Fri, 13 Sep 2019 09:03:47 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Lo9C+SEB; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id zWniB8M1cFKh; Fri, 13 Sep 2019 09:03:47 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46V6774QYRz9vKH2;
	Fri, 13 Sep 2019 09:03:47 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568358227; bh=AyuxYMR1Yo8syZCcIPlzcrvbLyPmuxun2LLiIZt5UxY=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=Lo9C+SEBqaduXoGOyBorDnpf+8JwISLneOlSFGcgJJY8qlWGaZzsb4C7dcuadXTZC
	 e5yGHtqWF6SrMhGyiQ0R4zx8DT4H4ASM+Fu1/D2UfL9R3Mf34r4ji6F/P+voIkRuzO
	 LAG9Ma5mTL5t0idPrnoCF8zSRDucaQop7Q6UvTR4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 80E098B963;
	Fri, 13 Sep 2019 09:03:48 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 9VHWBJ-wdCJw; Fri, 13 Sep 2019 09:03:48 +0200 (CEST)
Received: from [172.25.230.101] (po15451.idsi0.si.c-s.fr [172.25.230.101])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id EBB1B8B958;
	Fri, 13 Sep 2019 09:03:47 +0200 (CEST)
Subject: Re: [PATCH] mm/pgtable/debug: Fix test validating architecture page
 table helpers
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org,
 Jason Gunthorpe <jgg@ziepe.ca>, x86@kernel.org,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov"
 <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>,
 Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
 Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Vineet Gupta <vgupta@synopsys.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 "David S. Miller" <davem@davemloft.net>
References: <1892b37d1fd9a4ed39e76c4b999b6556077201c0.1568355752.git.christophe.leroy@c-s.fr>
 <527dd29d-45fa-4d83-1899-6cbf268dd749@arm.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <e2b42446-7f91-83f1-ac12-08dff75c4d35@c-s.fr>
Date: Fri, 13 Sep 2019 09:03:46 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <527dd29d-45fa-4d83-1899-6cbf268dd749@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 13/09/2019 =C3=A0 08:58, Anshuman Khandual a =C3=A9crit=C2=A0:
> On 09/13/2019 11:53 AM, Christophe Leroy wrote:
>> Fix build failure on powerpc.
>>
>> Fix preemption imbalance.
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
>> ---
>>   mm/arch_pgtable_test.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/mm/arch_pgtable_test.c b/mm/arch_pgtable_test.c
>> index 8b4a92756ad8..f2b3c9ec35fa 100644
>> --- a/mm/arch_pgtable_test.c
>> +++ b/mm/arch_pgtable_test.c
>> @@ -24,6 +24,7 @@
>>   #include <linux/swap.h>
>>   #include <linux/swapops.h>
>>   #include <linux/sched/mm.h>
>> +#include <linux/highmem.h>
>=20
> This is okay.
>=20
>>   #include <asm/pgalloc.h>
>>   #include <asm/pgtable.h>
>>  =20
>> @@ -400,6 +401,8 @@ static int __init arch_pgtable_tests_init(void)
>>   	p4d_clear_tests(p4dp);
>>   	pgd_clear_tests(mm, pgdp);
>>  =20
>> +	pte_unmap(ptep);
>> +
>=20
> Now the preemption imbalance via pte_alloc_map() path i.e
>=20
> pte_alloc_map() -> pte_offset_map() -> kmap_atomic()
>=20
> Is not this very much powerpc 32 specific or this will be applicable
> for all platform which uses kmap_XXX() to map high memory ?
>=20

See=20
https://elixir.bootlin.com/linux/v5.3-rc8/source/include/linux/highmem.h#=
L91

I think it applies at least to all arches using the generic implementatio=
n.

Applies also to arm:
https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/arm/mm/highmem.c#L5=
2

Applies also to mips:
https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/mips/mm/highmem.c#L=
47

Same on sparc:
https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/sparc/mm/highmem.c#=
L52

Same on x86:
https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/x86/mm/highmem_32.c=
#L34

I have not checked others, but I guess it is like that for all.

Christophe

