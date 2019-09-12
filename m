Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1558C4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 14:42:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55AA020830
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 14:42:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="rF17s6tJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55AA020830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E382D6B0005; Thu, 12 Sep 2019 10:42:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC1B76B0006; Thu, 12 Sep 2019 10:42:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C88F76B0007; Thu, 12 Sep 2019 10:42:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id A16086B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:42:30 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3FCD8180AD806
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 14:42:30 +0000 (UTC)
X-FDA: 75926534460.26.clam05_32e157c7d8933
X-HE-Tag: clam05_32e157c7d8933
X-Filterd-Recvd-Size: 10018
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 14:42:29 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46ThLp3CQXz9typD;
	Thu, 12 Sep 2019 16:42:26 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=rF17s6tJ; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id CVQlmJ3AEH2k; Thu, 12 Sep 2019 16:42:26 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46ThLp1t53z9typC;
	Thu, 12 Sep 2019 16:42:26 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568299346; bh=otnUrb4pzuxU7Yp0+QroZ8OVT4O1umudoLeJqQl5wZo=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=rF17s6tJhq8MvFO5HaHkJAy0j4vJJMc9gH1QsIdlkc0uGkrBFzY6mm7WqD7gp6Y2w
	 pDwud6FagAuEx2hmyDZDo1d1qU6dEAs2y6kNIO4poGfjfz3+JYPoadusOPxMP4DNCT
	 uG/GxTT9Ndmwpf9KkQmrv+QnUdDjo6qRIVZu/AVs=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id C98AA8B940;
	Thu, 12 Sep 2019 16:42:27 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 67GVoWa0YCuH; Thu, 12 Sep 2019 16:42:27 +0200 (CEST)
Received: from [192.168.4.90] (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A5BBC8B933;
	Thu, 12 Sep 2019 16:42:25 +0200 (CEST)
Subject: Re: [PATCH V2 0/2] mm/debug: Add tests for architecture exported page
 table helpers
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Thomas Gleixner <tglx@linutronix.de>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Dan Williams <dan.j.williams@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>, Mark Brown <broonie@kernel.org>,
 Steven Price <Steven.Price@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Matthew Wilcox <willy@infradead.org>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 "David S. Miller" <davem@davemloft.net>, Vineet Gupta <vgupta@synopsys.com>,
 James Hogan <jhogan@kernel.org>, Paul Burton <paul.burton@mips.com>,
 Ralf Baechle <ralf@linux-mips.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 Mike Kravetz <mike.kravetz@oracle.com>, linux-snps-arc@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <527edfce-c986-de4c-e286-34a70f6a2790@c-s.fr>
Date: Thu, 12 Sep 2019 16:42:25 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I didn't get patch 1 of this series, and it is not on linuxppc-dev=20
patchwork either. Can you resend ?

Thanks
Christophe

Le 12/09/2019 =C3=A0 08:02, Anshuman Khandual a =C3=A9crit=C2=A0:
> This series adds a test validation for architecture exported page table
> helpers. Patch in the series adds basic transformation tests at various
> levels of the page table. Before that it exports gigantic page allocati=
on
> function from HugeTLB.
>=20
> This test was originally suggested by Catalin during arm64 THP migratio=
n
> RFC discussion earlier. Going forward it can include more specific test=
s
> with respect to various generic MM functions like THP, HugeTLB etc and
> platform specific tests.
>=20
> https://lore.kernel.org/linux-mm/20190628102003.GA56463@arrakis.emea.ar=
m.com/
>=20
> Testing:
>=20
> Successfully build and boot tested on both arm64 and x86 platforms with=
out
> any test failing. Only build tested on some other platforms.
>=20
> But I would really appreciate if folks can help validate this test on o=
ther
> platforms and report back problems. All suggestions, comments and input=
s
> welcome. Thank you.
>=20
> Changes in V2:
>=20
> - Fixed small typo error in MODULE_DESCRIPTION()
> - Fixed m64k build problems for lvalue concerns in pmd_xxx_tests()
> - Fixed dynamic page table level folding problems on x86 as per Kirril
> - Fixed second pointers during pxx_populate_tests() per Kirill and Gera=
ld
> - Allocate and free pte table with pte_alloc_one/pte_free per Kirill
> - Modified pxx_clear_tests() to accommodate s390 lower 12 bits situatio=
n
> - Changed RANDOM_NZVALUE value from 0xbe to 0xff
> - Changed allocation, usage, free sequence for saved_ptep
> - Renamed VMA_FLAGS as VMFLAGS
> - Implemented a new method for random vaddr generation
> - Implemented some other cleanups
> - Dropped extern reference to mm_alloc()
> - Created and exported new alloc_gigantic_page_order()
> - Dropped the custom allocator and used new alloc_gigantic_page_order()
>=20
> Changes in V1:
>=20
> https://lore.kernel.org/linux-mm/1567497706-8649-1-git-send-email-anshu=
man.khandual@arm.com/
>=20
> - Added fallback mechanism for PMD aligned memory allocation failure
>=20
> Changes in RFC V2:
>=20
> https://lore.kernel.org/linux-mm/1565335998-22553-1-git-send-email-ansh=
uman.khandual@arm.com/T/#u
>=20
> - Moved test module and it's config from lib/ to mm/
> - Renamed config TEST_ARCH_PGTABLE as DEBUG_ARCH_PGTABLE_TEST
> - Renamed file from test_arch_pgtable.c to arch_pgtable_test.c
> - Added relevant MODULE_DESCRIPTION() and MODULE_AUTHOR() details
> - Dropped loadable module config option
> - Basic tests now use memory blocks with required size and alignment
> - PUD aligned memory block gets allocated with alloc_contig_range()
> - If PUD aligned memory could not be allocated it falls back on PMD ali=
gned
>    memory block from page allocator and pud_* tests are skipped
> - Clear and populate tests now operate on real in memory page table ent=
ries
> - Dummy mm_struct gets allocated with mm_alloc()
> - Dummy page table entries get allocated with [pud|pmd|pte]_alloc_[map]=
()
> - Simplified [p4d|pgd]_basic_tests(), now has random values in the entr=
ies
>=20
> Original RFC V1:
>=20
> https://lore.kernel.org/linux-mm/1564037723-26676-1-git-send-email-ansh=
uman.khandual@arm.com/
>=20
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Steven Price <Steven.Price@arm.com>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Sri Krishna chowdary <schowdary@nvidia.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Russell King - ARM Linux <linux@armlinux.org.uk>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: James Hogan <jhogan@kernel.org>
> Cc: Paul Burton <paul.burton@mips.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-mips@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: x86@kernel.org
> Cc: linux-kernel@vger.kernel.org
>=20
> Anshuman Khandual (2):
>    mm/hugetlb: Make alloc_gigantic_page() available for general use
>    mm/pgtable/debug: Add test validating architecture page table helper=
s
>=20
>   arch/x86/include/asm/pgtable_64_types.h |   2 +
>   include/linux/hugetlb.h                 |   9 +
>   mm/Kconfig.debug                        |  14 +
>   mm/Makefile                             |   1 +
>   mm/arch_pgtable_test.c                  | 429 +++++++++++++++++++++++=
+
>   mm/hugetlb.c                            |  24 +-
>   6 files changed, 477 insertions(+), 2 deletions(-)
>   create mode 100644 mm/arch_pgtable_test.c
>=20

