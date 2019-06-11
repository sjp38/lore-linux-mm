Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1120C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:11:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 835312089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:11:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 835312089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 068CD6B0005; Tue, 11 Jun 2019 06:11:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F34866B0006; Tue, 11 Jun 2019 06:11:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E23046B0007; Tue, 11 Jun 2019 06:11:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A8B206B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:11:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so14995587edv.16
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:11:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AWc+5A2MsNvUgIej4Ob+mmm+3tkQJme4/2tSyVqeajc=;
        b=cDdF2Yt1xCh4ORgi4CY98VfjVKI8tbEF8aL8rxwEZDrmki+N/Xst4AB7/0II63zyFV
         aZinxgZtOSAiC9GH7aCRbE5MCYJRheZSG7X3xA1FpjCSuty27T36K3eIvQoinr7tI9tA
         jXe/oXAypeLwlqItJl3QPWM/UyRzx2zMd2QN+N9Izycf+tyo53rT7TyHKfrx9yAm2ni/
         SvIEx8ZafjdH2tKS3h30WxMRshXh3zoDXW0lozA7nmbW9vKbfRy3elP5LVcQ7PwrWVPg
         AulUEyDIx3IdOs6FyOkqIcmPQwHbHTb8UPoP3y+XeOoxpR3XukfIpHBeNT2iPJtKf3Sl
         4rHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAWQM7VFOaiCSku7YjxHj2s/RNne/Qpc7PUAfI19holiwo/H8YSV
	5uNHWa+18P8gZWepR3/qqDFt4ysfWVuvvtGW587cPsFToXVE9lEnMADwuIyn7LqTC2rwa+yh57x
	HKPGnecZJK899l0SjKPtrFfengnEfS6FhoVUQCoubwxsq/yhyNcCCR+fORG6nQ58VzA==
X-Received: by 2002:a17:906:6545:: with SMTP id u5mr65780301ejn.102.1560247906252;
        Tue, 11 Jun 2019 03:11:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCPzE86aGRawDjSromM8hmEne8YdY3GWeBf6KJ5bdMbE2DAruBnmAgDF79tlLyzKSivIWt
X-Received: by 2002:a17:906:6545:: with SMTP id u5mr65780254ejn.102.1560247905623;
        Tue, 11 Jun 2019 03:11:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560247905; cv=none;
        d=google.com; s=arc-20160816;
        b=Qr6LO6ABLWdsVvXi0gamDi+a9PO447KDYfakcQm3QNwBa/LL3zK7jZWBOT0TqYC3YC
         1gbJ/EBfzclIAtTz/4CWbSF/QCtJiZBKqnS1rLFqJSvX4dYiV0I5U3P1Fklon55SdGCM
         M5zZ7ZaFrFzkgxQ1gtl/xIfPLUd54gVui/lyh9FmdmD4Uhw7DeRf7tzenYsJvMuxnV9i
         aBQhCuVK1PnzI+mhQ9BbnBiV9N1yObeoZu6rTlKvIh52PviYJ+AADH6kdjx6t8VbgzOQ
         m4g6FgaKtjfJdkVb943xiPoIbzZOe6rnsOJ/w58PI+VDaqDWVkJA9xpCnLsxZIDt4ph1
         CwTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AWc+5A2MsNvUgIej4Ob+mmm+3tkQJme4/2tSyVqeajc=;
        b=r8CETlH0EmuRVCRXfwyaoaA6gwoRWC3wfyPDrOZP4XnwL1SGPGK4B6ugL9E7Ye+c0x
         s8js8bhBPFsg6v5yRM8cxUtRc6eihI1Qj5dhD/Tfac8462Zm59SeDO0ahHQ2AalZ+Iyt
         JPL3hG9ulKTbT0VHZKniViqt5ksmYngbvp8r23U2FGRhg5DDckDoORK1L5cuu6EIKyQ0
         ZFMPE/VicotxTVYy8O08imcaoCvuorJxBSWMl3z1crhp0Qc1PXycVtB3upmfZIneiKQj
         abLH2RqvW6QuOa0ezYsz7/WM+m1S5Hr6/cCV4EoQ1pHTRKRKdYvvDXb0f4pOwJDyQvxD
         t6UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r42si4891059eda.345.2019.06.11.03.11.45
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 03:11:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BCF88337;
	Tue, 11 Jun 2019 03:11:44 -0700 (PDT)
Received: from [10.1.29.141] (e121487-lin.cambridge.arm.com [10.1.29.141])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2A4193F557;
	Tue, 11 Jun 2019 03:13:26 -0700 (PDT)
Subject: Re: [PATCH 01/17] mm: provide a print_vma_addr stub for !CONFIG_MMU
To: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org,
 uclinux-dev@uclinux.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190610221621.10938-1-hch@lst.de>
 <20190610221621.10938-2-hch@lst.de>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <e5827553-0924-28ee-3c8a-d29b4c01defd@arm.com>
Date: Tue, 11 Jun 2019 11:11:42 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190610221621.10938-2-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/10/19 11:16 PM, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/mm.h | 6 ++++++
>  1 file changed, 6 insertions(+)

FWIW:

Reviewed-by: Vladimir Murzin <vladimir.murzin@arm.com>

> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index dd0b5f4e1e45..69843ee0c5f8 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2756,7 +2756,13 @@ extern int randomize_va_space;
>  #endif
>  
>  const char * arch_vma_name(struct vm_area_struct *vma);
> +#ifdef CONFIG_MMU
>  void print_vma_addr(char *prefix, unsigned long rip);
> +#else
> +static inline void print_vma_addr(char *prefix, unsigned long rip)
> +{
> +}
> +#endif
>  
>  void *sparse_buffer_alloc(unsigned long size);
>  struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
> 

