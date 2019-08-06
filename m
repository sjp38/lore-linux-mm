Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FF15C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:31:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41B86206A2
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:31:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41B86206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCCB86B000D; Tue,  6 Aug 2019 04:31:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7D0C6B000E; Tue,  6 Aug 2019 04:31:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A92686B0010; Tue,  6 Aug 2019 04:31:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DBBE6B000D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:31:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c31so53387152ede.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:31:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2o3MEAl09JNQzVuEHRq57iPBSS9omAtfIoIZ2Acqt/c=;
        b=hEfhek1OSznwiYJ4u+bfPiW567MnES0IqDmqXy9Yn07i19QtwiadQb/NJgXzR1rQyK
         EupDG2XZySJFQNVjJK/BbCEcT8UHEAJ62g4R7UtZrMTcMumcS/+UQGy6OIhWm0mKnNlC
         MXh0EMHr2i6Wn0Dn/5hkLRs6EhYo/5V5yQabw25O6X/xrAEV6ZqArCndQBnh3riKvUSv
         nHJYhUMtunMcw4qo3Y45CHJhg1KK/0dUItxxfjnZCQNZtNFfOc4pvX5/lm7x95pB5c9I
         lzI/9h/4nOLRuWYqx14IB8znOfRBsR/auhW36Xg7ks1Vq5xG6tSRIIJk/fNOF1yC3/Tn
         /0NQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU4VoqhnICUDBBlPYTK8F0tOAcwHcaHDbPd8dB5aeAT/eHD9c8Z
	uHnr1X0sT0HwaeDLwPzN3VQ1tSO1p74RUR+rXyr0qBnRW1RphEHkd+B8IniyNatSXYOOQqvGc6l
	bnGwDOnmbrGa59YAxFuBC8X8cZyo3TNhmd9l9K8uxibLRh4pnzAvuUMmuGqQzKUSHcg==
X-Received: by 2002:a50:940b:: with SMTP id p11mr2621446eda.194.1565080306949;
        Tue, 06 Aug 2019 01:31:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQIOLpuKfTNe5sz1MqIRlEZ8rMQqAAvaDgdNeNTy570dllCAB/KiY2CljJsUL+W8e7CeD2
X-Received: by 2002:a50:940b:: with SMTP id p11mr2621409eda.194.1565080306307;
        Tue, 06 Aug 2019 01:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565080306; cv=none;
        d=google.com; s=arc-20160816;
        b=T9g4Z9UdH2Iv11dExrODAaXCzQK5N+6vFiN6n0rtxP2TW+8EnnOilM1H2vv99ecDbK
         YMAjuQfTHgIewp1ZDWyxowcYEG5mjCq0Qz28do4MDS/6BMNwRlU2bZBOnPtYjt1jkZYl
         Levot4Yqs5R8rp/btYBWJ8d709jYF0X64DdGEN9i2t/aXG7wQapOuRJ+YD+ochvw5CbU
         B5LOz1h/XX7XR/xmOmjGPiw83esJSq47EtiRg+ku3OMwxg4nBe4GzqKKx1mF3wbldfRq
         +Jrm50jmbb9XsBRYAWHFcfVoEYtma3z4MqUZ5hf0j+zV3l7UG7PUyb7wmpM3cdNv8Wyn
         kaQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2o3MEAl09JNQzVuEHRq57iPBSS9omAtfIoIZ2Acqt/c=;
        b=QZQA3GY9P+xPj3Pf4mPMIKHAD2QZlQLfFefPctepo7VueQvcPUSTstImf1PWSd9R/A
         6m/CwmI24xReXGrA9xYHje25guVvSWtHoPVs0hSHZoLoADIecEZLxLb8ZS0T0nBb84Xe
         31q+BuM7ymYz/d0z+F3lvks7XHdN76y5IgtI/DFB5ru0ecs15BbDp3Pr+P4gsrs5d9B4
         UWZalfok5PJ1jJ2vV6NegVO0TIGy6InOPCsQgDOGcLn56Qxo4qudfw+ntifD0pNAU1WA
         +Ff0to1WyPKCCvOBA9YruvRanElh+UaBcze0T5Ft5vsRkmxq73I69CA9Ebh4nbFzoHHu
         NyTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id o10si28215109ejx.110.2019.08.06.01.31.46
        for <linux-mm@kvack.org>;
        Tue, 06 Aug 2019 01:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6D59F337;
	Tue,  6 Aug 2019 01:31:45 -0700 (PDT)
