Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3A97C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 05:48:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 649B42089E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 05:48:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 649B42089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E74D08E0003; Thu,  1 Aug 2019 01:48:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFC318E0001; Thu,  1 Aug 2019 01:48:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEBE38E0003; Thu,  1 Aug 2019 01:48:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB1C8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 01:48:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so44006010eda.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:48:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MxmSwMz1Eu5n5J+AS9xPKWYDeLJxJptueVgGgi4JSeU=;
        b=cOzYM6Nk6OwVm5Kw10BSmb9f4uFF2YryaaeSqCTx7YYTf5LiCrXNhGnf13jq/Qt3AG
         i9zh4cJT9A2wJUdvvO4vd5qf1uh2Od5V6OqKkTk5ztNRHlG7nrovPHwiJUk8rZDINnh6
         VoM2iK6ZpNLIW+Jd4tyGHxJS46xRTvP67fFsqd22uCqOBoVzTfQhyQat7t/8M0T3nO28
         weMga+slMZIIqfmEBCc5+LWys+2zfGSjMJqartkWYW44UEEEeKIVL+h0TrhB3aCl4Da6
         8VbBD20TUFO1bGMJfPeHhNpPHEqpSwtGSP0v0N+HvBm3Q6FbH6QewtOvJbx7v/y8Zn3W
         OLQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVSCPUlpcOYD3I89CmRox8m9UouH/lhC9wvFDyS/u3+KHFituOh
	3AqDKfqdZ7scNY/IsSHZi4uerDZtFSMVYwFSoT21FjbAdS2fr9XFo0+TB8uV78O3g2fTdeoRy72
	9kTHMg5g7VFAGkymsBB090KhVdds7NTnTau7n/1BYEidQgtYfg3MLROCV+KJZ6/GpJg==
X-Received: by 2002:a17:906:3018:: with SMTP id 24mr13362844ejz.187.1564638487950;
        Wed, 31 Jul 2019 22:48:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzan+0o+KNfWddWdoxz69FEyOS/XTP5+rkZBlZ1radhqFLu30IV6qZLj9TiMt8BYb/9ENog
X-Received: by 2002:a17:906:3018:: with SMTP id 24mr13362799ejz.187.1564638486934;
        Wed, 31 Jul 2019 22:48:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564638486; cv=none;
        d=google.com; s=arc-20160816;
        b=ufH4+aiVSWZVbiMM5rjFLQIhbPMXsa5oJDmLTF7jSaR7aLoJF4l1GSAAsAu5OUqZYb
         H/2qOLfwykXsowYsIV1ntg3kkq0trpafa/BkQ2zpFUQE/j1iaB5gwhFgsCAYOqOIQ6c4
         r93fD5zCx3Gz2yMgPimPz8wznzNfVvu1OovvJfCEYmAWiB+mlEk5rHzzdqyIf4I4zNFO
         dF2fWMOk3mWTFltRs5WAQZA4bzVLwMD77QJ3oRknJh7oYO7VyhnfhgWP3of6wBHP1VAU
         Z7xOlLiZiRUdRR3guauHQlYU0PrbB/PPPqCTLYiUI+MvMnbKQwmV1tiqCosVKJJe4yzW
         C0Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MxmSwMz1Eu5n5J+AS9xPKWYDeLJxJptueVgGgi4JSeU=;
        b=yOTcTt4xcQ5MiTH2l+LQkH/NXQ8zSPwZXolVaU4i36NRPguox+mtE2PARXUeMjvM7Q
         yDjUDDkRjuYL8pbz7EIoK9YR8wzomau/p39N+DTBohfXOQ9IhgLGhzKGlkVx/8hNWiWd
         e5e1Vp8IjtxKpipJpmqbrB+xQHbCMMbKkp8DkJLcASxpQM3J1n3qLVhwqICUm0mPUZt4
         YpfWfQNiYgQTJ7hFRRmeXMTGncz7BojbEfeyB6sTJahXNvcuXmrQ4Bdel18NrODqiiH4
         S3WNvuZJuW7G5tvbUxUMTuNwp6VtVseahiU89J+vlOAZGwP/p+AesBCT9ASMETNggHeN
         N33w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v30si21278616ejk.208.2019.07.31.22.48.06
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 22:48:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DC921337;
	Wed, 31 Jul 2019 22:48:05 -0700 (PDT)
