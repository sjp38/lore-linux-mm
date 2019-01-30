Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E88FFC3E8A4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:57:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A02F21473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:57:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A02F21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC6C18E0002; Wed, 30 Jan 2019 03:57:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9CDD8E0001; Wed, 30 Jan 2019 03:57:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8CD28E0002; Wed, 30 Jan 2019 03:57:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D03C8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:57:07 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so9213879edc.9
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:57:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lCxabxsVWTynqe1k7NVN/+sCJlTo9JfxvTP0DnwspPg=;
        b=TiD9vfSysP7/NvQcF1poPaQFOmQAaUCeFpPUdtH1ZWMAJNcyqTzWx006KRRdDYFOQy
         GTP5sT4Ede6ZYwJOp9G6JPATPof2GNeSKdGb8ZhHL6nYKXOjfNXqEPnL0hcJBTnUKJ6X
         pz13Fw3nDfHww7RwUM7Bj6FJ3O9rnliUx3m6PAWJO7ttQ8CcLa7f0MKYhWBGro/Yxt84
         6AWaSxXCsG9ptk0DUijgczGWRxJM4NGFS4ZlESSjHNK4q1sRxqXdm+rHMYyozHucuC/9
         +TvPtIu8eniMiKjtROwTyM7aLKAGv1e02H1iGYflLHH/sUGWsNLKVD8JY6axnuziMw7X
         TjgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of julien.thierry@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.thierry@arm.com
X-Gm-Message-State: AJcUukdZHu3E0m8e5FpGdfNEkrQn/A4KItzu+svpFYIWfCr6v0ym3N9L
	jIPDS2x0uxkDQ00Fz386H0fzpXgTTFGDcS0H9Zgd7YP40Gw0knzNGNa1PY9Zepe6g9Q0f1tmnkd
	TNiAqI1ZEaUxavF1mxPaOtn0M+NtnAPYPuhwY0fUjQyN6IDIegB6DOZLuVVWPuY27gQ==
X-Received: by 2002:a17:906:7817:: with SMTP id u23-v6mr25900427ejm.145.1548838627018;
        Wed, 30 Jan 2019 00:57:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6oON+LfuvFeEIe1clR0DqZBdBUmOoEfrJ2HKbC6d1roXu5sTDThU1JCN4O/JvsKlMrXhN0
X-Received: by 2002:a17:906:7817:: with SMTP id u23-v6mr25900383ejm.145.1548838625949;
        Wed, 30 Jan 2019 00:57:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548838625; cv=none;
        d=google.com; s=arc-20160816;
        b=vxMW31KxfcNwJ8w0fCX9XNQlaAIaFgitmF0yU17Ch3uX5EnyNGCWZl5cC0j6bvaaJt
         eJuIXBasADxrTlGZ+qB4dguBh3KbPf/DnvlE6ieR7RDc2csftFMC+DGEds09QR7pilqZ
         hCpCdKPxAbjEP/iMK1R383mMvf9wUAmnwgIlwvuRmtDhLrM98SfqcfuVLW6vOO7L8+0S
         ap19Y00S7II+777lE6O7XaqJqx6RVGkWn0QAL+e45FihER+U1Gn9mzvwrVPhHT4wwOmY
         fHr1rQNOmowXH8aILEvCuHL1q/32qdYUQKGjikbB3KMQmZvoHSNzOaAVd9jK0ruXJ1k6
         KjbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=lCxabxsVWTynqe1k7NVN/+sCJlTo9JfxvTP0DnwspPg=;
        b=gvW5wB0IpK8tVFhggVXArcI2hnx/+F2ropc7WmCQilr/h2XvmkqI6h5ujFd3SqxkS8
         CRRj+/mCGpTTBRIPp+tR2ypDQ9FuSfK9iqXS4XJ8U00mHqak/Jn3RqEKWsQJ/hTYuTY0
         79k3roDaWidW64H0dS9nDFS1KvHYEkhoCDhwuPvdYqq/EgOC8m5tcCeu/7YFtugNrfYc
         E5B+TzkXjdGOde7/IXt9Bxm0/02pmF/8ZGKA3wVMj5jYEW4NwY4POGEGGnEWECVmqryk
         lEoXmXl8j2S7CTS2ozYFFt+2hyqpuHWOZvtHBXBRaJha/lNDnnP95SuMlKbZho7kW0H8
         SblA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of julien.thierry@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.thierry@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 34si728572edp.262.2019.01.30.00.57.05
        for <linux-mm@kvack.org>;
        Wed, 30 Jan 2019 00:57:05 -0800 (PST)