Received: from [10.163.1.69] (unknown [10.163.1.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6B3763F706;
	Tue,  6 Aug 2019 01:31:42 -0700 (PDT)
Subject: Re: [PATCH V2] fork: Improve error message for corrupted page tables
To: Vlastimil Babka <vbabka@suse.cz>,
 Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, Ingo Molnar <mingo@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
 <5ba88460-cf01-3d53-6d13-45e650b4eacd@suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <926d50ce-4742-0ae7-474c-ef561fe23cdd@arm.com>
Date: Tue, 6 Aug 2019 14:02:26 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <5ba88460-cf01-3d53-6d13-45e650b4eacd@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 08/06/2019 01:23 PM, Vlastimil Babka wrote:
> 
> On 8/6/19 5:05 AM, Sai Praneeth Prakhya wrote:
>> When a user process exits, the kernel cleans up the mm_struct of the user
>> process and during cleanup, check_mm() checks the page tables of the user
>> process for corruption (E.g: unexpected page flags set/cleared). For
>> corrupted page tables, the error message printed by check_mm() isn't very
>> clear as it prints the loop index instead of page table type (E.g: Resident
>> file mapping pages vs Resident shared memory pages). The loop index in
>> check_mm() is used to index rss_stat[] which represents individual memory
>> type stats. Hence, instead of printing index, print memory type, thereby
>> improving error message.
>>
>> Without patch:
>> --------------
>> [  204.836425] mm/pgtable-generic.c:29: bad p4d 0000000089eb4e92(800000025f941467)
>> [  204.836544] BUG: Bad rss-counter state mm:00000000f75895ea idx:0 val:2
>> [  204.836615] BUG: Bad rss-counter state mm:00000000f75895ea idx:1 val:5
>> [  204.836685] BUG: non-zero pgtables_bytes on freeing mm: 20480
>>
>> With patch:
>> -----------
>> [   69.815453] mm/pgtable-generic.c:29: bad p4d 0000000084653642(800000025ca37467)
>> [   69.815872] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_FILEPAGES val:2
>> [   69.815962] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_ANONPAGES val:5
>> [   69.816050] BUG: non-zero pgtables_bytes on freeing mm: 20480
>>
>> Also, change print function (from printk(KERN_ALERT, ..) to pr_alert()) so
>> that it matches the other print statement.
>>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
>> Acked-by: Dave Hansen <dave.hansen@intel.com>
>> Suggested-by: Dave Hansen <dave.hansen@intel.com>
>> Signed-off-by: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> I would also add something like this to reduce risk of breaking it in the
> future:
> 
> ----8<----
> diff --git a/include/linux/mm_types_task.h b/include/linux/mm_types_task.h
> index d7016dcb245e..a6f83cbe4603 100644
> --- a/include/linux/mm_types_task.h
> +++ b/include/linux/mm_types_task.h
> @@ -36,6 +36,9 @@ struct vmacache {
>  	struct vm_area_struct *vmas[VMACACHE_SIZE];
>  };
>  
> +/*
> + * When touching this, update also resident_page_types in kernel/fork.c
> + */
>  enum {
>  	MM_FILEPAGES,	/* Resident file mapping pages */
>  	MM_ANONPAGES,	/* Resident anonymous pages */
> 

Agreed and with that

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

