Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DCAEC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:18:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F40B206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:18:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F40B206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE7E28E0003; Wed, 31 Jul 2019 07:18:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B97BA8E0001; Wed, 31 Jul 2019 07:18:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5FFF8E0003; Wed, 31 Jul 2019 07:18:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5913E8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:18:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so42219737eda.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:18:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oMnAafuh4oSRldvNB1ItZoOCzo30/wE1I/uPbtdCz7I=;
        b=mTg/CmVv63irev/nKgFmGjrwh4Uq/dgxiAeV0KE3Oq5Vbk7v1KtKP7b0HnmuEwUvQg
         5PtMeu2mSHiDTTxq2NZJW4FSYuhoJh3gYI0GfcS0+UQ4nG3ta6svR5vQuDWsUd/YdumK
         freJprRh8BsGTrkyHsFxSzv6USf1nwhHFlZl0jzRm6/9w/PsP5sUS1M9QzfRoiNFlSkt
         k+bUAIkorYRhVNPqWXvRsSvQu503d+ICltc/X7yGkoqe2gq8cXZwZrcxYfTDdINAP1su
         0VmtnpCZ4nRjG2Fwx2ZU+ei4kXqmw5MnSzmHNo0jG09QSOxYgdG/YE9kPJ4pobhcnFFy
         uxkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVvyW9cjcVZ6M7/b1Ma2YXPuIaaTFxQKk9T3Xf2xTS3yG7DMWHs
	dbrkcW1Qe6guoAXZFeYwDRfDQFynv5lh+hLajPxNX/PqKss2sE/gSgmgevjhoyWoEVpPgU4P67t
	APD0nxjSy5SqVGRlSI6eft1ZpT1qUlMNcj2eWNcIo7uS+OC0VWnLsC7o7T3P/rELzTw==
X-Received: by 2002:a17:906:4894:: with SMTP id v20mr90935864ejq.120.1564571920878;
        Wed, 31 Jul 2019 04:18:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgO9YVUovnf1BNRGAtnvnNELHko62DmqxKeO2mLzBO8GVQeGo/VC9AOp+fn4V+HbbH6cpJ
X-Received: by 2002:a17:906:4894:: with SMTP id v20mr90935796ejq.120.1564571919858;
        Wed, 31 Jul 2019 04:18:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564571919; cv=none;
        d=google.com; s=arc-20160816;
        b=Hbi684dUj1KkpJlgc1moBA08sEUJAghFjaqhgknmnGp8kgIYEylBAmx0TiK/1syUDn
         HWoGW1gYtwqSO/6B4+khl/2ZcgVSWJ2Du8nkt8u4c+xeaSn0uHWFyKnTGAsnqBnCAmG9
         AWY3gjVlu/fCHADUU9meV3LhAQeS3gURnZ1pjbzVcGPrvt4TwGMYKuAbk+Mw+1U1eaTk
         dLjP5JOFo6RmUIH9BQ+My6k6orr2jKcg3Iy3+r3MBarsydsmtLy2bS6ru5pkX0Hvq6DH
         rGPezAmBaz5m7KYYJHY2EBhnsXDnKmFZLPB516XmrrGJFIPbzaLjHR6rFSuebGr7Otcs
         11Sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=oMnAafuh4oSRldvNB1ItZoOCzo30/wE1I/uPbtdCz7I=;
        b=Y5IRqldQyOrCXrQlu//sk7NcZUWSWrQ3HbFn4wpWHBhQNeYcI3kkRVMah+uvehvBKd
         pPbQARA+HCAX/tAQtQcjXBpNYoSQ1O4amPN3Cb4uAxLP5+laIfL8XtOGHfLoXJwX225l
         NXXUhGHSBWsBaJlz8cYonhe2EVoSBknm1mZ/1dNOjWq6iK9suuDcU9jKhc3RcmJPUXUe
         THo8l37Lsg7PG4F4HtzeC0n0waeEPk9fyIgOg1dbNAflw1DLilkofprBLnK5samDR11G
         LbXkVfkBvJoAiRW9HbDik09HjkgMCytzpY+5wrobxNbZXp4fl5OOJ2s74iZ3OMjHWq60
         mxew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g23si18648109eje.302.2019.07.31.04.18.39
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 04:18:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CC0CD344;
	Wed, 31 Jul 2019 04:18:38 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 23D7D3F71F;
	Wed, 31 Jul 2019 04:18:36 -0700 (PDT)
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Sven Schnelle <svens@stackframe.org>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Peter Zijlstra
 <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org,
 "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will@kernel.org>,
 "Liang, Kan" <kan.liang@linux.intel.com>, Helge Deller <deller@gmx.de>,
 x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann
 <arnd@arndb.de>, Anshuman Khandual <anshuman.khandual@arm.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org,
 James Morse <james.morse@arm.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190722154210.42799-1-steven.price@arm.com>
 <794fb469-00c8-af10-92a8-cb7c0c83378b@arm.com>
 <270ce719-49f9-7c61-8b25-bc9548a2f478@arm.com>
 <20190731092703.GA31316@t470p.stackframe.org>
