Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6758DC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:10:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3337B2166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:10:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3337B2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E49466B0005; Fri,  9 Aug 2019 05:10:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF91B6B0006; Fri,  9 Aug 2019 05:10:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE7E16B0007; Fri,  9 Aug 2019 05:10:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7426B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:10:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so59898523edx.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:10:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=G54Zwt+vB8h0+nqggCSrXu0/L6XlohtfmHz2tCBORb8=;
        b=Zbyclc3YD6XVMD+QwR7wQx2g9hKFHiTQLrtlIJ5u468/qMFPB+cF2BYPpFF6rCdCEU
         9dC4VozJX9uc3AM6weh48wFDwCPbhzMEdwT0IeBfghC2qQADXZaQMeVx/NIOwoqoV2IA
         svMcoBTjK6uvsvmX3hyhM6FUTWhsPeMkcHywrm4B5ict6osYFrYMwmQ1mP1IJOBeNDVs
         9RkIGadpcfe+EHTPjbz0GTTLF2CX857N7d8LTYYLr2gWdDyDD/UY5y7jY/0H3N2RomAz
         LOoWe1spEMbq8S7xMWwC8s+kb6xEIhpHSo2U7lArIziU+jXYeF1es/WsGaPBJY8z6Vo2
         grUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWns5xSxGSl7NNevHbn7Kceazg+KNZZCq2SoODcQ9JXN4Ki/xfk
	hSsp+QIBFVk4oJXWz7NpGX2TEYiqBjN+rXo9yMLlnK27eiN8qqzCZo/AGwIJ6KqmZ8UzO800oxV
	MmFptwnl+RYtZWGt7H1K1E6OjNEDoKcZMo4fxX0NajBsvWr+eIB+OgnjEZukRMHw8WQ==
X-Received: by 2002:a17:907:39a:: with SMTP id ss26mr6872696ejb.278.1565341809088;
        Fri, 09 Aug 2019 02:10:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKkKBqNzD5bFMIlbv177XIgy0bxmGL2JQ5BRbfFMtscog2aPhzM+fahYxJUvuXnT0qZqzq
X-Received: by 2002:a17:907:39a:: with SMTP id ss26mr6872652ejb.278.1565341808357;
        Fri, 09 Aug 2019 02:10:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565341808; cv=none;
        d=google.com; s=arc-20160816;
        b=ZAAiYlAyzgrOFCb/36Tm8O4KQoYn591CJCI0oSvOlinlNMLkeaxAGECc5peZu4+YeZ
         RDk0dVuk66QElDQs4MxGvjyLNR8SQfN9qVXjWYZTBYj4sfV+IqH7l0iStbHVZjAFAD3G
         rHceumK6FYq1N9I5zKuobZUtZ1AwPTINPg+GLFf7AtuQT+xp7wVbQ+WcBZPwqFZBtHhv
         /NSahRgMcI7bkWzMtiGYlk981zPSLtfNP6lb2WWnUC7WXNkxuinLQCZlsnVd+MMnVecy
         z6JRYniS6s7V+rn+XQEu9d+1I0059E7COc/CZz3+0wXxx1568lvz2SQ9KF/7R738qrkK
         Zjcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=G54Zwt+vB8h0+nqggCSrXu0/L6XlohtfmHz2tCBORb8=;
        b=qF5BkZDhr9j1LvgryuxPTvGmN9WooXIDTVy/UQC3SkoFV6TI7HCLR52dAWVy4aLTdg
         iEwqYewrnPFoWRW1YmpeylENM3q305RdGWdR4EP8Xb65jILZHyguV8bAypGVBwFKMwWt
         f2tTfH8dPedjomi5Hr15c4n7mlX0Pd8rGeB34Yka6qh+2vtoG6ZeHkhZJxcXQci9Pb4z
         CMC4E9UqBCv9EnOBYCRcjHNMIJlXCAeFC9pP1o0K4kZMe59FuZ2Dky+DqtBpur+QA6sw
         h4tvmh3YqbASPW1jPRQCFSirqJNMso5ySZHS7n3XQzewid02MK2JyQlbdza2VYjR9kGd
         UeiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id mh20si547385ejb.2.2019.08.09.02.10.08
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 02:10:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8043515A2;
	Fri,  9 Aug 2019 02:10:07 -0700 (PDT)
Received: from [10.163.1.243] (unknown [10.163.1.243])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EE6A33F575;
	Fri,  9 Aug 2019 02:10:03 -0700 (PDT)
Subject: Re: [PATCH] mm/sparse: use __nr_to_section(section_nr) to get
 mem_section
To: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
 osalvador@suse.de, pasha.tatashin@oracle.com, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190809010242.29797-1-richardw.yang@linux.intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <e17278f0-94dc-e0c6-379b-b7694cec3247@arm.com>
Date: Fri, 9 Aug 2019 14:39:59 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190809010242.29797-1-richardw.yang@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 08/09/2019 06:32 AM, Wei Yang wrote:
> __pfn_to_section is defined as __nr_to_section(pfn_to_section_nr(pfn)).

Right.

> 
> Since we already get section_nr, it is not necessary to get mem_section
> from start_pfn. By doing so, we reduce one redundant operation.
> 
> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>

Looks right.

With this applied, memory hot add still works on arm64.

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

> ---
>  mm/sparse.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 72f010d9bff5..95158a148cd1 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -867,7 +867,7 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
>  	 */
>  	page_init_poison(pfn_to_page(start_pfn), sizeof(struct page) * nr_pages);
>  
> -	ms = __pfn_to_section(start_pfn);
> +	ms = __nr_to_section(section_nr);
>  	set_section_nid(section_nr, nid);
>  	section_mark_present(ms);
>  
> 

