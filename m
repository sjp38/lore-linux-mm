Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE7C0C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:30:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69C5D206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:30:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="BN4Ej/JD";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="oFfS295r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69C5D206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06F8F6B0269; Thu,  4 Apr 2019 03:30:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3B6D6B026A; Thu,  4 Apr 2019 03:30:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB52A6B026B; Thu,  4 Apr 2019 03:30:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDD86B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:30:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s19so1257935plp.6
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:30:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=KWKUmZlwiOvhevc38gmx4x8XOqMg/20lgxwrN29WmQs=;
        b=P1DCHTvDngahglhhC9kccNB1HrZDMFNimOW2y5m53PivHzf3p2Wvxml42pIFWWMGgH
         7zfggCgh+8HJhDpkBeIM+SzqCCi95VFjGfBtutp/GHzb7KcG7G2/IbX9Jm3AfiJl2GQq
         0a/hKo0cLUAK8MNpSE2r4ZW8/TtvptcA4huPl8ffJe0wpQ5vXgjLeM2iZz3jcHOq1Thk
         iAZzA7ERcM9FMRRt3QtMRwTRuNvX4j+4cnqQ3dqvbLieGX6XW06sRn7UJmgRSvpUCFV9
         3Hx8BbwUaa0WaGXmKLatq+bI9X7ncvWz5zstVN55x/TD4hJ5iDqpMD9GAHo4o+48NaOT
         Cbog==
X-Gm-Message-State: APjAAAWHIptzNwh2C/2f5sg4fn3MDFD8P6j3p63s+APaFIFnwtOFTGKe
	sYVrL/zci10mH9XglO1DdeRnVghlpV5R2kWNfbIt2xAXn+OcIASG/aPhJQpH/YSDWrmuyp7NEI8
	UaGhRa44h3POV+TeiQNWfZhOWFJSaErsCdJjxO3M81zIsNg/q9RlAjpcxsX1dUpqNzA==
X-Received: by 2002:a62:458a:: with SMTP id n10mr4237435pfi.136.1554363026272;
        Thu, 04 Apr 2019 00:30:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyz6DAxeKnw1+6XdtEobgNQFmXxahTFNXHm/KIFPLz1QfOnxKkhSssMLRQhUlMPAEEdT2MM
X-Received: by 2002:a62:458a:: with SMTP id n10mr4237378pfi.136.1554363025490;
        Thu, 04 Apr 2019 00:30:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554363025; cv=none;
        d=google.com; s=arc-20160816;
        b=Ec8t4xS8IlNJBIpEarTyoCffoCWxaxJk2OxB3klfHpKzp6+WbD9YM2amClbJons+XX
         EwRXk/ufQ3h5cfPR77IeD1BNxNhlr+mx5ghhecvKC9ld2UR6FdFoqoHePHJIU1Q4EaCB
         wkWYXlg1RbnglppwYzy/sq9Pwc/ELPgJx8NXUJ3DYJN63q+XRk4PQPUzlqFZhN85YUkG
         f7QD4qxpHklcZX+8h39+qD4MRSzfv5Qtj0e0o8QE3rnjpwKv6QLclMwmY+Ni9q/SMtf3
         mzNZWpI5vm1JHenEHyWBLIZ61D0M/ZWMJ0ERfY1UwqD7wTp1JNNV99BfnpNn6yfDRuD1
         xeGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dmarc-filter:dkim-signature:dkim-signature;
        bh=KWKUmZlwiOvhevc38gmx4x8XOqMg/20lgxwrN29WmQs=;
        b=vOnStnHiFE8aPc9CpY5qJI8s3wZADrsoRc/81UMpzgsi2ix9d4yVdqQYHz/pqE4COe
         VTy0RqZinqNTrgf1DyU26c4ToBPHUqo59SXch/3mUZji/t/sQjaCKfq4iZb90r5BtTOP
         RBJKCIG3y4QpAJWXuEKNrgJKRlFeXRgVBgdNEI72qp/cUxZG1ouxLyZ43b2CjjBYhW3w
         S6SehPrpSG01+hdHuRBybxIAr1eme8weFNbpNJ6ipNObVY+v0He5QJpR9W8VBAwa5BWx
         7O0bUThpM+C4jOQOS/L2EyzVTzOxgvWSGMVyvlmf784oe6Fg5qQm5eaPU8hIwdDAqVMS
         fLFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b="BN4Ej/JD";
       dkim=pass header.i=@codeaurora.org header.s=default header.b=oFfS295r;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id f20si15670392pfd.51.2019.04.04.00.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 00:30:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b="BN4Ej/JD";
       dkim=pass header.i=@codeaurora.org header.s=default header.b=oFfS295r;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 22BD361A42; Thu,  4 Apr 2019 07:30:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1554363025;
	bh=eFb1Phc+myeQ/NOdZyTaAoOXqU1b8biNLp0iv1xEqlk=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=BN4Ej/JDEyxMHCeM/b8hh+vkX+PXkaxfcS59hWAYOsERDdLedA/K8aQyevmg3J4dT
	 DngCZsHhLaqYOB79AkTa45kEwy1XrbmqHiUtpHhBO1ztDDcovKxRED7I/ZaZZtDM0X
	 fnb8YT53GskVbaP7hf59lSR6N/N6kvHOdDPGES4M=
