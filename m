Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id AA8916B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:09:17 -0500 (EST)
Date: Tue, 29 Jan 2013 23:48:59 -0500
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug
 framework
Message-ID: <20130130044859.GD30002@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
 <5036592.TuXAnGzk4M@vostro.rjw.lan>
 <1358177628.14145.49.camel@misato.fc.hp.com>
 <2154272.qDAyBlTr8z@vostro.rjw.lan>
 <1358190124.14145.79.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358190124.14145.79.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Mon, Jan 14, 2013 at 12:02:04PM -0700, Toshi Kani wrote:
> On Mon, 2013-01-14 at 19:48 +0100, Rafael J. Wysocki wrote:
> > On Monday, January 14, 2013 08:33:48 AM Toshi Kani wrote:
> > > On Fri, 2013-01-11 at 22:23 +0100, Rafael J. Wysocki wrote:
> > > > On Thursday, January 10, 2013 04:40:19 PM Toshi Kani wrote:
> > > > > Added include/linux/sys_hotplug.h, which defines the system device
> > > > > hotplug framework interfaces used by the framework itself and
> > > > > handlers.
> > > > > 
> > > > > The order values define the calling sequence of handlers.  For add
> > > > > execute, the ordering is ACPI->MEM->CPU.  Memory is onlined before
> > > > > CPU so that threads on new CPUs can start using their local memory.
> > > > > The ordering of the delete execute is symmetric to the add execute.
> > > > > 
> > > > > struct shp_request defines a hot-plug request information.  The
> > > > > device resource information is managed with a list so that a single
> > > > > request may target to multiple devices.
> > > > > 
> > >  :
> > > > > +
> > > > > +struct shp_device {
> > > > > +	struct list_head	list;
> > > > > +	struct device		*device;
> > > > > +	enum shp_class		class;
> > > > > +	union shp_dev_info	info;
> > > > > +};
> > > > > +
> > > > > +/*
> > > > > + * Hot-plug request
> > > > > + */
> > > > > +struct shp_request {
> > > > > +	/* common info */
> > > > > +	enum shp_operation	operation;	/* operation */
> > > > > +
> > > > > +	/* hot-plug event info: only valid for hot-plug operations */
> > > > > +	void			*handle;	/* FW handle */
> > > > 
> > > > What's the role of handle here?
> > > 
> > > On ACPI-based platforms, the handle keeps a notified ACPI handle when a
> > > hot-plug request is made.  ACPI bus handlers, acpi_add_execute() /
> > > acpi_del_execute(), then scans / trims ACPI devices from the handle.
> > 
> > OK, so this is ACPI-specific and should be described as such.
> 
> Other FW interface I know is parisc, which has mod_index (module index)
> to identify a unique object, just like what ACPI handle does.  The
> handle can keep the mod_index as an opaque value as well.  But as you
> said, I do not know if the handle works for all other FWs.  So, I will
> add descriptions, such that the hot-plug event info is modeled after
> ACPI and may need to be revisited when supporting other FW.

Please make it a "real" pointer, and not a void *, those shouldn't be
used at all if possible.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
