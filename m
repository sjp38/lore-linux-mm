Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 47A806B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 09:48:26 -0400 (EDT)
Received: by lahh2 with SMTP id h2so136139357lah.0
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 06:48:25 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id je10si5975810lbc.77.2015.09.27.06.48.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Sep 2015 06:48:24 -0700 (PDT)
Received: by lahh2 with SMTP id h2so136139184lah.0
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 06:48:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8d3d3428c3a36f821e4c3d8563d094ca4b4763fd.1443304934.git.viresh.kumar@linaro.org>
References: <8d3d3428c3a36f821e4c3d8563d094ca4b4763fd.1443304934.git.viresh.kumar@linaro.org>
Date: Sun, 27 Sep 2015 15:48:24 +0200
Message-ID: <CAJZ5v0imYBPVNfVjkgX1r8a1x6QbY4LtRcS7BNsGzg5=yuPRfA@mail.gmail.com>
Subject: Re: [PATCH V5 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
From: "Rafael J. Wysocki" <rafael@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Lists linaro-kernel <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, netdev@vger.kernel.org, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>

On Sun, Sep 27, 2015 at 12:04 AM, Viresh Kumar <viresh.kumar@linaro.org> wrote:
> global_lock is defined as an unsigned long and accessing only its lower
> 32 bits from sysfs is incorrect, as we need to consider other 32 bits
> for big endian 64-bit systems. There are no such platforms yet, but the
> code needs to be robust for such a case.
>
> Fix that by changing type of 'global_lock' to u32.
>
> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Greg, please take this one along with the [2/2] if that one looks good to you.

> ---
> BCC'd a lot of people (rather than cc'ing them) to make sure
> - the series reaches them
> - mailing lists do not block the patchset due to long cc list
> - and we don't spam the BCC'd people for every reply
>
> V4->V5:
> - Switch back to the original solution of making global_lock u32.
> ---
>  drivers/acpi/ec_sys.c   | 2 +-
>  drivers/acpi/internal.h | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/acpi/ec_sys.c b/drivers/acpi/ec_sys.c
> index b4c216bab22b..bea8e425a8de 100644
> --- a/drivers/acpi/ec_sys.c
> +++ b/drivers/acpi/ec_sys.c
> @@ -128,7 +128,7 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec, unsigned int ec_device_count)
>         if (!debugfs_create_x32("gpe", 0444, dev_dir, (u32 *)&first_ec->gpe))
>                 goto error;
>         if (!debugfs_create_bool("use_global_lock", 0444, dev_dir,
> -                                (u32 *)&first_ec->global_lock))
> +                                &first_ec->global_lock))
>                 goto error;
>
>         if (write_support)
> diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
> index 9e426210c2a8..9db196de003c 100644
> --- a/drivers/acpi/internal.h
> +++ b/drivers/acpi/internal.h
> @@ -138,7 +138,7 @@ struct acpi_ec {
>         unsigned long gpe;
>         unsigned long command_addr;
>         unsigned long data_addr;
> -       unsigned long global_lock;
> +       u32 global_lock;
>         unsigned long flags;
>         unsigned long reference_count;
>         struct mutex mutex;
> --
> 2.4.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
