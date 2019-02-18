Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B7CFC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:29:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C5672173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:29:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tzEbac8+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C5672173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A516C8E0003; Mon, 18 Feb 2019 06:29:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FF8F8E0002; Mon, 18 Feb 2019 06:29:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C7A78E0003; Mon, 18 Feb 2019 06:29:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0F58E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:29:33 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r9so13542524pfb.13
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:29:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9zVouE7YOK8js3D9q4XzpJUxoMNosNwdoryRQYjPG0E=;
        b=pGhCznhNCALypVG+M9Z3kjOA/yKLsoWtHuX0RbbR3BpI4tcWTtBqeResXvDQZsu16O
         9QYtWaauPTrBWr0B9DGUptDY/DdTmGKyyaTbaqSga1onyKAvHQIgkGepXzx2xKe1JIJr
         9Mpj8aRWdef21QV1NQDRfjPVMnnddUkzJhE79aJcfZFyFFgCAfH4o1dHmYNz3VnCGmA4
         NGVOaEmzAJ6KqUyCST6qonUQUaOMXJdKTj8v+gxaeOb5RBjzlyhQXRamfmyvmGxlEX8H
         QEBXq4VPBl//+c1KjyohhwqC9Pu5D9lTV0W4lKrR2VLxACJ51YFWycxi5DjX+SbOXcgd
         Twmw==
X-Gm-Message-State: AHQUAuaqa4yc2Sc+u+TFEJEk9E8izMVQQiZs+tTSdalCRrWMo/OkB24i
	6Cf09gIVz7Y9hmlIJMr7BK/EaqeW1buOSwx79ioFL8DH4Pm1e7CZtcwp5NXT43BSdSlnCg1z2ki
	2qs2DvebwR4dyFKGP8nZLKKUeaZuAZDLkMonhjPr8uWQI7odHvptv5Ty3ZEvyTc+lJw==
X-Received: by 2002:a63:f816:: with SMTP id n22mr18530771pgh.146.1550489372925;
        Mon, 18 Feb 2019 03:29:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbgWbFHiOdCEKkNawEt6d6UHI/1gyc9UNRMdp5aZpL6VV3YHjqJ0Ohi6ETMSw+Ca5q13GSk
X-Received: by 2002:a63:f816:: with SMTP id n22mr18530734pgh.146.1550489372230;
        Mon, 18 Feb 2019 03:29:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550489372; cv=none;
        d=google.com; s=arc-20160816;
        b=mR4GYeq5soC4pTHL3OEI6T9Gjj/pa4S9qvQ4+nqrO0W+MZhPD0ASmx2zcVSFW5FZ4U
         IVga+nkU3xaL1J5qUjn4UdNy5/ATdXhat5ocbIYkeJzCjitEn2SxE7hOdQQc790bINCM
         l6/XpRxhbPOH4FY0KzIfC4kMrRAuA2K5jAN8fKuTk11ujidFLi8eFv+3UKW9yOlwurR3
         lhuoMr5bQ4LsHnqPeeO4LjhYYWBzG2RT5vOU84M5Y5ixwE8748Go04SMBv0SPoBLgv3n
         v/ADCPUmvql/zr3yawoEu3OO3SnfZiyow7Jq3jU2BJ1iGwU/mcZonawTuX2A38IpRKmQ
         KCcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9zVouE7YOK8js3D9q4XzpJUxoMNosNwdoryRQYjPG0E=;
        b=e7cu5obHDkqqMM9W0JRqRzoIwSyBz/h4jpioBbjpdbvnyX9sHWl7kp33hwT7z6TmaN
         Y/nFyNxPj6Py79qoN668bl9aGZtOw35tGpBdpf4/E0pdj2+6s/KC0hHKphCw7DX2AluW
         qBduJpf3ZRVBjc7rNlo7p0ImZf0XmT+ZSaNvxSb0y5NmYKYrb3EfpTRUSnIs5uVu0hlk
         4OA7sjwFjM+whowbqcFjWvvmXT30zHK0UuSoqLL7EbAw/blzFbEotLO826P/gjadYiHm
         +MCPvPFcHKX6V7H7jNWXMyAqY4jtYwsW7hJJfrurqScFdefc5BjGSfcF/GyLnHKdnM4h
         O6vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tzEbac8+;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i2si13226245pgl.153.2019.02.18.03.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 03:29:32 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tzEbac8+;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=9zVouE7YOK8js3D9q4XzpJUxoMNosNwdoryRQYjPG0E=; b=tzEbac8+iPNgeGV+p0XkPk8Bp
	iUaJYYy9vePbQcLSuhi8zC/5QKr4hKNVF8fXj3LOCPR6Pgpa8+Y7gduDH5xAlP4LED1Ml/cGoigXj
	A5rcb8QXfNYQhw8iobVYN7jSRwRp3l5uQZTfF2CDY6ZuM6PsxuIV23B9msvwWyPec2Kx7dEID6a/A
	AXRNy4ZBLSbWyMCX8+Q7FtE9KSM6Mg2PTN8/NXsjxH0V5uIVy7UQ8xPNYgVpTcGd17HLbmJFzFy0X
	RpL1f0qFldAammcBhMoyGvSqhvz+t8vPUxzQkMi9LQn4j19QJwt94B3ZQoF6rOUDcpcGH6rgSeS/k
	FR5n5UI5A==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvh6z-0000Gc-DF; Mon, 18 Feb 2019 11:29:25 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A14E423EAF75C; Mon, 18 Feb 2019 12:29:22 +0100 (CET)
Date: Mon, 18 Feb 2019 12:29:22 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
Message-ID: <20190218112922.GT32477@hirez.programming.kicks-ass.net>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215170235.23360-2-steven.price@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 05:02:22PM +0000, Steven Price wrote:

> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index de70c1eabf33..09d308921625 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  				 PMD_TYPE_TABLE)
>  #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
>  				 PMD_TYPE_SECT)
> +#define pmd_large(x)		pmd_sect(x)
>  
>  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
>  #define pud_sect(pud)		(0)
> @@ -435,6 +436,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  #else
>  #define pud_sect(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
>  				 PUD_TYPE_SECT)
> +#define pud_large(x)		pud_sect(x)
>  #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
>  				 PUD_TYPE_TABLE)
>  #endif

So on x86 p*d_large() also matches p*d_huge() and thp, But it is not
clear to me this p*d_sect() thing does so, given your definitions.

See here why I care:

  http://lkml.kernel.org/r/20190201124741.GE31552@hirez.programming.kicks-ass.net

