Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 448458E00C7
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:36:58 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id l73so5008555wmb.1
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:36:58 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id z83si529801wmg.180.2018.12.11.10.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 10:36:56 -0800 (PST)
Date: Tue, 11 Dec 2018 19:36:34 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
Message-ID: <20181211183634.GO27375@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-11-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-11-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:58PM +0000, James Morse wrote:
> ACPI has a GHESv2 which is used on hardware reduced platforms to
> explicitly acknowledge that the memory for CPER records has been
> consumed. This lets an external agent know it can re-use this
> memory for something else.
> 
> Previously notify_nmi and the estatus queue didn't do this as
> they were never used on hardware reduced platforms. Once we move
> notify_sea over to use the estatus queue, it may become necessary.
> 
> Add the call. This is safe for use in NMI context as the
> read_ack_register is pre-mapped by ghes_new() before the
> ghes can be added to an RCU list, and then found by the
> notification handler.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index 366dbdd41ef3..15d94373ba72 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -926,6 +926,10 @@ static int _in_nmi_notify_one(struct ghes *ghes)
>  	__process_error(ghes);
>  	ghes_clear_estatus(ghes, buf_paddr);
>  
> +	if (is_hest_type_generic_v2(ghes) && ghes_ack_error(ghes->generic_v2))

Since ghes_ack_error() is always prepended with this check, you could
push it down into the function:

ghes_ack_error(ghes)
...

	if (!is_hest_type_generic_v2(ghes))
		return 0;

and simplify the two callsites :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
