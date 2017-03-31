Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3AD46B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 18:41:02 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 76so17908314lft.18
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 15:41:02 -0700 (PDT)
Received: from cloudserver094114.home.net.pl (cloudserver094114.home.net.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id u6si3984490lff.372.2017.03.31.15.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 Mar 2017 15:41:01 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: memory hotplug and force_remove
Date: Sat, 01 Apr 2017 00:35:16 +0200
Message-ID: <1544048.hoAj1vGYsS@aspire.rjw.lan>
In-Reply-To: <20170331120236.GO27098@dhcp22.suse.cz>
References: <20170320192938.GA11363@dhcp22.suse.cz> <20170331115530.GB28365@linux-l9pv.suse> <20170331120236.GO27098@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: joeyli <jlee@suse.com>, Kani Toshimitsu <toshi.kani@hpe.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Friday, March 31, 2017 02:02:36 PM Michal Hocko wrote:
> On Fri 31-03-17 19:55:30, Joey Lee wrote:
> > On Fri, Mar 31, 2017 at 12:55:05PM +0200, Michal Hocko wrote:
> > > On Fri 31-03-17 18:49:05, Joey Lee wrote:
> > > > Hi Michal,
> > > > 
> > > > On Fri, Mar 31, 2017 at 10:30:17AM +0200, Michal Hocko wrote:
> > > [...]
> > > > > @@ -241,11 +232,10 @@ static int acpi_scan_try_to_offline(struct acpi_device *device)
> > > > >  		acpi_walk_namespace(ACPI_TYPE_ANY, handle, ACPI_UINT32_MAX,
> > > > >  				    NULL, acpi_bus_offline, (void *)true,
> > > > >  				    (void **)&errdev);
> > > > > -		if (!errdev || acpi_force_hot_remove)
> > > > > +		if (!errdev)
> > > > >  			acpi_bus_offline(handle, 0, (void *)true,
> > > > >  					 (void **)&errdev);
> > > > > -
> > > > > -		if (errdev && !acpi_force_hot_remove) {
> > > > > +		else {
> > > >               ^^^^^^^^^^^^^
> > > > Here should still checks the parent's errdev state then rollback
> > > > parent/children to online state:
> > > > 
> > > > -		if (errdev && !acpi_force_hot_remove) {
> > > > +		if (errdev) {
> > > 
> > > You are right, I have missed that acpi_bus_offline modifies errdev.
> > > Thanks for spotting that! Updated patch is below.
> > > ---
> > > >From 8df0abd29988ffb52b6df52407b96d6015861bb7 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Fri, 31 Mar 2017 10:08:41 +0200
> > > Subject: [PATCH] acpi: drop support for force_remove
> > > 
> > > /sys/firmware/acpi/hotplug/force_remove was presumably added to support
> > > auto offlining in the past. This is, however, inherently dangerous for
> > > some hotplugable resources like memory. The memory offlining fails when
> > > the memory is still in use and cannot be dropped or migrated. If we
> > > ignore the failure we are basically allowing for subtle memory
> > > corruption or a crash.
> > > 
> > > We have actually noticed the later while hitting BUG() during the memory
> > > hotremove (remove_memory):
> > > 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> > > 			check_memblock_offlined_cb);
> > > 	if (ret)
> > > 		BUG();
> > > 
> > > it took us quite non-trivial time realize that the customer had
> > > force_remove enabled. Even if the BUG was removed here and we could
> > > propagate the error up the call chain it wouldn't help at all because
> > > then we would hit a crash or a memory corruption later and harder to
> > > debug. So force_remove is unfixable for the memory hotremove. We haven't
> > > checked other hotplugable resources to be prone to a similar problems.
> > > 
> > > Remove the force_remove functionality because it is not fixable currently.
> > > Keep the sysfs file and report an error if somebody tries to enable it.
> > > Encourage users to report about the missing functionality and work with
> > > them with an alternative solution.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > This patch is good to me. Please feel free to add:
> > 
> > Reviewed-by: Lee, Chun-Yi <jlee@suse.com>
> 
> Thanks for the review Joey!

Can you please resend it with a CC to linux-acpi to give the people on that list
a chance to speak up if they have any concerns?

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
