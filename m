Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4D38E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 13:04:46 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y199-v6so1523851wmc.6
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 10:04:46 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id o13-v6si5321486wrm.251.2018.09.28.10.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 10:04:45 -0700 (PDT)
Date: Fri, 28 Sep 2018 19:04:46 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 04/18] ACPI / APEI: Switch NOTIFY_SEA to use the
 estatus queue
Message-ID: <20180928170446.GE20768@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-5-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-5-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Sep 21, 2018 at 11:16:51PM +0100, James Morse wrote:
> Now that the estatus queue can be used by more than one notification
> method, we can move notifications that have NMI-like behaviour over to
> it, and start abstracting GHES's single in_nmi() path.
> 
> Switch NOTIFY_SEA over to use the estatus queue. This makes it behave
> in the same way as x86's NOTIFY_NMI.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
> Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
> ---
>  drivers/acpi/apei/ghes.c | 23 +++++++++++------------
>  1 file changed, 11 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index d7c46236b353..150fb184c7cb 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -58,6 +58,10 @@
>  
>  #define GHES_PFX	"GHES: "
>  
> +#if defined(CONFIG_HAVE_ACPI_APEI_NMI) || defined(CONFIG_ACPI_APEI_SEA)
> +#define WANT_NMI_ESTATUS_QUEUE	1
> +#endif

Is that just so that you have shorter ifdeffery lines? Because if so, an
additional level of indirection is silly. Or maybe there's more coming -
I'll see when I continue going through this set. :)

Otherwise looks good - trying to reuse the facilities and all. Better. :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
