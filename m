Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 371F36B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 06:49:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l95so15364645wrc.12
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 03:49:28 -0700 (PDT)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id 66si7624953wrb.134.2017.03.31.03.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 03:49:26 -0700 (PDT)
Date: Fri, 31 Mar 2017 18:49:05 +0800
From: joeyli <jlee@suse.com>
Subject: Re: memory hotplug and force_remove
Message-ID: <20170331104905.GA28365@linux-l9pv.suse>
References: <20170320192938.GA11363@dhcp22.suse.cz>
 <2735706.OR0SQDpVy6@aspire.rjw.lan>
 <20170328075808.GB18241@dhcp22.suse.cz>
 <2203902.lsAnRkUs2Y@aspire.rjw.lan>
 <20170331083017.GK27098@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170331083017.GK27098@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Kani Toshimitsu <toshi.kani@hpe.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

Hi Michal,

On Fri, Mar 31, 2017 at 10:30:17AM +0200, Michal Hocko wrote:
> [Fixed up email address of Toshimitsu - the email thread starts
> http://lkml.kernel.org/r/20170320192938.GA11363@dhcp22.suse.cz]
> 
> On Tue 28-03-17 17:22:58, Rafael J. Wysocki wrote:
> > On Tuesday, March 28, 2017 09:58:08 AM Michal Hocko wrote:
> > > On Mon 20-03-17 22:24:42, Rafael J. Wysocki wrote:
> > > > On Monday, March 20, 2017 03:29:39 PM Michal Hocko wrote:
> > > > > Hi Rafael,
> > > > 
> > > > Hi,
> > > > 
> > > > > we have been chasing the following BUG() triggering during the memory
> > > > > hotremove (remove_memory):
> > > > > 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> > > > > 				check_memblock_offlined_cb);
> > > > > 	if (ret)
> > > > > 		BUG();
> > > > > 
> > > > > and it took a while to learn that the issue is caused by
> > > > > /sys/firmware/acpi/hotplug/force_remove being enabled. I was really
> > > > > surprised to see such an option because at least for the memory hotplug
> > > > > it cannot work at all. Memory hotplug fails when the memory is still
> > > > > in use. Even if we do not BUG() here enforcing the hotplug operation
> > > > > will lead to problematic behavior later like crash or a silent memory
> > > > > corruption if the memory gets onlined back and reused by somebody else.
> > > > > 
> > > > > I am wondering what was the motivation for introducing this behavior and
> > > > > whether there is a way to disallow it for memory hotplug. Or maybe drop
> > > > > it completely. What would break in such a case?
> > > > 
> > > > Honestly, I don't remember from the top of my head and I haven't looked at
> > > > that code for several months.
> > > > 
> > > > I need some time to recall that.
> > > 
> > > Did you have any chance to look into this?
> > 
> > Well, yes.
> > 
> > It looks like that was added for some people who depended on the old behavior
> > at that time.
> > 
> > I guess we can try to drop it and see what happpens. :-)
> 
> OK, so what do you think about the following? It is based on the current
> linux-next and I have only compile tested it.
> ---
> >From 6c5ae594ce938a1ae9b9718958401682bfab3980 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 31 Mar 2017 10:08:41 +0200
> Subject: [PATCH] acpi: drop support for force_remove
> 
> /sys/firmware/acpi/hotplug/force_remove was presumably added to support
> auto offlining in the past. This is, however, inherently dangerous for
> some hotplugable resources like memory. The memory offlining fails when
> the memory is still in use and cannot be dropped or migrated. If we
> ignore the failure we are basically allowing for subtle memory
> corruption or a crash.
> 
> We have actually noticed the later while hitting BUG() during the memory
> hotremove (remove_memory):
> 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> 			check_memblock_offlined_cb);
> 	if (ret)
> 		BUG();
> 
> it took us quite non-trivial time realize that the customer had
> force_remove enabled. Even if the BUG was removed here and we could
> propagate the error up the call chain it wouldn't help at all because
> then we would hit a crash or a memory corruption later and harder to
> debug. So force_remove is unfixable for the memory hotremove. We haven't
> checked other hotplugable resources to be prone to a similar problems.
> 
> Remove the force_remove functionality because it is not fixable currently.
> Keep the sysfs file and report an error if somebody tries to enable it.
> Encourage users to report about the missing functionality and work with
> them with an alternative solution.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  Documentation/ABI/obsolete/sysfs-firmware-acpi |  8 ++++++++
>  Documentation/ABI/testing/sysfs-firmware-acpi  | 10 ----------
>  drivers/acpi/internal.h                        |  2 --
>  drivers/acpi/scan.c                            | 17 +++--------------
>  drivers/acpi/sysfs.c                           |  9 +++++----
>  5 files changed, 16 insertions(+), 30 deletions(-)
>  create mode 100644 Documentation/ABI/obsolete/sysfs-firmware-acpi
> 
> diff --git a/Documentation/ABI/obsolete/sysfs-firmware-acpi b/Documentation/ABI/obsolete/sysfs-firmware-acpi
> new file mode 100644
> index 000000000000..6715a71bec3d
> --- /dev/null
> +++ b/Documentation/ABI/obsolete/sysfs-firmware-acpi
> @@ -0,0 +1,8 @@
> +What:		/sys/firmware/acpi/hotplug/force_remove
> +Date:		Mar 2017
> +Contact:	Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> +Description:
> +		Since the force_remove is inherently broken and dangerous to
> +		use for some hotplugable resources like memory (because ignoring
> +		the offline failure might lead to memory corruption and crashes)
> +		enabling this knob is not safe and thus unsupported.
> diff --git a/Documentation/ABI/testing/sysfs-firmware-acpi b/Documentation/ABI/testing/sysfs-firmware-acpi
> index c7fc72d4495c..613f42a9d5cd 100644
> --- a/Documentation/ABI/testing/sysfs-firmware-acpi
> +++ b/Documentation/ABI/testing/sysfs-firmware-acpi
> @@ -44,16 +44,6 @@ Contact:	Rafael J. Wysocki <rafael.j.wysocki@intel.com>
>  		or 0 (unset).  Attempts to write any other values to it will
>  		cause -EINVAL to be returned.
>  
> -What:		/sys/firmware/acpi/hotplug/force_remove
> -Date:		May 2013
> -Contact:	Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> -Description:
> -		The number in this file (0 or 1) determines whether (1) or not
> -		(0) the ACPI subsystem will allow devices to be hot-removed even
> -		if they cannot be put offline gracefully (from the kernel's
> -		viewpoint).  That number can be changed by writing a boolean
> -		value to this file.
> -
>  What:		/sys/firmware/acpi/interrupts/
>  Date:		February 2008
>  Contact:	Len Brown <lenb@kernel.org>
> diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
> index f15900132912..66229ffa909b 100644
> --- a/drivers/acpi/internal.h
> +++ b/drivers/acpi/internal.h
> @@ -65,8 +65,6 @@ static inline void acpi_cmos_rtc_init(void) {}
>  #endif
>  int acpi_rev_override_setup(char *str);
>  
> -extern bool acpi_force_hot_remove;
> -
>  void acpi_sysfs_add_hotplug_profile(struct acpi_hotplug_profile *hotplug,
>  				    const char *name);
>  int acpi_scan_add_handler_with_hotplug(struct acpi_scan_handler *handler,
> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
> index 192691880d55..a8d893fcedca 100644
> --- a/drivers/acpi/scan.c
> +++ b/drivers/acpi/scan.c
> @@ -30,12 +30,6 @@ extern struct acpi_device *acpi_root;
>  
>  #define INVALID_ACPI_HANDLE	((acpi_handle)empty_zero_page)
>  
> -/*
> - * If set, devices will be hot-removed even if they cannot be put offline
> - * gracefully (from the kernel's standpoint).
> - */
> -bool acpi_force_hot_remove;
> -
>  static const char *dummy_hid = "device";
>  
>  static LIST_HEAD(acpi_dep_list);
> @@ -170,9 +164,6 @@ static acpi_status acpi_bus_offline(acpi_handle handle, u32 lvl, void *data,
>  			pn->put_online = false;
>  		}
>  		ret = device_offline(pn->dev);
> -		if (acpi_force_hot_remove)
> -			continue;
> -
>  		if (ret >= 0) {
>  			pn->put_online = !ret;
>  		} else {
> @@ -241,11 +232,10 @@ static int acpi_scan_try_to_offline(struct acpi_device *device)
>  		acpi_walk_namespace(ACPI_TYPE_ANY, handle, ACPI_UINT32_MAX,
>  				    NULL, acpi_bus_offline, (void *)true,
>  				    (void **)&errdev);
> -		if (!errdev || acpi_force_hot_remove)
> +		if (!errdev)
>  			acpi_bus_offline(handle, 0, (void *)true,
>  					 (void **)&errdev);
> -
> -		if (errdev && !acpi_force_hot_remove) {
> +		else {
              ^^^^^^^^^^^^^
Here should still checks the parent's errdev state then rollback
parent/children to online state:

-		if (errdev && !acpi_force_hot_remove) {
+		if (errdev) {

>  			dev_warn(errdev, "Offline failed.\n");
>  			acpi_bus_online(handle, 0, NULL, NULL);
>  			acpi_walk_namespace(ACPI_TYPE_ANY, handle,
[...snip]

Thanks a lot!
Joey Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
