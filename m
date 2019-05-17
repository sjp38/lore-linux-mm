Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 484FBC04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 04:47:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13AC020848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 04:47:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13AC020848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 952EB6B0005; Fri, 17 May 2019 00:47:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 903186B0006; Fri, 17 May 2019 00:47:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F1606B0007; Fri, 17 May 2019 00:47:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30D396B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 00:47:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 18so8760777eds.5
        for <linux-mm@kvack.org>; Thu, 16 May 2019 21:47:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Ckg3fyl/DRcbAO1cJNUc1jz4I+AwFfW1P6BfAJnwIt8=;
        b=HpoxZreSww7NWeWxEBitCR3NdVkEIc3m4cvYgjW5iUf5WF+8faIkmvDrpjJXNkiASi
         jfRE9nuYHzhvidLYgl9uppz5jE6et1e+Dd+6kfZ7GhCoHpVhw7fsd57G5TLShGpF7joT
         uqGskMhlOX/xnsOeEheQ51N06Yu7ft2VF4d5/KbSeG029gCUN4WVDv1OHS1wZfEpdwZD
         pnOff3hKLfBsabgoSj57sPD5LjkT0Ckkb4yM2OueW7psL+T88vyqMQCAywSGqoEN5qjO
         34NgV130bvhdHM/lQkdpUmWCV87NGlIzbyvOt3olmZVYu1wlntUvQFS6BFwZoGoR4GNi
         PKuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUFD/9IjnK/iGpFk9c+MPnQEeQdYOVv67WAjQ/Uxa5361gqQBJq
	X1VCdRobFLs8hoHttQXLiWTtIpZxmQeKpWBGVGePTQvLHjvbP4uNF8Xmkyi+YiiYa8dkXIbniE1
	4n/mhxoK+IRvEes7zdwrFLVTDzk1DexR1of+jVWbksv1g3VOSnWK4aD4LQBMHTKxXdw==
X-Received: by 2002:aa7:c641:: with SMTP id z1mr55186504edr.142.1558068477768;
        Thu, 16 May 2019 21:47:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywbv2AqvQ9vJAR5Gp1uf+M+3Bmq3IE93ZTA9pl/kJaDdTWVJm7yknPAnN45+oSIV5Xs0Ul
X-Received: by 2002:aa7:c641:: with SMTP id z1mr55186447edr.142.1558068476838;
        Thu, 16 May 2019 21:47:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558068476; cv=none;
        d=google.com; s=arc-20160816;
        b=f3bH71c0MjkA1h+pVWiCUkuWrBr1UA2MVG4kShJB2py1dBDkiwTfpFmJA3efPV6kJ6
         41hQ74UEVbAeriCYJxpTSjeW8D1nVAId3lKJ0birysPiCZwDvRdrE8jzIqWZMhPiN32O
         Un7CZuY7etkZJ4xpLk1Tda9Xk9sR0Mu6/QIZQoTu1lXfqUshbIVLGR/lKyAfY7cZLoLw
         Dbl3HbAi98v7Z0rIUxRWyMkZbF825b6NUdOZREMeo6Su5M3Nu8S3lVOCO+GlviPwH7BQ
         GrPWlTpZCuXNQhW50CibVWLepebaEtUr+GER1G0yxxr/RtsqizUTEpGkUOAmcYoTZGGG
         C+Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Ckg3fyl/DRcbAO1cJNUc1jz4I+AwFfW1P6BfAJnwIt8=;
        b=PtrZNolzs3/z2US0UP0yYCUKG3ABE+NaDEK3ZPGagnqGPzD4/NE0cF51qwKa56z2QI
         3TIFTwcc3rciWekt03TgHWS4wqGP0iPei6+GUTdBW5i0yYMDtuCCF5m73mPS8dZwXdJx
         VifzyYHQlkvlMOl1ZilS7tzAMbqekTGdehO/3J2mxp5gqiO62tKlP7gL/ltavjHek0wK
         gsX6kZgPJLdoSSCeaz0ugqxTuSLATPE6d8iNsWwC91xkg6kZM1JSZiQEd5xPgoF4olUc
         yJOr9Bt1zTA35ooqBIg3/+1tCci0WKAVvEy94OQrXbaycaUJhctISaGrGeqKHyH8eFJh
         yw1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l11si3412382eja.122.2019.05.16.21.47.56
        for <linux-mm@kvack.org>;
        Thu, 16 May 2019 21:47:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 900E680D;
	Thu, 16 May 2019 21:47:55 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 18AB33F5AF;
	Thu, 16 May 2019 21:47:52 -0700 (PDT)
Subject: Re: [PATCH] mm, memory-failure: clarify error message
To: Jane Chu <jane.chu@oracle.com>, n-horiguchi@ah.jp.nec.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
References: <1558066095-9495-1-git-send-email-jane.chu@oracle.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <512532de-4c09-626d-380f-58cef519166b@arm.com>
Date: Fri, 17 May 2019 10:18:02 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1558066095-9495-1-git-send-email-jane.chu@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/17/2019 09:38 AM, Jane Chu wrote:
> Some user who install SIGBUS handler that does longjmp out

What the longjmp about ? Are you referring to the mechanism of catching the
signal which was registered ?

> therefore keeping the process alive is confused by the error
> message
>   "[188988.765862] Memory failure: 0x1840200: Killing
>    cellsrv:33395 due to hardware memory corruption"

Its a valid point because those are two distinct actions.

> Slightly modify the error message to improve clarity.
> 
> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> ---
>  mm/memory-failure.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index fc8b517..14de5e2 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -216,10 +216,9 @@ static int kill_proc(struct to_kill *tk, unsigned long pfn, int flags)
>  	short addr_lsb = tk->size_shift;
>  	int ret;
>  
> -	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corruption\n",
> -		pfn, t->comm, t->pid);
> -
>  	if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
> +		pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory "
> +			"corruption\n", pfn, t->comm, t->pid);
>  		ret = force_sig_mceerr(BUS_MCEERR_AR, (void __user *)tk->addr,
>  				       addr_lsb, current);
>  	} else {
> @@ -229,6 +228,8 @@ static int kill_proc(struct to_kill *tk, unsigned long pfn, int flags)
>  		 * This could cause a loop when the user sets SIGBUS
>  		 * to SIG_IGN, but hopefully no one will do that?
>  		 */
> +		pr_err("Memory failure: %#lx: Sending SIGBUS to %s:%d due to hardware "
> +			"memory corruption\n", pfn, t->comm, t->pid);
>  		ret = send_sig_mceerr(BUS_MCEERR_AO, (void __user *)tk->addr,
>  				      addr_lsb, t);  /* synchronous? */

As both the pr_err() messages are very similar, could not we just switch between "Killing"
and "Sending SIGBUS to" based on a variable e.g action_[kill|sigbus] evaluated previously
with ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm).

