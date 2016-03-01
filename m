Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0918B6B0256
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 10:43:47 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id y8so22998446igp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 07:43:47 -0800 (PST)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id m23si29019929iod.142.2016.03.01.07.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 07:43:46 -0800 (PST)
Received: by mail-io0-x230.google.com with SMTP id l127so226537123iof.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 07:43:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160301153957.GA22107@localhost.localdomain>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
	<1456757084-1078-6-git-send-email-ard.biesheuvel@linaro.org>
	<20160301153957.GA22107@localhost.localdomain>
Date: Tue, 1 Mar 2016 16:43:46 +0100
Message-ID: <CAKv+Gu9q-Z2mXtvPQUA2du_VhAwLGp04-5E8cGtyk1zVbGjZEA@mail.gmail.com>
Subject: Re: [PATCH v2 5/9] arm64: mm: move vmemmap region right below the
 linear region
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Jonas Bonn <jonas@southpole.se>, "linux-mm@kvack.org" <linux-mm@kvack.org>, nios2-dev@lists.rocketboards.org, linux@lists.openrisc.net, lftan@altera.com, Andrew Morton <akpm@linux-foundation.org>

On 1 March 2016 at 16:39, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Mon, Feb 29, 2016 at 03:44:40PM +0100, Ard Biesheuvel wrote:
>> @@ -404,6 +404,12 @@ void __init mem_init(void)
>>       BUILD_BUG_ON(TASK_SIZE_32                       > TASK_SIZE_64);
>>  #endif
>>
>> +     /*
>> +      * Make sure we chose the upper bound of sizeof(struct page)
>> +      * correctly.
>> +      */
>> +     BUILD_BUG_ON(sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT));
>
> Since with the vmemmap fix you already assume that PAGE_OFFSET is half
> of the VA space, we should add another check on PAGE_OFFSET !=
> UL(0xffffffffffffffff) << (VA_BITS - 1), just in case someone thinks
> they could map a bit of extra RAM without going for a larger VA.
>

Indeed. The __pa() check only checks a single bit, so it must be split
exactly in half, unless we want to revisit that in the future (if
__pa() is no longer on a hot path after changes like these).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
