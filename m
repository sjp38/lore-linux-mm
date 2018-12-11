Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF488E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:48:13 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id w17so871208wmc.6
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:48:13 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id f18si321994wme.168.2018.12.11.08.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 08:48:11 -0800 (PST)
Date: Tue, 11 Dec 2018 17:48:02 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 04/25] ACPI / APEI: Make hest.c manage the estatus
 memory pool
Message-ID: <20181211164802.GI27375@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-5-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-5-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:52PM +0000, James Morse wrote:
> ghes.c has a memory pool it uses for the estatus cache and the estatus
> queue. The cache is initialised when registering the platform driver.
> For the queue, an NMI-like notification has to grow/shrink the pool
> as it is registered and unregistered.
> 
> This is all pretty noisy when adding new NMI-like notifications, it
> would be better to replace this with a static pool size based on the
> number of users.
> 
> As a precursor, move the call that creates the pool from ghes_init(),
> into hest.c. Later this will take the number of ghes entries and
> consolidate the queue allocations.
> Remove ghes_estatus_pool_exit() as hest.c doesn't have anywhere to put
> this.
> 
> The pool is now initialised as part of ACPI's subsys_initcall():
> (acpi_init(), acpi_scan_init(), acpi_pci_root_init(), acpi_hest_init())
> Before this patch it happened later as a GHES specific device_initcall().
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 33 ++++++---------------------------
>  drivers/acpi/apei/hest.c |  5 +++++
>  include/acpi/ghes.h      |  2 ++
>  3 files changed, 13 insertions(+), 27 deletions(-)

...

> diff --git a/drivers/acpi/apei/hest.c b/drivers/acpi/apei/hest.c
> index b1e9f81ebeea..da5fabaeb48f 100644
> --- a/drivers/acpi/apei/hest.c
> +++ b/drivers/acpi/apei/hest.c
> @@ -32,6 +32,7 @@
>  #include <linux/io.h>
>  #include <linux/platform_device.h>
>  #include <acpi/apei.h>
> +#include <acpi/ghes.h>
>  
>  #include "apei-internal.h"
>  
> @@ -200,6 +201,10 @@ static int __init hest_ghes_dev_register(unsigned int ghes_count)
>  	if (!ghes_arr.ghes_devs)
>  		return -ENOMEM;
>  
> +	rc = ghes_estatus_pool_init();
> +	if (rc)
> +		goto out;

Right, this happens before...

> +
>  	rc = apei_hest_parse(hest_parse_ghes, &ghes_arr);

... this but do we even want to do any memory allocations if we don't
have any HEST tables or we've been disabled by hest_disable?

IOW, we should swap those two calls, methinks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