Received: from [10.204.79.83] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: mojha@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 824EA6155D;
	Thu,  4 Apr 2019 07:30:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1554363022;
	bh=eFb1Phc+myeQ/NOdZyTaAoOXqU1b8biNLp0iv1xEqlk=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=oFfS295r0yoWB2adTX6rQ1sWHIw36Ol/zHYx7jG4Xp6LC5SXDHcWd1VmZEyafo391
	 l8mDjb9ZwT23er8QE3dwtb892/5cVnkKX5W03ybycVUQi8S68I2VG+SBvje80InI6E
	 uAtCaA1Oz+r1TkjlHzBL01R3U5QnJGnnqpd4pQs0=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 824EA6155D
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=mojha@codeaurora.org
Subject: Re: [PATCH] mm: __pagevec_lru_add_fn: typo fix
To: Peng Fan <peng.fan@nxp.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "vbabka@suse.cz" <vbabka@suse.cz>, "mhocko@suse.com" <mhocko@suse.com>,
 "willy@infradead.org" <willy@infradead.org>,
 "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
 "arunks@codeaurora.org" <arunks@codeaurora.org>,
 "nborisov@suse.com" <nborisov@suse.com>,
 "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
 "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>,
 "ldr709@gmail.com" <ldr709@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "van.freenix@gmail.com" <van.freenix@gmail.com>
References: <20190402095609.27181-1-peng.fan@nxp.com>
From: Mukesh Ojha <mojha@codeaurora.org>
Message-ID: <43a2f07f-1b28-cd85-b37c-af730b446d2e@codeaurora.org>
Date: Thu, 4 Apr 2019 13:00:11 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402095609.27181-1-peng.fan@nxp.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 4/2/2019 3:13 PM, Peng Fan wrote:
> There is no function named munlock_vma_pages, correct it to
> munlock_vma_page.
>
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>

Cheers,
-Mukesh
> ---
>   mm/swap.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index 301ed4e04320..3a75722e68a9 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -867,7 +867,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
>   	SetPageLRU(page);
>   	/*
>   	 * Page becomes evictable in two ways:
> -	 * 1) Within LRU lock [munlock_vma_pages() and __munlock_pagevec()].
> +	 * 1) Within LRU lock [munlock_vma_page() and __munlock_pagevec()].
>   	 * 2) Before acquiring LRU lock to put the page to correct LRU and then
>   	 *   a) do PageLRU check with lock [check_move_unevictable_pages]
>   	 *   b) do PageLRU check before lock [clear_page_mlock]

