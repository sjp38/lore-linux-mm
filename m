Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E8BA86B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 19:27:26 -0500 (EST)
Message-ID: <1353975541.26955.182.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 26 Nov 2012 17:19:01 -0700
In-Reply-To: <50B3323E.7020907@cn.fujitsu.com>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <1353693037-21704-4-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <50B0F3DF.4000802@gmail.com>
	 <20121126083634.GA4574@dhcp-192-168-178-175.profitbricks.localdomain>
	 <50B3323E.7020907@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Wen Congyang <wencongyang@gmail.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> >> Consider the following sequence of operations for a hotplugged memory
> >> device:
> >>
> >> 1. echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> >> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> >>
> >> If we don't offline/remove the memory, we have no chance to do it in
> >> step 2. After
> >> step2, the memory is used by the kernel, but we have powered off it. It
> >> is very
> >> dangerous.
> > 
> > How does power-off happen after unbind? acpi_eject_store checks for existing
> > driver before taking any action:
> > 
> > #ifndef FORCE_EJECT
> > 	if (acpi_device->driver == NULL) {
> > 		ret = -ENODEV;
> > 		goto err;
> > 	}
> > #endif
> > 
> > FORCE_EJECT is not defined afaict, so the function returns without scheduling
> > acpi_bus_hot_remove_device. Is there another code path that calls power-off?
> 
> Consider the following case:
> 
> We hotremove the memory device by SCI and unbind it from the driver at the same time:
> 
> CPUa                                                  CPUb
> acpi_memory_device_notify()
>                                        unbind it from the driver
>     acpi_bus_hot_remove_device()

Can we make acpi_bus_remove() to fail if a given acpi_device is not
bound with a driver?  If so, can we make the unbind operation to perform
unbind only?

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
