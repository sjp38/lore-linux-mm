Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id D6E526B0255
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 15:49:59 -0400 (EDT)
Received: by lacrr8 with SMTP id rr8so30255777lac.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:49:59 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id pt4si2357671lbb.117.2015.09.25.12.49.57
        for <linux-mm@kvack.org>;
        Fri, 25 Sep 2015 12:49:58 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Fri, 25 Sep 2015 22:18:13 +0200
Message-ID: <1460975.zriLPuubXp@vostro.rjw.lan>
In-Reply-To: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linaro-kernel@lists.linaro.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org, linux-edac@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Friday, September 25, 2015 09:41:37 AM Viresh Kumar wrote:
> global_lock is defined as an unsigned long and accessing only its lower
> 32 bits from sysfs is incorrect, as we need to consider other 32 bits
> for big endian 64 bit systems. There are no such platforms yet, but the
> code needs to be robust for such a case.
> 
> Fix that by passing a local variable to debugfs_create_bool() and
> assigning its value to global_lock later.
> 
> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Greg, please take this one if the [2/2] looks good to you.

> ---
> V3->V4:
> - Create a local variable instead of changing type of global_lock
>   (Rafael)
> - Drop the stable tag
> - BCC'd a lot of people (rather than cc'ing them) to make sure
>   - the series reaches them
>   - mailing lists do not block the patchset due to long cc list
>   - and we don't spam the BCC'd people for every reply
> ---
>  drivers/acpi/ec_sys.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/acpi/ec_sys.c b/drivers/acpi/ec_sys.c
> index b4c216bab22b..b44b91331a56 100644
> --- a/drivers/acpi/ec_sys.c
> +++ b/drivers/acpi/ec_sys.c
> @@ -110,6 +110,7 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec, unsigned int ec_device_count)
>  	struct dentry *dev_dir;
>  	char name[64];
>  	umode_t mode = 0400;
> +	u32 val;
>  
>  	if (ec_device_count == 0) {
>  		acpi_ec_debugfs_dir = debugfs_create_dir("ec", NULL);
> @@ -127,10 +128,11 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec, unsigned int ec_device_count)
>  
>  	if (!debugfs_create_x32("gpe", 0444, dev_dir, (u32 *)&first_ec->gpe))
>  		goto error;
> -	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir,
> -				 (u32 *)&first_ec->global_lock))
> +	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir, &val))
>  		goto error;
>  
> +	first_ec->global_lock = val;
> +
>  	if (write_support)
>  		mode = 0600;
>  	if (!debugfs_create_file("io", mode, dev_dir, ec, &acpi_ec_io_ops))
> 

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
