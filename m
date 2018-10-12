Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B421A6B0271
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:56:00 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y199-v6so7335053wmc.6
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:56:00 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id p18-v6si1470345wmc.85.2018.10.12.09.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 09:55:59 -0700 (PDT)
Date: Fri, 12 Oct 2018 18:55:53 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 11/18] ACPI / APEI: Remove silent flag from
 ghes_read_estatus()
Message-ID: <20181012165553.GE580@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-12-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-12-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Sep 21, 2018 at 11:16:58PM +0100, James Morse wrote:
> Subsequent patches will split up ghes_read_estatus(), at which
> point passing around the 'silent' flag gets annoying. This is to
> suppress prink() messages, which prior to 42a0bb3f7138 ("printk/nmi:
> generic solution for safe printk in NMI"), were unsafe in NMI context.

Put that commit onto a separate line:

"... which prior to

  42a0bb3f7138 ("printk/nmi: generic solution for safe printk in NMI")

were unsafe ..."

This way it is immediately visible.

In any case, this patch looks like a cleanup so move it to the beginning
of the queue, I'd say.

> We don't need to do this anymore, remove the flag. printk() messages
> are batched in a per-cpu buffer and printed via irq-work, or a call
> back from panic().
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index 586689cbc0fd..ba5344d26a39 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -300,7 +300,7 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
>  
>  static int ghes_read_estatus(struct ghes *ghes,
>  			     struct acpi_hest_generic_status *estatus,
> -			     int silent, int fixmap_idx)
> +			     int fixmap_idx)
>  {
>  	struct acpi_hest_generic *g = ghes->generic;
>  	u64 buf_paddr;
> @@ -309,7 +309,7 @@ static int ghes_read_estatus(struct ghes *ghes,
>  
>  	rc = apei_read(&buf_paddr, &g->error_status_address);
>  	if (rc) {
> -		if (!silent && printk_ratelimit())
> +		if (printk_ratelimit())

Btw, checkpatch complains here:

WARNING: Prefer printk_ratelimited or pr_<level>_ratelimited to printk_ratelimit
#57: FILE: drivers/acpi/apei/ghes.c:312:
+               if (printk_ratelimit())

WARNING: Prefer printk_ratelimited or pr_<level>_ratelimited to printk_ratelimit
#66: FILE: drivers/acpi/apei/ghes.c:345:
+       if (rc && printk_ratelimit())


-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
