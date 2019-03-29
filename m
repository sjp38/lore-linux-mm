Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67FB2C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:08:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19A9C2184D
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:08:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Eb5dQL4J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19A9C2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF08A6B000D; Fri, 29 Mar 2019 14:08:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A774F6B000E; Fri, 29 Mar 2019 14:08:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 941036B0010; Fri, 29 Mar 2019 14:08:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 564AE6B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:08:07 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v76so941407pfa.18
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:08:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=H/PoRPC1lktHX4182NbmlBZcudeaZE+Xbszx/F65dUQ=;
        b=ewa+PGz7nFMyQdxuYyYCnWRZvkIl6MHCqZOcSB1tExZ1y9ZlaOlX3lHVSrtOH347n4
         dm1QpJ34X9SAfTm2g2Dggx37D4JA5Xvqje/njAySRdyLPYK+MKrCPoyATTcjOdN/2Kwl
         qA50RCr1on3XO9AQNjKA38Pkyo8FjlPlyTBMdi28vCC7RXl/8qMMh+NHMlMrZ2HinjXu
         HJBCxjKHyyviAsvP0M3wR+gTtRR2AQXe506GaHFvNST/s64fh8qiJ3Czxa6zD+kuInNK
         ONQTl8x6OdwqUkn8TkIP7FqXqLjSm4DaCCONTdJibJ+B62PQO8B2ShKXbxd3IyklJU0e
         XCOg==
X-Gm-Message-State: APjAAAXCYK8bE02LnOESK0R0+96U410Kbb8tg+st6Td3gUtpWs82qd9a
	MbOqUvAJVXPqMn0VoVS1HdWdpiBKzbzjuAllT1ujVZ4LkRRpBY7zGtyM25UKWALBsA31gAaeYK1
	pEMetUjKI6crOXZvkaQlQZoa3p/d3/r2peQfBDFb5zg8lbMzKQjMUlROWAKG1r+S0VA==
X-Received: by 2002:a62:b602:: with SMTP id j2mr35401462pff.68.1553882886957;
        Fri, 29 Mar 2019 11:08:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd+1PtlOCHvaGXrcw2iG1HnJAiG+8tQTTTl6zob2llTjCIeVKxvTV790yucn38A/vvcrAo
X-Received: by 2002:a62:b602:: with SMTP id j2mr35401402pff.68.1553882886269;
        Fri, 29 Mar 2019 11:08:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553882886; cv=none;
        d=google.com; s=arc-20160816;
        b=d27zp1SNI3UZqg4oXa4m2QrBE48GHeshvT+ZLTcj678PuP7aBuflH4HSBgv9uuB2E5
         EDNEMShLSJPh1jko+d+0sG3cF+lqJ+LVXCbzwl0biUiTEBW2QcvUJdmCmHM39dSw4p2G
         RaDUn3V6INMhrHd4Fip5YR9d59puNUVw7k4FefSN2YocgqCn3wvaN9jDo5IVeRXf/s7N
         8I6z+2JXwsbS0WQA7fAxFuvwzXKHN3tjNdi6gzOWLOU0n81Ujd5qg6knhG4DvOSi2WjA
         GyUa1cUle/pGH92E6PLyr3weSpAduqC+a+nLacegvk7GQ8AIOfDoTT82fmx3vCkJfMOc
         h9kQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=H/PoRPC1lktHX4182NbmlBZcudeaZE+Xbszx/F65dUQ=;
        b=jwp4k2sAjekmYgGelmLz7O7pMmL4ZsCI4kayBL2xA4xFPR95nnBSAdrS2Q459sYrB3
         ayuiNZy6BLoGBtwLRCVeJtV/ogBCM7CE+D1X//dqJX35Wk50XGIkHnAT60zwuSI0Qn8U
         MkQd1DK8c2UpadRQ6O5i0LC/VfEEFhH7be43wpz+WF17kfnbbJS3Ntcerx+TSnAaH2KI
         uo2K0yMkxj8Yg26w0JkV51youtOcQhMRfUHRmjN71+GWIRg6s1w64EOoiqzVDVlrBPLg
         YFTPwAdBTLsakb82xlH/+nCaO0SMNBsPlA+xXFm1y1NW0HqmiVgvmIOWYpMNlN3vKz5N
         JMWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Eb5dQL4J;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i1si2334226pgq.528.2019.03.29.11.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 11:08:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Eb5dQL4J;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:References:Cc:To:From:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=H/PoRPC1lktHX4182NbmlBZcudeaZE+Xbszx/F65dUQ=; b=Eb5dQL4JNedsk9Xw6+iVOelqg
	eAnX8G1j+knYyrWzdWqSBa0WC7UkL62NxgXrXRCxezJ/XVF3WBGkj2Jm3aBy1/siPPi4ODJXvNHtn
	H0XArkbXYD3erwTNkhmzqMx2Huh+w+Vs94UjwrkEUjLqSH/+ievYFVSx6sqQll8gADaj+u4tM3LjY
	+FWXe8Z8iz1iJC6a/lBciM8KlvebP1i2LuXY0wisohrUVNkVUn3TjT3yFKNzduTuwSUpuNxUae7QM
	wH7evI68tOlFuqDsktUVB1Ewf/1en7L33J+jkvA39/cBhBhy/zsShGUqDQVFxKG9jN5ogl2zMF/NP
	QYTWg9yFg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9vvA-0001Nd-FU; Fri, 29 Mar 2019 18:08:04 +0000
