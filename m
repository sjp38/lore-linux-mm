Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D2DEC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 12:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59192206B8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 12:17:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59192206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D26828E0003; Mon, 29 Jul 2019 08:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6038E0002; Mon, 29 Jul 2019 08:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9E358E0003; Mon, 29 Jul 2019 08:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF3B8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:17:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so38149523eds.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:17:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CXrcaOBj3B23MTenWM0mP3ocey8/kwaMaZd8l0+RWsQ=;
        b=ZZ/NdqbHlXNyATHmTTMXk6S9a5Q/fXr4XK73ZnOoxRUvGLrJunuse2PIg7XB3B4dwP
         HvAJQLHUczym1xev21EITS1MbocsgbvpvMv34H5Er9BVmK5gfcvhDaEJmK+GKIySLUd9
         ltOmlYNvRiwmImC/AwXeQcs94KOzLL8Ns6cxaM0THvebrkKm2KYQ/Eio96oi11y+HH9X
         LnRlIQLbLGB4yQoRgqLgcecvc4AyNo79CLUAWrbNS7mmhIcAjtb9nrp4zazOHOxXOa9X
         OE3yqioKcr3PjTnLxrEUriQ+NTv9QXMeDqPtwVcRTgqaFKUM92dQB74X4NkVnC4X4JKL
         487A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV4zo7+Wrvbky4DMrKCFsFXU1EDuZCPDLe/6V+94JXDSQSHh0mo
	+BOylrANVCMd17Zcq3LhyEPPkN3IeS5NcbswwVzAY7ROd/hyXMXx7rx4YcD+0eKpjSVBfQexCbs
	tfyW85c4L0dVOufOxBMMdro24wjD4pnVHpopl6WneXuFvJ79LagdMnmJZ+rWFUZuKyQ==
X-Received: by 2002:a17:906:4e8f:: with SMTP id v15mr82960878eju.47.1564402667985;
        Mon, 29 Jul 2019 05:17:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzSjkwJdOuneHWBfUP839UP4AU6yn/zvKVAzkW3LXhn9AUpf5nUP6/MiHtmFDthjdZnuTS
X-Received: by 2002:a17:906:4e8f:: with SMTP id v15mr82960809eju.47.1564402666967;
        Mon, 29 Jul 2019 05:17:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564402666; cv=none;
        d=google.com; s=arc-20160816;
        b=YpfXi5yXYuV+I3KeSTBHBaELFnUjuV5gAgWSy2oUQ3ar8GQa1FjsnYBEu5ODlBPeJ4
         XBLLl3O1L5rv8RInJJcNO9/XpJrWibXVaCd5U/mqJAW3WLFLSgh4FjPegwiFJgXyvIRH
         zkn0hXTsT2u+6H8BjzIw4Samxd9lH7sILrkXLpOIJX7TcXNHiyS68S25gWVLF2C/CAQ6
         uCu8hqW/AdnOqqttxxc6urUiHdehEmnSzAsjCDGqcmUi6Ez2ekweVuxAMydMd2ARXs+j
         orySCUKc0JONzmgXR2sRPkPziWImoDQD2cA43TLfoXhzLB/KvS7HJfmP74BlRPnR5FRB
         +BuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=CXrcaOBj3B23MTenWM0mP3ocey8/kwaMaZd8l0+RWsQ=;
        b=UVED7U5nfvrqRhOoNnr7Uu2bys2ANnPa8d/y3sY85RpaoyK/k6rhBeAssnrZw0pBUq
         qoMhLVW1DjITzW1Kp5LUkY9YCnaRBm722ZUWrw3B7ynzC7egvDWbsQOQ36ZtCZEbpgyF
         l3oIx10Yd1S0AxA0NS80iacZX+npOD+M8lA6myHh1cIeDnppPI0pwZccWB003sE+t9U6
         1F2bFz7JzSWQGTPYbtgsqbZWNk3cklhn2Yg7IrivYfE0A4Uq/F0ZkWlRXR8SkWOBm679
         usZZJSk63CY3WA3/UP5pNjjifl3OzTEWfSETlazJCVEzhgddwjDCwShm7pfWWtvdakOl
         0dbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id jp14si15367554ejb.398.2019.07.29.05.17.46
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 05:17:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F232528;
	Mon, 29 Jul 2019 05:17:45 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4EFF93F575;
	Mon, 29 Jul 2019 05:17:43 -0700 (PDT)
