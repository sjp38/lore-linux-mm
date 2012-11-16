Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C27CC6B0068
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 17:53:58 -0500 (EST)
Message-ID: <1353105943.12509.60.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 0/3] acpi: Introduce prepare_remove device
 operation
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 16 Nov 2012 15:45:43 -0700
In-Reply-To: <1446291.TgLDtXqY7q@vostro.rjw.lan>
References: 
	<1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <1446291.TgLDtXqY7q@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Fri, 2012-11-16 at 22:43 +0100, Rafael J. Wysocki wrote:
> On Thursday, November 15, 2012 11:22:47 AM Vasilis Liaskovitis wrote:
> > As discussed in https://patchwork.kernel.org/patch/1581581/
> > the driver core remove function needs to always succeed. This means we need
> > to know that the device can be successfully removed before acpi_bus_trim / 
> > acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
> > eject or driver unbind of memory devices fails e.g with:
> > 
> > echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> > echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> > 
> > since the ACPI core goes ahead and ejects the device regardless of whether the
> > the memory is still in use or not.
> 
> So the question is, does the ACPI core have to do that and if so, then why?

The problem is that acpi_memory_devcie_remove() can fail.  However,
device_release_driver() is a void function, so it cannot report its
error.  Here are function flows for SCI, sysfs eject and unbind.

SCI & sysfs eject
===
acpi_bus_hot_remove_device()
  acpi_bus_trim()
    acpi_bus_remove()
      device_release_driver()  // Driver Core
        acpi_device_remove()
          acpi_memory_device_remove()  // ACPI Driver
  acpi_evaluate_object(handle, "_EJ0",,)  // Eject


sysfs unbind
===
driver_unbind()  // Driver Core
  device_release_driver()  // Driver Core
    acpi_device_remove()
      acpi_memory_device_remove()  // ACPI Driver
  put_device()
  bus_put()

Yasuaki's approach was to change device_release_driver() to report an
error so that acpi_bus_hot_remove_device() can fail without ejecting.
Vasilis's approach was to call ACPI driver via a new interface before
device_release_driver(), but still requires to change driver_unbind().
It looks to me that some changes to driver core is needed...

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