Subject: Re: [PATCH] gcov: include linux/module.h for within_module
From: Randy Dunlap <rdunlap@infradead.org>
To: Nick Desaulniers <ndesaulniers@google.com>, oberpar@linux.ibm.com,
 akpm@linux-foundation.org
Cc: Greg Hackmann <ghackmann@android.com>, Tri Vo <trong@android.com>,
 linux-mm@kvack.org, kbuild-all@01.org, kbuild test robot <lkp@intel.com>,
 linux-kernel@vger.kernel.org
References: <201903291603.7podsjD7%lkp@intel.com>
 <20190329174541.79972-1-ndesaulniers@google.com>
 <9f1ad3e1-fad7-2fb4-31c0-d31832468143@infradead.org>
Message-ID: <16a9f1b8-f937-7350-968e-36c5b3f838a5@infradead.org>
Date: Fri, 29 Mar 2019 11:08:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <9f1ad3e1-fad7-2fb4-31c0-d31832468143@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/29/19 11:01 AM, Randy Dunlap wrote:
> On 3/29/19 10:45 AM, Nick Desaulniers wrote:
>> Fixes commit 8c3d220cb6b5 ("gcov: clang support")
>>
>> Cc: Greg Hackmann <ghackmann@android.com>
>> Cc: Tri Vo <trong@android.com>
>> Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
>> Cc: linux-mm@kvack.org
>> Cc: kbuild-all@01.org
>> Reported-by: kbuild test robot <lkp@intel.com>
>> Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
>> Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> see https://lore.kernel.org/linux-mm/20190328225107.ULwYw%25akpm@linux-foundation.org/T/#mee26c00158574326e807480fc39dfcbd7bebd5fd
> 
> Did you test this?  kernel/gcov/gcc_4_7.c includes local "gcov.h",
> which includes <linux/module.h>, so why didn't that work or why
> does this patch work?

No, this patch does not fix the build error for me.

> thanks.
> 
>> ---
>>  kernel/gcov/gcc_3_4.c | 1 +
>>  kernel/gcov/gcc_4_7.c | 1 +
>>  2 files changed, 2 insertions(+)
>>
>> diff --git a/kernel/gcov/gcc_3_4.c b/kernel/gcov/gcc_3_4.c
>> index 801ee4b0b969..0eda59ef57df 100644
>> --- a/kernel/gcov/gcc_3_4.c
>> +++ b/kernel/gcov/gcc_3_4.c
>> @@ -16,6 +16,7 @@
>>   */
>>  
>>  #include <linux/errno.h>
>> +#include <linux/module.h>
>>  #include <linux/slab.h>
>>  #include <linux/string.h>
>>  #include <linux/seq_file.h>
>> diff --git a/kernel/gcov/gcc_4_7.c b/kernel/gcov/gcc_4_7.c
>> index ec37563674d6..677851284fe2 100644
>> --- a/kernel/gcov/gcc_4_7.c
>> +++ b/kernel/gcov/gcc_4_7.c
>> @@ -13,6 +13,7 @@
>>   */
>>  
>>  #include <linux/errno.h>
>> +#include <linux/module.h>
>>  #include <linux/slab.h>
>>  #include <linux/string.h>
>>  #include <linux/seq_file.h>
>>
> 
> 


-- 
~Randy

