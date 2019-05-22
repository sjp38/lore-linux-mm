Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BEA5C072B5
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 01:01:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 597462070D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 01:01:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 597462070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB4EE6B0003; Tue, 21 May 2019 21:01:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C65856B0006; Tue, 21 May 2019 21:01:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B53E46B0007; Tue, 21 May 2019 21:01:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C88D6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 21:01:04 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b5so284726plr.16
        for <linux-mm@kvack.org>; Tue, 21 May 2019 18:01:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=tMJyJWRJeS+wduhjqIEr/53WBgZzmYc8fDCjlf8nlWM=;
        b=hRtGI/jiU0u7vFYmUm1ZYO2T1Z75NGCHKBoHFmw9gZqKEQn3hLDptlfiyojkIUH3Q0
         H0CBsPvSqVrrNeqGg8O3fn8cWv/XhXA1PZFMpy5cPfFATwgk48b9Ix6gNDb5yQSuuzgd
         +iU4j3Nwq4UqEBilcc1VaNABqeofy6xikdUwD5QA66Z3C02AiXyPX8ZNmH/JJy3o0uJQ
         BS0+MGioB6u3PElbzKELGIF8jFA7BRvSptdE0+RcM1bW7wFB/W8eUS9eCvOURp4WMQAs
         2oiv62915gg8vIxB96QCLI7iau/nszF/+bmvF1a5T/o8NDINzlch8mhxSDd9iTaSqD87
         S+Vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX8qOVN1/KvXI1AhB8QM6ic+3YahHEflRZs5EQPQ8YPphco2RmQ
	n6RnRhIt2u2mouszLcJDPhUFxzhYO0dc7GDaz/3PdBlTgGtNY4NcynW6qloQHwdkKuMGlHklTb6
	dfcJMTuI/m9TDsVUQbrne2+QJ0l0YqlYMWmiAoBhAkaV5dx0n8uxXPgCdF0AnFsnh/A==
X-Received: by 2002:a62:ee05:: with SMTP id e5mr89996908pfi.117.1558486864126;
        Tue, 21 May 2019 18:01:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySpOC818mnHDF+7Kc6v6a8OdBUN6q7dLwI3wtDEN0z4vvBY5WOr//TsKb45KJMzqWHyKMd
X-Received: by 2002:a62:ee05:: with SMTP id e5mr89996791pfi.117.1558486863164;
        Tue, 21 May 2019 18:01:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558486863; cv=none;
        d=google.com; s=arc-20160816;
        b=BmeBCgXSNVVVTv4tASozaF8FT8bVmhPUu88kFBxr52ndspvHkSoLibw1m9m9b+jqE1
         XZmsOpwDN3woPtHxnXzn7xLOrMuHigMCd3MkkUmAuvK7VHho4SIQIhRbyTDLgOPTpiKP
         SXo8q4WTiB7RWuonkVJa2FXKGI5yUDMOkhDgSAxzIZ71kbVrInCfWLLw9FsWrRmQmGEo
         YWvFqfgZhtHxYS5XszokioUHStrZBqajA2CT7GEiDqw+4eSfWyY/HiFPrniTJkad/4vI
         HgaTy5wJEurC4RZqnkvNfeOLMJ9KetJY1lgVt/OwN9MSAHxBffKLHRmgUwa7CNcLOe1U
         fduQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=tMJyJWRJeS+wduhjqIEr/53WBgZzmYc8fDCjlf8nlWM=;
        b=TT+kvB7KnVRBU1YMZLEysWpeIR8SchciFUYSyEq7eSu0/MjaRwboukg3Ytg7Kcr7kX
         fZsFBKlal8FsD8TfqDHaWxBytw2wHuvzT569PbenCqf5awNd/FYUI9ue0F07unK4wSfF
         Xpapi2OeQcD9KSGYqqBLOb6gKAGIsgSPQWO11kbis4WKAZIEZniDVPvVQeR2urhLhn++
         br6FJwrgC6gkeyE4Ro8xuEEEiITrOmYvgQH7MM1CukUT2N0lPCngolNE2L81wWPkSypI
         xGPSBgUEHeukP/lxU1uHloSumOvC/omjR1dpFGaakE7fQELuB2MVBXVc1B+4+ZPCML7S
         BEfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id t20si23812125pfh.238.2019.05.21.18.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 18:01:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R611e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSLG0uI_1558486838;
Received: from 192.168.1.105(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSLG0uI_1558486838)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 22 May 2019 09:00:47 +0800
Subject: Re: [v3 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
To: Andrew Morton <akpm@linux-foundation.org>
Cc: jstancek@redhat.com, peterz@infradead.org, will.deacon@arm.com,
 npiggin@gmail.com, aneesh.kumar@linux.ibm.com, namit@vmware.com,
 minchan@kernel.org, mgorman@suse.de, stable@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1558322252-113575-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190521161826.029782de0750c8f5cd2e5dd6@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9c27f777-3330-8e43-e4cf-cc4d9c3e0229@linux.alibaba.com>
Date: Wed, 22 May 2019 09:00:34 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190521161826.029782de0750c8f5cd2e5dd6@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/22/19 7:18 AM, Andrew Morton wrote:
> On Mon, 20 May 2019 11:17:32 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> A few new fields were added to mmu_gather to make TLB flush smarter for
>> huge page by telling what level of page table is changed.
>>
>> __tlb_reset_range() is used to reset all these page table state to
>> unchanged, which is called by TLB flush for parallel mapping changes for
>> the same range under non-exclusive lock (i.e. read mmap_sem).  Before
>> commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
>> munmap"), the syscalls (e.g. MADV_DONTNEED, MADV_FREE) which may update
>> PTEs in parallel don't remove page tables.  But, the forementioned
>> commit may do munmap() under read mmap_sem and free page tables.  This
>> may result in program hang on aarch64 reported by Jan Stancek.  The
>> problem could be reproduced by his test program with slightly modified
>> below.
>>
>> ...
>>
>> Use fullmm flush since it yields much better performance on aarch64 and
>> non-fullmm doesn't yields significant difference on x86.
>>
>> The original proposed fix came from Jan Stancek who mainly debugged this
>> issue, I just wrapped up everything together.
> Thanks.  I'll add
>
> Fixes: dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
>
> to this.

Thanks, Andrew.


