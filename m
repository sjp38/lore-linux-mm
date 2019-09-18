Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 621A7C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 07:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31D3C21907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 07:32:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31D3C21907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C998D6B0289; Wed, 18 Sep 2019 03:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C22EA6B028A; Wed, 18 Sep 2019 03:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B10F16B028B; Wed, 18 Sep 2019 03:32:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id 86BE36B0289
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:32:22 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 367A4180AD803
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:32:22 +0000 (UTC)
X-FDA: 75947223324.30.map26_88c5d7b5b5353
X-HE-Tag: map26_88c5d7b5b5353
X-Filterd-Recvd-Size: 3911
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:32:19 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A357528;
	Wed, 18 Sep 2019 00:32:18 -0700 (PDT)
Received: from [10.162.40.136] (p8cg001049571a15.blr.arm.com [10.162.40.136])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 77E5C3F59C;
	Wed, 18 Sep 2019 00:34:39 -0700 (PDT)
Subject: Re: [PATCH] mm/pgtable/debug: Fix test validating architecture page
 table helpers
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
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
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <cb338e2e-23b1-b8af-811c-57feb6f4e7b4@arm.com>
Date: Wed, 18 Sep 2019 13:02:22 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1892b37d1fd9a4ed39e76c4b999b6556077201c0.1568355752.git.christophe.leroy@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/13/2019 11:53 AM, Christophe Leroy wrote:
> Fix build failure on powerpc.
> 
> Fix preemption imbalance.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  mm/arch_pgtable_test.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/arch_pgtable_test.c b/mm/arch_pgtable_test.c
> index 8b4a92756ad8..f2b3c9ec35fa 100644
> --- a/mm/arch_pgtable_test.c
> +++ b/mm/arch_pgtable_test.c
> @@ -24,6 +24,7 @@
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/sched/mm.h>
> +#include <linux/highmem.h>
>  #include <asm/pgalloc.h>
>  #include <asm/pgtable.h>
>  
> @@ -400,6 +401,8 @@ static int __init arch_pgtable_tests_init(void)
>  	p4d_clear_tests(p4dp);
>  	pgd_clear_tests(mm, pgdp);
>  
> +	pte_unmap(ptep);
> +
>  	pmd_populate_tests(mm, pmdp, saved_ptep);
>  	pud_populate_tests(mm, pudp, saved_pmdp);
>  	p4d_populate_tests(mm, p4dp, saved_pudp);
> 

Hello Christophe,

I am planning to fold this fix into the current patch and retain your
Signed-off-by. Are you okay with it ?

- Anshuman