Received: from [10.163.1.81] (unknown [10.163.1.81])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0BE013F694;
	Wed, 31 Jul 2019 22:50:07 -0700 (PDT)
Subject: Re: [PATCH] fork: Improve error message for corrupted page tables
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, Ingo Molnar <mingo@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <56ad91b8-1ea0-6736-5bc5-eea0ced01054@arm.com>
Date: Thu, 1 Aug 2019 11:18:38 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/31/2019 03:48 AM, Sai Praneeth Prakhya wrote:
> When a user process exits, the kernel cleans up the mm_struct of the user
> process and during cleanup, check_mm() checks the page tables of the user
> process for corruption (E.g: unexpected page flags set/cleared). For
> corrupted page tables, the error message printed by check_mm() isn't very
> clear as it prints the loop index instead of page table type (E.g: Resident
> file mapping pages vs Resident shared memory pages). Hence, improve the
> error message so that it's more informative.

The loop index in check_mm() also happens to be the index in rss_stat[] which
represents individual memory type stats. But you are right, index value here
in the print does not make any sense.

> 
> Without patch:
> --------------
> [  204.836425] mm/pgtable-generic.c:29: bad p4d 0000000089eb4e92(800000025f941467)
> [  204.836544] BUG: Bad rss-counter state mm:00000000f75895ea idx:0 val:2
> [  204.836615] BUG: Bad rss-counter state mm:00000000f75895ea idx:1 val:5
> [  204.836685] BUG: non-zero pgtables_bytes on freeing mm: 20480
> 
> With patch:
> -----------
> [   69.815453] mm/pgtable-generic.c:29: bad p4d 0000000084653642(800000025ca37467)
> [   69.815872] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_FILEPAGES val:2
> [   69.815962] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_ANONPAGES val:5
> [   69.816050] BUG: non-zero pgtables_bytes on freeing mm: 20480

Yes, this is definitely better.

> 
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by/Acked-by: Dave Hansen <dave.hansen@intel.com>

Though I am not sure, should the above be two separate lines instead ?

> Signed-off-by: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
> ---
>  include/linux/mm_types_task.h | 7 +++++++
>  kernel/fork.c                 | 4 ++--
>  2 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm_types_task.h b/include/linux/mm_types_task.h
> index d7016dcb245e..881f4ea3a1b5 100644
> --- a/include/linux/mm_types_task.h
> +++ b/include/linux/mm_types_task.h
> @@ -44,6 +44,13 @@ enum {
>  	NR_MM_COUNTERS
>  };
>  
> +static const char * const resident_page_types[NR_MM_COUNTERS] = {
> +	"MM_FILEPAGES",
> +	"MM_ANONPAGES",
> +	"MM_SWAPENTS",
> +	"MM_SHMEMPAGES",
> +};

Should index them to match respective typo macros.

	[MM_FILEPAGES] = "MM_FILEPAGES",
	[MM_ANONPAGES] = "MM_ANONPAGES",
	[MM_SWAPENTS] = "MM_SWAPENTS",
	[MM_SHMEMPAGES] = "MM_SHMEMPAGES",

> +
>  #if USE_SPLIT_PTE_PTLOCKS && defined(CONFIG_MMU)
>  #define SPLIT_RSS_COUNTING
>  /* per-thread cached information, */
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 2852d0e76ea3..6aef5842d4e0 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -649,8 +649,8 @@ static void check_mm(struct mm_struct *mm)
>  		long x = atomic_long_read(&mm->rss_stat.count[i]);
>  
>  		if (unlikely(x))
> -			printk(KERN_ALERT "BUG: Bad rss-counter state "
> -					  "mm:%p idx:%d val:%ld\n", mm, i, x);
> +			pr_alert("BUG: Bad rss-counter state mm:%p type:%s val:%ld\n",
> +				 mm, resident_page_types[i], x);
It changes the print function as well, though very minor change but perhaps
mention that in the commit message ?