From: Steven Price <steven.price@arm.com>
Message-ID: <788180f7-88ae-c88d-1531-68febb462010@arm.com>
Date: Wed, 31 Jul 2019 12:18:34 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190731092703.GA31316@t470p.stackframe.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31/07/2019 10:27, Sven Schnelle wrote:
> Hi Steven,
> 
> On Mon, Jul 29, 2019 at 12:32:25PM +0100, Steven Price wrote:
>>
>> parisc is more interesting and I'm not sure if this is necessarily
>> correct. I originally proposed a patch with the line "For parisc, we
>> don't support large pages, so add stubs returning 0" which got Acked by
>> Helge Deller. However going back to look at that again I see there was a
>> follow up thread[2] which possibly suggests I was wrong?
> 
> I just started a week ago implementing ptdump for PA-RISC. Didn't notice that
> you're working on making it generic, which is nice. I'll adjust my code
> to use the infrastructure you're currently developing.

Great, hopefully it will make it easier to implement.

>> Can anyone shed some light on whether parisc does support leaf entries
>> of the page table tree at a higher than the normal depth?
>>
>> [1] https://lkml.org/lkml/2019/2/27/572
>> [2] https://lkml.org/lkml/2019/3/5/610
> 
> My understanding is that PA-RISC only has leaf entries on PTE level.

Yes, that's my current interpretation.

>> The intention is that the page table walker would be available for all
>> architectures so that it can be used in any generic code - PTDUMP simply
>> seemed like a good place to start.
>>
>>> Now that pmd_leaf() and pud_leaf() are getting used in walk_page_range() these
>>> functions need to be defined on all arch irrespective if they use PTDUMP or not
>>> or otherwise just define it for archs which need them now for sure i.e x86 and
>>> arm64 (which are moving to new generic PTDUMP framework). Other archs can
>>> implement these later.
> 
> I'll take care of the PA-RISC part - for 32 bit your generic code works, for 64Bit
> i need to learn a bit more about the following hack:
> 
> arch/parisc/include/asm/pgalloc.h:15
> /* Allocate the top level pgd (page directory)
>  *
>  * Here (for 64 bit kernels) we implement a Hybrid L2/L3 scheme: we
>  * allocate the first pmd adjacent to the pgd.  This means that we can
>  * subtract a constant offset to get to it.  The pmd and pgd sizes are
>  * arranged so that a single pmd covers 4GB (giving a full 64-bit
>  * process access to 8TB) so our lookups are effectively L2 for the
>  * first 4GB of the kernel (i.e. for all ILP32 processes and all the
>  * kernel for machines with under 4GB of memory)
>  */

As far as I understand this, the page table tree isn't any different
here. It's just that there's a PMD which is allocated at the same time
as the PGD. The PGD's first entry then points to the PMD (P4D/PUD are
folded). There are then some tricks which means that for addresses < 4GB
the PGD stage can be skipped because you already know where the relevant
PMD is.

However, nothing should stop a simple walk from PGD down - it's just an
optimisation to remove the pointer fetch from PGD in the usual case for
accesses < 4GB.

> I see that your change clear P?D entries when p?d_bad() returns true, which - i think -
> would be the case with the PA-RISC implementation.

The only case where p?d_bad() is checked is at the PGD and P4D levels
(unless I'm missing something?). I have to admit I'm a little unsure
about this. Basically the code as it stands doesn't allow leaf entries
at PGD or P4D. I'm not aware of any architectures that do this though.

Thanks,

Steve