Received-SPF: pass (google.com: domain of julien.thierry@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of julien.thierry@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.thierry@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2D6FAA78;
	Wed, 30 Jan 2019 00:57:04 -0800 (PST)
Received: from [10.1.197.45] (e112298-lin.cambridge.arm.com [10.1.197.45])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E63293F557;
	Wed, 30 Jan 2019 00:57:01 -0800 (PST)
Subject: Re: [PATCH v8 24/26] arm64: acpi: Make apei_claim_sea() synchronise
 with APEI's irq work
To: James Morse <james.morse@arm.com>, linux-acpi@vger.kernel.org
Cc: Rafael Wysocki <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>,
 Marc Zyngier <marc.zyngier@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Dongjiu Geng <gengdongjiu@huawei.com>,
 linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>,
 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kvmarm@lists.cs.columbia.edu,
 linux-arm-kernel@lists.infradead.org, Len Brown <lenb@kernel.org>
References: <20190129184902.102850-1-james.morse@arm.com>
 <20190129184902.102850-25-james.morse@arm.com>
From: Julien Thierry <julien.thierry@arm.com>
Message-ID: <858ac1d3-8b21-d3a7-d7dd-3d95294a9bea@arm.com>
Date: Wed, 30 Jan 2019 08:56:59 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20190129184902.102850-25-james.morse@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi James,

On 29/01/2019 18:49, James Morse wrote:
> APEI is unable to do all of its error handling work in nmi-context, so
> it defers non-fatal work onto the irq_work queue. arch_irq_work_raise()
> sends an IPI to the calling cpu, but this is not guaranteed to be taken
> before returning to user-space.
> 
> Unless the exception interrupted a context with irqs-masked,
> irq_work_run() can run immediately. Otherwise return -EINPROGRESS to
> indicate ghes_notify_sea() found some work to do, but it hasn't
> finished yet.
> 
> With this apei_claim_sea() returning '0' means this external-abort was
> also notification of a firmware-first RAS error, and that APEI has
> processed the CPER records.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
> Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> CC: Xie XiuQi <xiexiuqi@huawei.com>
> CC: gengdongjiu <gengdongjiu@huawei.com>
> 
> ---
> Changes since v7:
>  * Added Catalin's ack, then:
>  * Added __irq_enter()/exit() calls so if we interrupted preemptible code, the
>    preempt count matches what other irq-work expects.
>  * Changed the 'if (!arch_irqs_disabled_flags(interrupted_flags))' test to be
>    safe before/after Julien's PMR series.
> 
> Changes since v6:
>  * Added pr_warn() for the EINPROGRESS case so panic-tracebacks show
>    'APEI was here'.
>  * Tinkered with the commit message
> 
> Changes since v2:
>  * Removed IS_ENABLED() check, done by the caller unless we have a dummy
>    definition.
> ---
>  arch/arm64/kernel/acpi.c | 23 +++++++++++++++++++++++
>  arch/arm64/mm/fault.c    |  9 ++++-----
>  2 files changed, 27 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
> index 803f0494dd3e..8288ae0c8f3b 100644
> --- a/arch/arm64/kernel/acpi.c
> +++ b/arch/arm64/kernel/acpi.c
> @@ -22,6 +22,7 @@
>  #include <linux/init.h>
>  #include <linux/irq.h>
>  #include <linux/irqdomain.h>
> +#include <linux/irq_work.h>
>  #include <linux/memblock.h>
>  #include <linux/of_fdt.h>
>  #include <linux/smp.h>
> @@ -268,12 +269,17 @@ pgprot_t __acpi_get_mem_attribute(phys_addr_t addr)
>  int apei_claim_sea(struct pt_regs *regs)
>  {
>  	int err = -ENOENT;
> +	bool return_to_irqs_enabled;
>  	unsigned long current_flags;
>  
>  	if (!IS_ENABLED(CONFIG_ACPI_APEI_GHES))
>  		return err;
>  
>  	current_flags = arch_local_save_flags();
> +	return_to_irqs_enabled = !irqs_disabled_flags(current_flags);
> +
> +	if (regs)
> +		return_to_irqs_enabled = interrupts_enabled(regs);
>  
>  	/*
>  	 * SEA can interrupt SError, mask it and describe this as an NMI so
> @@ -283,6 +289,23 @@ int apei_claim_sea(struct pt_regs *regs)
>  	nmi_enter();
>  	err = ghes_notify_sea();
>  	nmi_exit();
> +
> +	/*
> +	 * APEI NMI-like notifications are deferred to irq_work. Unless
> +	 * we interrupted irqs-masked code, we can do that now.
> +	 */
> +	if (!err) {
> +		if (return_to_irqs_enabled) {
> +			local_daif_restore(DAIF_PROCCTX_NOIRQ);
> +			__irq_enter();
> +			irq_work_run();
> +			__irq_exit();
> +		} else {
> +			pr_warn("APEI work queued but not completed");
> +			err = -EINPROGRESS;
> +		}
> +	}
> +

Reviewed-by: Julien Thierry <julien.thierry@arm.com>

Cheers,

-- 
Julien Thierry

