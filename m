Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DFEBC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 05:55:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49BD8208CA
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 05:55:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49BD8208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB1716B0005; Tue, 14 May 2019 01:55:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D60ED6B0007; Tue, 14 May 2019 01:55:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C51326B0008; Tue, 14 May 2019 01:55:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78AE36B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 01:55:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5so21675634edz.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 22:55:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=O8I7afRqoTPOvTxOpi6wNmqGKYucHXkC9um24mV1vhA=;
        b=l9Ao8gDVAW/eZEEq9cZcG9qh08NSGbFybskaHJse8DWElq8rdfMi7VHHW9RsthTXoi
         RLGe1hiN03Yv4+nAh9sJO50SZjhPD7nyu4uuQlQulIoMWNCa3pEJ9NqEtepFpBmDZDwy
         KqfGtAWnGtfRliApmJJDDTEQYOUQnfW7h7QAlnjXIxCPLiabmW5amR2kJsQApu3vrwO5
         97kOH7rLAwlazibXEHhXandljsVNYspjALzJtUqHq/b/wVTifNIBxTfvIx+1q5MzjMRF
         yHd80S+oeCLIyZWm8020TGMp4mE5HVNd6kV0aiAd679i241YfS7/+xstksiIr0Py2ZXz
         rGFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVTwpDz0GflCsFiVL0f8vNfMoLiKcp7ITMYdbEPdWJ2zFS4l8pb
	YGQ2evNP4J7ioFZyG8NqM3vqiezlIacG68NmLcZ0kkutbG42K89O2KMQPzrhk7Z+UtVUlHT5UEY
	d4FhD7B79RmSpZmWiHHa09vldcxSFGHOgo+XD6UCjXvWBS26jSGOGb20oZ/vkvVCJrA==
X-Received: by 2002:a50:cb4d:: with SMTP id h13mr34571683edi.110.1557813355081;
        Mon, 13 May 2019 22:55:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLPYuFKCjBF/EZCElD7JEjXW+wm/gphWXGKLYg+o+vtBzISxES7eODggEoFdqjgvX3wM7a
X-Received: by 2002:a50:cb4d:: with SMTP id h13mr34571619edi.110.1557813354165;
        Mon, 13 May 2019 22:55:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557813354; cv=none;
        d=google.com; s=arc-20160816;
        b=wK50jB9sD5eqZrxXEtAsqjpiIVPLBANpRNCc/eUQNMfW2CssgncewXIT812Kqn+eSx
         Xt3WZTPCzIlobkd8giAibJUCnoOp4TGTd+z6OHex+kb249snAahwr/yr5ecYOX2pPgi8
         9t7U21ZNkEg3PZJ7xojzTmuBXdBHY/iw7MbheDPKd8ZY66GAu3yvYVk1rK8MRegmnukb
         tinwL5CZ6hWAxKclU+o2KkakUMfWEJPNHNqHT3CT10jQ9B98WN3tME39+uBGCOdNWHy3
         lx9IQlcIr4HgHWrQA4S6sj/Mcktf9GYY1c/pC/MQQC/J6mbKooWaUHMkNzMNNXmHtEqg
         CmFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=O8I7afRqoTPOvTxOpi6wNmqGKYucHXkC9um24mV1vhA=;
        b=Vhii6XTqqUwK74o+4nHXOPM18M+2tk08kiciqollb57K9oMjbtTY9QmczzE3LR5UVe
         80kNUVuPGeuxEZTtgXIg2vOiSNtzmu5Mqu9+CfSRn+qflVI/YAJpLf1aOsx0JUF5ji37
         y10w2OayBkzbIxWgQCifTDlFZofrtDxA+7O+z8I4eONYAZ/d6kaZmQlL6pbTqA4xFfG3
         OyXrqae11DmqVi6Ia489bhgIfTip9qOyluSEVhDleGCUMF8wzH3txkiGTeDQl4uApD75
         gB3JQftitlj1jcvAScRon/Zno34OXHykVOi2d6KzwyD36RVF6tmZlyVaP6dhEngH3nF/
         NVRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t49si4570327edd.121.2019.05.13.22.55.53
        for <linux-mm@kvack.org>;
        Mon, 13 May 2019 22:55:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D4DF880D;
	Mon, 13 May 2019 22:55:52 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C1BDE3F703;
	Mon, 13 May 2019 22:55:49 -0700 (PDT)
Subject: Re: [PATCH V3 1/2] mm/ioremap: Check virtual address alignment while
 creating huge mappings
To: "Kani, Toshi" <toshi.kani@hpe.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
 "cpandya@codeaurora.org" <cpandya@codeaurora.org>,
 "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "will.deacon@arm.com" <will.deacon@arm.com>
References: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
 <1557377177-20695-2-git-send-email-anshuman.khandual@arm.com>
 <f56ab0da9e9f20a7c4c019e629052d0e1aa2ffff.camel@hpe.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a893db51-c89a-b061-d308-2a3a1f6cc0eb@arm.com>
Date: Tue, 14 May 2019 11:25:59 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <f56ab0da9e9f20a7c4c019e629052d0e1aa2ffff.camel@hpe.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/14/2019 03:56 AM, Kani, Toshi wrote:
> On Thu, 2019-05-09 at 10:16 +0530, Anshuman Khandual wrote:
>> Virtual address alignment is essential in ensuring correct clearing for all
>> intermediate level pgtable entries and freeing associated pgtable pages. An
>> unaligned address can end up randomly freeing pgtable page that potentially
>> still contains valid mappings. Hence also check it's alignment along with
>> existing phys_addr check.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> Cc: Toshi Kani <toshi.kani@hpe.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Chintan Pandya <cpandya@codeaurora.org>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> ---
>>  lib/ioremap.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/lib/ioremap.c b/lib/ioremap.c
>> index 063213685563..8b5c8dda857d 100644
>> --- a/lib/ioremap.c
>> +++ b/lib/ioremap.c
>> @@ -86,6 +86,9 @@ static int ioremap_try_huge_pmd(pmd_t *pmd, unsigned long addr,
>>  	if ((end - addr) != PMD_SIZE)
>>  		return 0;
>>  
>> +	if (!IS_ALIGNED(addr, PMD_SIZE))
>> +		return 0;
>> +
>>  	if (!IS_ALIGNED(phys_addr, PMD_SIZE))
>>  		return 0;
>>  
>> @@ -126,6 +129,9 @@ static int ioremap_try_huge_pud(pud_t *pud, unsigned long addr,
>>  	if ((end - addr) != PUD_SIZE)
>>  		return 0;
>>  
>> +	if (!IS_ALIGNED(addr, PUD_SIZE))
>> +		return 0;
>> +
>>  	if (!IS_ALIGNED(phys_addr, PUD_SIZE))
>>  		return 0;
> 
> Not sure if we have such case today, but I agree that it is prudent to
> have such checks.  Is there any reason not to add this check to p4d for
> consistency?

No, will add it.

