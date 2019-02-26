Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87D5BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:16:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42E462173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:16:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="VpnHDEnE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42E462173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFAD78E0003; Tue, 26 Feb 2019 09:16:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAAAF8E0001; Tue, 26 Feb 2019 09:16:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9A848E0003; Tue, 26 Feb 2019 09:16:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92FAC8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:16:33 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 207so10538618qkf.9
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:16:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1VOsHpqNa6LTsxo2nkxb4h40F31APusw6iNn5tYasUU=;
        b=I8Exl2whRj/2O1zwPBEPG9tileUjpTnxr64BzFc1H5UTJCSSEfXjVW3QMfimyyyU6B
         x+WWKL1+i9wWBFKCLqr0HeFBKmWfY8G2y6VDoKkbCK9owbBvHIWoDYXlIzdbMvXpdTGK
         +ofkCgKXg7Y9KtfQTCY/IaWrZk2EAQpL9h0dtRgiIDoZwE4LOQMX4zen34uUCJjQS4Xm
         XOiZDgF9/Q1aTS27bEiQCL2YpO1+iQbBIgV39OXGgmehlQGUfQTVXckdTnNSbRwR8wDP
         liMSioPRZvtIOQ+4CTQismr8S2cPOIA8b0n4C/hjmx8WPX1eyeYvTmGH4PXlMU0uv9WC
         7B3g==
X-Gm-Message-State: AHQUAuYQFJNbgY5yO86qgYZdOnPqSq/0CwkHSHXVVUHskzN754r5tE7g
	vBx7yW/HrJsGREvtD7enlGkT/um18nmQN2M2IH6mplzVZEGalGOpk7tSnHk0hfS7T1M0TRD0ppd
	81GTf47g6G6xCLcJt1mIuvpC9ZxWABn7KN36r43KVQujOPrH4E8AeR/QLy8cDuiSEvFfVqHxkNl
	/pDFVVIIP7LZEHhwScLaqtYEEnC74llYSNlVwFWOOli96o7ifS6NMoBneznlk4gr5uzvjy3EsLY
	s/gcj2QZ9Sh/Tu7A+ofyu+A5ISRMURcYEl1G6/flFe2XsH3wMHCHnzSeXbaQ3wttaSlGT7Uqq3Z
	18Nub3nx8qquT60HN9XzBjraOV7kGKJGT1oQfI0+UcKKOZeNBIf7LAC/9j/nUl6B/7JfdtqGx8r
	g
X-Received: by 2002:ac8:33bc:: with SMTP id c57mr19051087qtb.63.1551190593369;
        Tue, 26 Feb 2019 06:16:33 -0800 (PST)
X-Received: by 2002:ac8:33bc:: with SMTP id c57mr19051028qtb.63.1551190592638;
        Tue, 26 Feb 2019 06:16:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551190592; cv=none;
        d=google.com; s=arc-20160816;
        b=CHfs8Wtpg++5RRlmbvPgygi3HeAzfrPegy37cREBcFebjL/lbnhzeGTKJVZUPb73pK
         KuMfNCH/Y1yFZYLMbzuiRm9ieFPMb16F9LWuVgAZLfE+y8d67bh3BHU2Wz0buw6rsLpA
         yA7c0EIlw9MYczdrFeXNRbS4VTch0jUuh3mrlrr/ZPtmIHoOCFif1sNqR9W1xXUk5Zl7
         8eGtFVA3Bm2pU7mBIdlUkqDzWcPijcuDspx7DRu+H86iVAKLFcDBzaJDyOi6jhxjMvPy
         IDDK/O0Khv1KaZbvY5tFY5LI5FDoI6V9/Pndc2Bcex0r/6PB/CEhjuYkDr6BYyTr42Cg
         6IVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=1VOsHpqNa6LTsxo2nkxb4h40F31APusw6iNn5tYasUU=;
        b=ktby9JCvYsx7zBAB10qUsLfzHeC2QUWB4CeorRdhMpSM2qk5SaRyUcc8d6SBhtOqbR
         ou7Cx4Ec4FcxVEajmLGXRBcANpw1UiagUWcZeN3oa6jbjeKAqc2kPiIAoYR0o/4BZrBa
         LoOusi2MlJeeyPuoY1tuH3VZYj5MUndf70vzhwgohGxjhSDlN1oUQHDTGrEdOklLblMT
         rlkZFQW5MGBCYZoex6ds0AXF6Tr9NZqADn1wAvfME9uccBmAcVAEWmAuBSrYWtjjtKTV
         /3xJuBpPosdtF/t2vP/SK3bztwOqToMD3KuBpzRDuaH7UCTkjazZc5WUBORlndMvo3RM
         bt9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=VpnHDEnE;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w26sor15487088qth.47.2019.02.26.06.16.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 06:16:32 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=VpnHDEnE;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=1VOsHpqNa6LTsxo2nkxb4h40F31APusw6iNn5tYasUU=;
        b=VpnHDEnE169AhLVJM0OL/pdD5WNAdf7Z5iZGZ6Lryup9dB6oqqy0DobWbMhOAn6Wub
         KE3UNHnAW317nAshfjaHsJGH7wFVeKDEtuKAKWmmD3zvU8hD5Md66y89ce0JZcYhNZfS
         Itd8ytY4ciWf9T3fxUp3aFQNtJNzn4csfJE6XXsmXd6VOGFakrOdYVCh1u4x9cJaDyHJ
         UY7yml1X3iQxnW6R/+XUIIVV8HRZixbg3etXjrGsvEOCavTJYuyccwu3oRmsKb6MFPQ/
         rGXesSqSzVAJQs4KYfVSo2BHcMHAEPhW+dZdBxS24XRrFV9U3DIoIJPbpNaWRzEHhMl5
         gQZQ==
X-Google-Smtp-Source: AHgI3Ia/vYitV8v90DyK+0qhpC+uDfIAsBuwHdIzuer4PHfEHeCppu5XT0rghK9/VqR/H+eExjFffw==
X-Received: by 2002:ac8:33bc:: with SMTP id c57mr19051000qtb.63.1551190592171;
        Tue, 26 Feb 2019 06:16:32 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id e184sm14174372qka.31.2019.02.26.06.16.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 06:16:31 -0800 (PST)
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190225191710.48131-1-cai@lca.pw>
 <20190226123521.GZ10588@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
Date: Tue, 26 Feb 2019 09:16:30 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190226123521.GZ10588@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.005335, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/26/19 7:35 AM, Michal Hocko wrote:
> On Mon 25-02-19 14:17:10, Qian Cai wrote:
>> When onlining memory pages, it calls kernel_unmap_linear_page(),
>> However, it does not call kernel_map_linear_page() while offlining
>> memory pages. As the result, it triggers a panic below while onlining on
>> ppc64le as it checks if the pages are mapped before unmapping,
>> Therefore, let it call kernel_map_linear_page() when setting all pages
>> as reserved.
> 
> This really begs for much more explanation. All the pages should be
> unmapped as they get freed AFAIR. So why do we need a special handing
> here when this path only offlines free pages?
> 

It sounds like this is exact the point to explain the imbalance. When offlining,
every page has already been unmapped and marked reserved. When onlining, it
tries to free those reserved pages via __online_page_free(). Since those pages
are order 0, it goes free_unref_page() which in-turn call
kernel_unmap_linear_page() again without been mapped first.

