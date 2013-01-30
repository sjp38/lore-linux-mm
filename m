Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id DEE3D6B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:09:23 -0500 (EST)
Date: Tue, 29 Jan 2013 23:51:53 -0500
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 02/12] ACPI: Add sys_hotplug.h for system device
 hotplug framework
Message-ID: <20130130045153.GE30002@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
 <3236298.SULt2IKQv6@vostro.rjw.lan>
 <1358188929.14145.69.camel@misato.fc.hp.com>
 <4116384.4pypaK248y@vostro.rjw.lan>
 <1358191290.14145.88.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358191290.14145.88.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Mon, Jan 14, 2013 at 12:21:30PM -0700, Toshi Kani wrote:
> On Mon, 2013-01-14 at 20:07 +0100, Rafael J. Wysocki wrote:
> > On Monday, January 14, 2013 11:42:09 AM Toshi Kani wrote:
> > > On Mon, 2013-01-14 at 19:47 +0100, Rafael J. Wysocki wrote:
> > > > On Monday, January 14, 2013 08:53:53 AM Toshi Kani wrote:
> > > > > On Fri, 2013-01-11 at 22:25 +0100, Rafael J. Wysocki wrote:
> > > > > > On Thursday, January 10, 2013 04:40:20 PM Toshi Kani wrote:
> > > > > > > Added include/acpi/sys_hotplug.h, which is ACPI-specific system
> > > > > > > device hotplug header and defines the order values of ACPI-specific
> > > > > > > handlers.
> > > > > > > 
> > > > > > > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > > > > > > ---
> > > > > > >  include/acpi/sys_hotplug.h |   48 ++++++++++++++++++++++++++++++++++++++++++++
> > > > > > >  1 file changed, 48 insertions(+)
> > > > > > >  create mode 100644 include/acpi/sys_hotplug.h
> > > > > > > 
> > > > > > > diff --git a/include/acpi/sys_hotplug.h b/include/acpi/sys_hotplug.h
> > > > > > > new file mode 100644
> > > > > > > index 0000000..ad80f61
> > > > > > > --- /dev/null
> > > > > > > +++ b/include/acpi/sys_hotplug.h
> > > > > > > @@ -0,0 +1,48 @@
> > > > > > > +/*
> > > > > > > + * sys_hotplug.h - ACPI System device hot-plug framework
> > > > > > > + *
> > > > > > > + * Copyright (C) 2012 Hewlett-Packard Development Company, L.P.
> > > > > > > + *	Toshi Kani <toshi.kani@hp.com>
> > > > > > > + *
> > > > > > > + * This program is free software; you can redistribute it and/or modify
> > > > > > > + * it under the terms of the GNU General Public License version 2 as
> > > > > > > + * published by the Free Software Foundation.
> > > > > > > + */
> > > > > > > +
> > > > > > > +#ifndef _ACPI_SYS_HOTPLUG_H
> > > > > > > +#define _ACPI_SYS_HOTPLUG_H
> > > > > > > +
> > > > > > > +#include <linux/list.h>
> > > > > > > +#include <linux/device.h>
> > > > > > > +#include <linux/sys_hotplug.h>
> > > > > > > +
> > > > > > > +/*
> > > > > > > + * System device hot-plug operation proceeds in the following order.
> > > > > > > + *   Validate phase -> Execute phase -> Commit phase
> > > > > > > + *
> > > > > > > + * The order values below define the calling sequence of ACPI-specific
> > > > > > > + * handlers for each phase in ascending order.  The order value of
> > > > > > > + * platform-neutral handlers are defined in <linux/sys_hotplug.h>.
> > > > > > > + */
> > > > > > > +
> > > > > > > +/* Add Validate order values */
> > > > > > > +#define SHP_ACPI_BUS_ADD_VALIDATE_ORDER		0	/* must be first */
> > > > > > > +
> > > > > > > +/* Add Execute order values */
> > > > > > > +#define SHP_ACPI_BUS_ADD_EXECUTE_ORDER		10
> > > > > > > +#define SHP_ACPI_RES_ADD_EXECUTE_ORDER		20
> > > > > > > +
> > > > > > > +/* Add Commit order values */
> > > > > > > +#define SHP_ACPI_BUS_ADD_COMMIT_ORDER		10
> > > > > > > +
> > > > > > > +/* Delete Validate order values */
> > > > > > > +#define SHP_ACPI_BUS_DEL_VALIDATE_ORDER		0	/* must be first */
> > > > > > > +#define SHP_ACPI_RES_DEL_VALIDATE_ORDER		10
> > > > > > > +
> > > > > > > +/* Delete Execute order values */
> > > > > > > +#define SHP_ACPI_BUS_DEL_EXECUTE_ORDER		100
> > > > > > > +
> > > > > > > +/* Delete Commit order values */
> > > > > > > +#define SHP_ACPI_BUS_DEL_COMMIT_ORDER		100
> > > > > > > +
> > > > > > > +#endif	/* _ACPI_SYS_HOTPLUG_H */
> > > > > > > --
> > > > > > 
> > > > > > Why did you use the particular values above?
> > > > > 
> > > > > The ordering values above are used to define the relative order among
> > > > > handlers.  For instance, the 100 for SHP_ACPI_BUS_DEL_EXECUTE_ORDER can
> > > > > potentially be 21 since it is still larger than 20 for
> > > > > SHP_MEM_DEL_EXECUTE_ORDER defined in linux/sys_hotplug.h.  I picked 100
> > > > > so that more platform-neutral handlers can be added in between 20 and
> > > > > 100 in future.
> > > > 
> > > > I thought so, but I don't think it's a good idea to add gaps like this.
> > > 
> > > OK, I will use an equal gap of 10 for all values.  So, the 100 in the
> > > above example will be changed to 30.  
> > 
> > I wonder why you want to have those gaps at all.
> 
> Oh, I see.  I think some gap is helpful since it allows a new handler to
> come between without recompiling other modules.  For instance, OEM
> vendors may want to add their own handlers with loadable modules after
> the kernel is distributed.

No, we don't support such a model, sorry, just make it a sequence of
numbers and go from there.  If a vendor wants to modify the kernel to
add new values, they can rebuild the core code as well.

I really don't like the whole idea of values in the first place, can't
we just do things in the correct order in the code, and not be driven by
random magic values?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
