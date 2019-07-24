Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A24BDC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:53:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 654D521926
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:53:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 654D521926
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE2A38E0003; Wed, 24 Jul 2019 09:53:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E92388E0002; Wed, 24 Jul 2019 09:53:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D82678E0003; Wed, 24 Jul 2019 09:53:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC3C8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:53:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so30306637edb.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 06:53:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=K/NGaHNDTuxqRsiTxNWxXdgbnrjQ2IFjoWSMvqmkJ1s=;
        b=oITbLPpo2VV/nA3nB71UGjE3bUL1XfdybCdoeyXSlB5zTqtsbobiskWm6zO1ZOOc3I
         DRFMI+7RBTEhzHgQPduzcQEFG+dsWrg3TrJgbQXlQYRLXwWPe0hHV69+GpQdMch/TnyN
         Ov7+0KCKEEGVtyugx/tboczKLE8nqlFA3pqd4xt2DmvGUTNSt1A1OdpSX1iTjjehNK7N
         xcrKl3n8/vrQRcHcjiyPortb2Vtw5v11d1mHms/a+ZtAkvYdoPCQGDISf3KqPjAoqXlu
         pn80/u0h/k4mGpwdOC2W0Evsp2Ggruz7FwC2qPem+vWFOz8wbK14ahKxxgRLlqF8RErw
         xYHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXAql5pYw5UjcJfRiFMAVDxES1ilmrPSsqo0lgZ2AJQpdweGAGx
	WumqWlvzk/j5D0YZfaCglTh0GH5FWp3GcRx1ALbh+t2xoHLeXP1nOOMRF0GWLQFaKeRhUVlRsBZ
	4Th7DiqehMdYo2ncJo54YGzI3w0xA7P+3k/R+OBCvxFouLKUjyYnyq3hdnK15VfANnQ==
X-Received: by 2002:a05:6402:1707:: with SMTP id y7mr70257740edu.223.1563976390121;
        Wed, 24 Jul 2019 06:53:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCT4zAl7Dx23SZeQRJxgcWPzvnVd6i73WhB4/gU0/5o96hcHG5l/pK74XvpTFBcSdw9GbF
X-Received: by 2002:a05:6402:1707:: with SMTP id y7mr70257684edu.223.1563976389409;
        Wed, 24 Jul 2019 06:53:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563976389; cv=none;
        d=google.com; s=arc-20160816;
        b=amMa+GXEa6k1jhEUGYt5zt5LSwvxvYJxwiyekg50R5DZAKTrSkxN7stA0dOIXjLuJi
         +kzLHj4egd4sF7alqASmKWatpfHSj2u7uXWGCrKPRoJGRfWx8EgD3d7Rmeamu/2XBcgs
         HWFh5CaCV1YCHlhkFB4DsPPFHZ0m3JK6MijOmpiL96rOzanBcakZIZHWl1zSl67r1rLi
         H4OzO+p8uIQhXJT4TrwAi5TDpioLlaQWOtp3wEj4UZHJlEhFdLfEztJNbH6EXfucN8mV
         hiFQsgpOK8U/RBcjFL1B8Awmz+BGp8wFg6IRbs7ndWopEXV9DDGSCar4EPaWUO8Y2Lt0
         Xbww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=K/NGaHNDTuxqRsiTxNWxXdgbnrjQ2IFjoWSMvqmkJ1s=;
        b=GSXbwGScLEewVs5pTifqbayPWI0xTObscmdysbK85XTYVK/NcNBY+SooHyI85dNE1u
         H2os27CCvY/jjksupdioK/QLCGvQGaHBcgCtUR9R7BWcVwM/URNbtX3Zvq/408Rv5x07
         9G3xejuhDvnJddpuLN2QBbNFAoJhCiMnsRuHTbM453eyJdT0CiOeGt4IIJUxlx1TypKv
         v7QUqsiLlGuFyKvxcnyLNGd6+Y5VOj7ZOG9fkIHYMa921YG9alagbUVrSeidxfAwWRfr
         cVrYbu2CfR6pyaHwK3P7jkG2wr/U8ITNbqCGxKIVPYBwwvvwm44SuUKV9L8TOz1RkAp+
         HSNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 7si8943243ejx.290.2019.07.24.06.53.09
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 06:53:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6F72D28;
	Wed, 24 Jul 2019 06:53:08 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 996793F71A;
	Wed, 24 Jul 2019 06:53:05 -0700 (PDT)
Subject: Re: [PATCH v9 11/21] mm: pagewalk: Add p4d_entry() and pgd_entry()
To: Mark Rutland <mark.rutland@arm.com>
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-12-steven.price@arm.com>
 <20190723101432.GC8085@lakrids.cambridge.arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <60ee20ef-62a3-5df1-6e24-24973b69be70@arm.com>
Date: Wed, 24 Jul 2019 14:53:04 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723101432.GC8085@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23/07/2019 11:14, Mark Rutland wrote:
> On Mon, Jul 22, 2019 at 04:42:00PM +0100, Steven Price wrote:
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
> 
> How are these expected to work with folding?
> 
> For example, on arm64 with 64K pages and 42-bit VA, you can have 2-level
> tables where the PGD is P4D, PUD, and PMD. IIUC we'd invoke the
> callbacks for each of those levels where we found an entry in the pgd.
> 
> Either the callee handle that, or we should inhibit the callbacks when
> levels are folded, and I think that needs to be explcitly stated either
> way.
> 
> IIRC on x86 the p4d folding is dynamic depending on whether the HW
> supports 5-level page tables. Maybe that implies the callee has to
> handle that.

Yes, my assumption is that it has to be up to the callee to handle that
because folding can be dynamic. I believe this also was how these
callbacks work before they were removed. However I'll add a comment
explaining that here as it's probably non-obvious.

Steve

