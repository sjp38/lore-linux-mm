Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6CBCC10F00
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 17:42:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70D77217F5
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 17:42:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="COzkJKPR";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="COzkJKPR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70D77217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5AFA6B0003; Sat, 30 Mar 2019 13:42:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE3A86B0006; Sat, 30 Mar 2019 13:42:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B86EC6B0007; Sat, 30 Mar 2019 13:42:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 781916B0003
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 13:42:13 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q7so4019352plr.7
        for <linux-mm@kvack.org>; Sat, 30 Mar 2019 10:42:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=s4e7VeoWMlzIlEPKaiEQCl8IY++EoUIg4A8b4SZPT8U=;
        b=jWBSu4P6F8fNNzGzDTYv+kFt1ASgXwpsFSvYghhxE9+8iGoK5F8cbA9PRmDuv2BicM
         5+ivTYMAuBzkb+/mNKeKedBgPaODBrwc49akBtMVqqsIWCaLNWTmooYNnYYeg4WJ6K7i
         qUuaiI49tFOa8Rhp8G1OWe/XIl6Fjtc5zgwp+qi195Hc9mwxhywnX+IosOyCdKDnuTAZ
         kAFl9h6npz8zQSdjbeXfc2bPrQ0eTFTTiZ1scNycAW/vBG+ZJfN/ILoYsSKW1ztavvLG
         aAsH1tXR9iWI8h1T6naEEgsL1cz7WGCXexoc+4qaFAzx4NHtltXk0/2qgHVcvVN5bEQY
         CSdA==
X-Gm-Message-State: APjAAAVrMY7TJC0u0bqvyn7o0Xuu0qCPczXl12PwcDVGRO6Y3RWszoCs
	d7q/qSrbUJUkFEP74nQSGlZkj6WmetPg/+DGij21C0kEvS/p763nghwVK8OzTvCpcHde7MuBLDc
	RNJl6Eyaga7bxONhrUyQBfDhxdAlbjpOfw5LWIhKNjAQyqlCaLxU7UFyZzjyeCtF1rw==
X-Received: by 2002:a63:6142:: with SMTP id v63mr51973153pgb.342.1553967732842;
        Sat, 30 Mar 2019 10:42:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn+cqqUxOk72KBmdON1n72OKQS5Iar7wHLWBi4aYLO2HA85smUpZnIYpA+5DrhG9yFz8Jz
X-Received: by 2002:a63:6142:: with SMTP id v63mr51973109pgb.342.1553967731989;
        Sat, 30 Mar 2019 10:42:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553967731; cv=none;
        d=google.com; s=arc-20160816;
        b=Ov/Pjy4pM1xarF8XQy0qUlrUkUo+RnwFbtTY2Z11tkW0ucllY9tZ4moBPqDY3GAGBv
         qbsZo1vL4PlPtDEwQiiaF1/qLrv3ToA201U2XwBySkiq43bdIxkKk5maoCWWO4AhSLf6
         urcGxE2dOLWDGwnhY+FakDSPs5riL+8WQoXroRGlBH31fo1WsGdHNT1l9CgfWLRnUloW
         EPv3dIA8QYytlhs/yj9W9uuTegwQunYm0CmklKOqGcsTmeYPHrksUfI0W8zzPbQp9DQT
         QU3APQFCZ0kH3xFXPJ4kopV0HlN/QuT9jQ3796P1W50zdl3vCxtA+2GlArPwd6rVa29E
         jeAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dmarc-filter:dkim-signature:dkim-signature;
        bh=s4e7VeoWMlzIlEPKaiEQCl8IY++EoUIg4A8b4SZPT8U=;
        b=Lx6bADLJwpF7FG6MK2sKP41ZZ9jQ6yNB3Hx0Nz019FeOX+vmqw04CvvwBpQvGo0xyB
         alTrDiVsYYEzK1AKMr338dcjTjNlJe9wci7a7xzYAWVM3QNjVKbpZguvCeroqtgzHma8
         hYSww6BVTgXVaYXiZSEtVnnX+NifYinm8tzbLEZs67rouFwtMgj1KfFWJm96NpOzw6Fl
         5yQVxacbgMu2RRGLu31u4/itsLWaVG6ErL+Fym+YaAlT+XnttM6vV3dciHxbBH2nxH1/
         khV8zVbftFsul2etU1qypdzhBkCW8ee394UrtR+OwbeTo+OhWM/6cJBFzD9ljV/1KUa+
         qzZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=COzkJKPR;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=COzkJKPR;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id f3si5105805plf.300.2019.03.30.10.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Mar 2019 10:42:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=COzkJKPR;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=COzkJKPR;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 6764E608BA; Sat, 30 Mar 2019 17:42:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1553967731;
	bh=s9DH1lhnU4At9ElnJVltMNvm3FhOZ1iX/6ORMr+PCSk=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=COzkJKPRRahvkG+CPBnlMF4kDrY2Y4Kyj6+54XoscnBqRSYl2KTEzb12RH+cjKlKT
	 bk5hWDDMGDL0SrgX+yALaiIVkBh9b5rJEhiVf97Jy63oaFIW+AwTut70fgmkC07O6G
	 CUV6BoJIdMrAn4OiU/UXGKDYM4B3MRGJXu26h/GA=
Received: from [10.79.169.97] (blr-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.18.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: mojha@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 52EDA6087D;
	Sat, 30 Mar 2019 17:42:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1553967731;
	bh=s9DH1lhnU4At9ElnJVltMNvm3FhOZ1iX/6ORMr+PCSk=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=COzkJKPRRahvkG+CPBnlMF4kDrY2Y4Kyj6+54XoscnBqRSYl2KTEzb12RH+cjKlKT
	 bk5hWDDMGDL0SrgX+yALaiIVkBh9b5rJEhiVf97Jy63oaFIW+AwTut70fgmkC07O6G
	 CUV6BoJIdMrAn4OiU/UXGKDYM4B3MRGJXu26h/GA=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 52EDA6087D
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=mojha@codeaurora.org
Subject: Re: [PATCH] mm: Fix build warning
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190330054248.28357-1-aneesh.kumar@linux.ibm.com>
From: Mukesh Ojha <mojha@codeaurora.org>
Message-ID: <91e4d2ab-db8c-aaa4-efbf-5df337242d08@codeaurora.org>
Date: Sat, 30 Mar 2019 23:12:03 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190330054248.28357-1-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 3/30/2019 11:12 AM, Aneesh Kumar K.V wrote:
> mm/debug.c: In function ‘dump_mm’:
> include/linux/kern_levels.h:5:18: warning: format ‘%llx’ expects argument of type ‘long long unsigned int’, but argument 19 has type ‘long int’ [-Wformat=]
>                ~~~^
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Does it come even after this patch ?
https://patchwork.kernel.org/patch/10846421/


Thanks.

Mukesh

> ---
>   mm/debug.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/debug.c b/mm/debug.c
> index c0b31b6c3877..c134e76918dc 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -137,7 +137,7 @@ void dump_mm(const struct mm_struct *mm)
>   		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
>   		"pgd %px mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
>   		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
> -		"pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
> +		"pinned_vm %lx data_vm %lx exec_vm %lx stack_vm %lx\n"
>   		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
>   		"start_brk %lx brk %lx start_stack %lx\n"
>   		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"

