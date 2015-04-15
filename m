Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id A25FB6B0038
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 22:37:17 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so55772231igb.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 19:37:17 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id f15si2674956ioi.55.2015.04.14.19.37.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 19:37:16 -0700 (PDT)
Message-ID: <552DCED9.40207@codeaurora.org>
Date: Tue, 14 Apr 2015 19:37:13 -0700
From: David Keitel <dkeitel@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] arm64: add KASan support
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com> <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com> <20150401122843.GA28616@e104818-lin.cambridge.arm.com> <551E993E.5060801@samsung.com>
In-Reply-To: <551E993E.5060801@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

>>> +	pgd = __pgd(__pa(kasan_zero_pmd) | PAGE_KERNEL);
>>> +#else
>>> +	pgd = __pgd(__pa(kasan_zero_pte) | PAGE_KERNEL);
>>> +#endif
>>> +
>>> +	for (i = pgd_index(start); start < end; i++) {
>>> +		set_pgd(&pgdp[i], pgd);
>>> +		start += PGDIR_SIZE;
>>> +	}
>>> +}
>>
>> Same problem as above with PAGE_KERNEL. You should just use
>> pgd_populate().

Any suggestion what the correct flag setting would be here for a 4K mapping?

I tried fixing this by changing this to pud and setting the PMD_TYPE_TABLE flag for kasan_zero_pmd. However the MMU doesn't like it and I get a first level address translation fault.

If you have any updated patches to share I'd be glad to try them out.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
