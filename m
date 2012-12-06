Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 1849B6B005D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 04:30:26 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so3053960bkc.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 01:30:24 -0800 (PST)
Date: Thu, 6 Dec 2012 10:30:19 +0100
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
Message-ID: <20121206093019.GA4584@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
 <9212118.3s2xH6uJDI@vostro.rjw.lan>
 <1354136568.26955.312.camel@misato.fc.hp.com>
 <4042591.gpFk7OYmph@vostro.rjw.lan>
 <1354150952.26955.377.camel@misato.fc.hp.com>
 <1354151742.26955.385.camel@misato.fc.hp.com>
 <20121129110451.GA639@dhcp-192-168-178-175.profitbricks.localdomain>
 <1354211051.26955.435.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354211051.26955.435.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,
On Thu, Nov 29, 2012 at 10:44:11AM -0700, Toshi Kani wrote:
> On Thu, 2012-11-29 at 12:04 +0100, Vasilis Liaskovitis wrote:
> 
> Yes, that's what I had in mind along with device_lock().  I think the
> lock is necessary to close the window.
> http://www.spinics.net/lists/linux-mm/msg46973.html
> 
> But as I mentioned in other email, I prefer option 3 with
> suppress_bind_attrs.  So, yes, please take a look to see how it works
> out.

I tested the suppress_bind_attrs and it works by simply setting it to true
before driver registration e.g. 

--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -783,7 +783,8 @@ int acpi_bus_register_driver(struct acpi_driver *driver)
 	driver->drv.name = driver->name;
 	driver->drv.bus = &acpi_bus_type;
 	driver->drv.owner = driver->owner;
-
+    if (!strcmp(driver->class, "memory"))
+        driver->drv.suppress_bind_attrs = true;
 	ret = driver_register(&driver->drv);
 	return ret;
 }

No bind/unbind sysfs files are created when using this, as expected.
I assume we only want to suppress for acpi_memhotplug
(class=ACPI_MEMORY_DEVICE_CLASS i.e. "memory") devices.

Is there agreement on what acpi_bus_trim behaviour and rollback (if any) we
want to have for the current ACPI framework (partial trim or full trim on
failure)?

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