Subject: Re: [PATCH v9 11/21] mm: pagewalk: Add p4d_entry() and pgd_entry()
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-12-steven.price@arm.com>
 <b61435a3-0da0-de57-0993-b1fffeca3ca9@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <63a86424-9a8e-4528-5880-138f0009e462@arm.com>
Date: Mon, 29 Jul 2019 13:17:42 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <b61435a3-0da0-de57-0993-b1fffeca3ca9@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/07/2019 13:33, Anshuman Khandual wrote:
> 
> 
> On 07/22/2019 09:12 PM, Steven Price wrote:
>> pgd_entry() and pud_entry() were removed by commit 0b1fbfe50006c410
>> ("mm/pagewalk: remove pgd_entry() and pud_entry()") because there were
>> no users. We're about to add users so reintroduce them, along with
>> p4d_entry() as we now have 5 levels of tables.
>>
>> Note that commit a00cc7d9dd93d66a ("mm, x86: add support for
>> PUD-sized transparent hugepages") already re-added pud_entry() but with
>> different semantics to the other callbacks. Since there have never
>> been upstream users of this, revert the semantics back to match the
>> other callbacks. This means pud_entry() is called for all entries, not
>> just transparent huge pages.
>>
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>  include/linux/mm.h | 15 +++++++++------
>>  mm/pagewalk.c      | 27 ++++++++++++++++-----------
>>  2 files changed, 25 insertions(+), 17 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 0334ca97c584..b22799129128 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1432,15 +1432,14 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>>  
>>  /**
>>   * mm_walk - callbacks for walk_page_range
>> - * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
>> - *	       this handler should only handle pud_trans_huge() puds.
>> - *	       the pmd_entry or pte_entry callbacks will be used for
>> - *	       regular PUDs.
>> - * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
>> + * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
>> + * @p4d_entry: if set, called for each non-empty P4D entry
>> + * @pud_entry: if set, called for each non-empty PUD entry
>> + * @pmd_entry: if set, called for each non-empty PMD entry
>>   *	       this handler is required to be able to handle
>>   *	       pmd_trans_huge() pmds.  They may simply choose to
>>   *	       split_huge_page() instead of handling it explicitly.
>> - * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
>> + * @pte_entry: if set, called for each non-empty PTE (lowest-level) entry
>>   * @pte_hole: if set, called for each hole at all levels
>>   * @hugetlb_entry: if set, called for each hugetlb entry
>>   * @test_walk: caller specific callback function to determine whether
>> @@ -1455,6 +1454,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>>   * (see the comment on walk_page_range() for more details)
>>   */
>>  struct mm_walk {
>> +	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
>> +			 unsigned long next, struct mm_walk *walk);
>> +	int (*p4d_entry)(p4d_t *p4d, unsigned long addr,
>> +			 unsigned long next, struct mm_walk *walk);
>>  	int (*pud_entry)(pud_t *pud, unsigned long addr,
>>  			 unsigned long next, struct mm_walk *walk);
>>  	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
>> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
>> index c3084ff2569d..98373a9f88b8 100644
>> --- a/mm/pagewalk.c
>> +++ b/mm/pagewalk.c
>> @@ -90,15 +90,9 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>>  		}
>>  
>>  		if (walk->pud_entry) {
>> -			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
>> -
>> -			if (ptl) {
>> -				err = walk->pud_entry(pud, addr, next, walk);
>> -				spin_unlock(ptl);
>> -				if (err)
>> -					break;
>> -				continue;
>> -			}
>> +			err = walk->pud_entry(pud, addr, next, walk);
>> +			if (err)
>> +				break;
> 
> But will not this still encounter possible THP entries when walking user
> page tables (valid walk->vma) in which case still needs to get a lock.
> OR will the callback take care of it ?

This is what I mean in the commit message by:
> Since there have never
> been upstream users of this, revert the semantics back to match the
> other callbacks. This means pud_entry() is called for all entries, not
> just transparent huge pages.

So the expectation is that the caller takes care of it.

However, having checked again, it appears that mm/hmm.c now does use
this callback (merged in v5.2-rc1).

Jérôme - are you happy with this change in semantics? It looks like
hmm_vma_walk_pud() should deal gracefully with both normal and large
pages - although I'm unsure whether you are relying on the lock from
pud_trans_huge_lock()?

Thanks,

Steve

