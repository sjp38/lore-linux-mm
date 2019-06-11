Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E05ADC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:32:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9668F20665
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:32:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9668F20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB1066B0005; Tue, 11 Jun 2019 06:32:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E61A16B0006; Tue, 11 Jun 2019 06:32:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D29076B0007; Tue, 11 Jun 2019 06:32:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3196B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:32:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s5so20066340eda.10
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:32:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yi4Viu+xpAMuUI9z3dU0VFv3EA1DXGPoCHP1fK6d9DE=;
        b=VTjUSETUelYb41Gxcv5Ma1L96hoLQf/34PWwguNzbC6WmuaNYGT1n0eOcChWnLePIU
         DFvdSOmZf/DTEJiF73FuUsqNUUyvoL/xkkvsUXGi9OzOqcPhpeC2BYCi0W2A2+n7jKcy
         sLvhyAWLAWj79ph24DTbtioMYkKvEHDxJvYsObCOa4aXZnDtTc3iS60aNWMJ61aKr7QV
         CbDo4mW5iMth2NuaLLOmwOZ6TWEJ3jih9h579kvVLz5rxESihl08x9NVqfWN+7GvO1XV
         PNl2rq4a7Gzj90kKW6kPiV99ea/9Z+wDxpYbtjNIEzMaBJYnKny4NDbJIb+gvZiW75CE
         6jaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAVGUcN7WrhdKiGLgy76rw5KAohxmajUGB/NPPuT8S+6ejeUsJG2
	9QFHzzXgbXAHte65UGEgNWOMQmqz9Otutt72ktiJcWix3uxSna6Hn7qZAJNwIAgW1g2aywYtbsl
	VdAUI1PgSCfbBgEeCUW3oEesAyrt/iy92bs8Dajdcl7eQGcIrhzi4wPmZaCGV2NwDRA==
X-Received: by 2002:a17:906:1813:: with SMTP id v19mr50688723eje.109.1560249163211;
        Tue, 11 Jun 2019 03:32:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJhMfC027oGPPDsZAxz9dA9cIMDS0UbsMsovlb+sBwKjQew3kecydnPnpkuEgo+IfU7c8+
X-Received: by 2002:a17:906:1813:: with SMTP id v19mr50688660eje.109.1560249162342;
        Tue, 11 Jun 2019 03:32:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560249162; cv=none;
        d=google.com; s=arc-20160816;
        b=R+7rgVBQR4348U7faaRDSZbprrqiJ10FBljnotY+Q9DCD8YtJTQhXdAthsliat503k
         LBxeLIQ5VCQKHb0a9ygrEet+hsFB6XxGRlhPkrMcK9jbRRLrFEfOLNKMTXUxrw20Ql6w
         QghMzPg8rSPty+yGiB9aAwc5MbaWREhC9eDSgWv0emMtL0TyEYXpwgLHDU6zjp8bZQPr
         yeVtNESIzQR2xOv8L7EKGXpWE/xlzYmK92YKZehOo4hzUg62d0hM38t/spV+qdaNUz2J
         zz4spuZEZ6RZFyNpgO0ZryZTwnb6CquIAypBOkGx3IFxiluglAksk8QTW7tzKCo3L25g
         WQ1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yi4Viu+xpAMuUI9z3dU0VFv3EA1DXGPoCHP1fK6d9DE=;
        b=PeZVZ6ax0OvcBUSHayvwnggVs+rxCiBv6ZHp+NhcGJKAnzKWwXd1UZFWzzrfRZFHFe
         SgS7/jRuENxNXMTI7zB5+Z8EMyxhkf/+EHHtF3Ada3lQYhPKfDaTYxzcV4OZpEuSpLlS
         G1w7Oe7wZmklaLtZxefv92HC3ptQzdquRkwUu24wPnv9THq3WzKaI3e+3n2tARSII8YQ
         f9wHwllEl1kLp8wtttoFUivM5FfBlDUILPtRBvcFCHjly+8KNVRs9bPVysjZVxtd5Bz9
         vKZ9+DiWgZyg6e0akoB3lfKwgf6zYl2vKL87GaatmlVlVnWTRaEc36C8VeX2CsFpVmdr
         IjOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h21si7975784ejj.356.2019.06.11.03.32.42
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 03:32:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6D599337;
	Tue, 11 Jun 2019 03:32:41 -0700 (PDT)
Received: from [10.1.29.141] (e121487-lin.cambridge.arm.com [10.1.29.141])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 21DD73F557;
	Tue, 11 Jun 2019 03:34:21 -0700 (PDT)
Subject: Re: [PATCH 17/17] riscv: add nommu support
To: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org,
 uclinux-dev@uclinux.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190610221621.10938-1-hch@lst.de>
 <20190610221621.10938-18-hch@lst.de>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <cbf88fe0-94a6-b559-2b64-c725f236b683@arm.com>
Date: Tue, 11 Jun 2019 11:32:38 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190610221621.10938-18-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/10/19 11:16 PM, Christoph Hellwig wrote:
> Most of the patch is just stubbing out code not needed without page
> tables, but there is an interesting detail in the signals implementation:
> 
>  - The normal RISC-V syscall ABI only implements rt_sigreturn as VDSO
>    entry point, but the ELF VDSO is not supported for nommu Linux.
>    We instead copy the code to call the syscall onto the stack.

On ARM we perform I/D cache synchronization after stack manipulation.

OTOH, ARM port of uClibc provides SA_RESTORER with intention to avoid
manipulation with stack and cache maintenance operations (yet kernel
still performs such manipulation, IIUC, for backward compatibility)

Cheers
Vladimir

