Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 312C26B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 06:55:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id t30so15193554wrc.15
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 03:55:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w6si2894177wmf.145.2017.03.31.03.55.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 03:55:09 -0700 (PDT)
Date: Fri, 31 Mar 2017 12:55:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory hotplug and force_remove
Message-ID: <20170331105505.GM27098@dhcp22.suse.cz>
References: <20170320192938.GA11363@dhcp22.suse.cz>
 <2735706.OR0SQDpVy6@aspire.rjw.lan>
 <20170328075808.GB18241@dhcp22.suse.cz>
 <2203902.lsAnRkUs2Y@aspire.rjw.lan>
 <20170331083017.GK27098@dhcp22.suse.cz>
 <20170331104905.GA28365@linux-l9pv.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170331104905.GA28365@linux-l9pv.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joeyli <jlee@suse.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Kani Toshimitsu <toshi.kani@hpe.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri 31-03-17 18:49:05, Joey Lee wrote:
> Hi Michal,
> 
> On Fri, Mar 31, 2017 at 10:30:17AM +0200, Michal Hocko wrote:
[...]
> > @@ -241,11 +232,10 @@ static int acpi_scan_try_to_offline(struct acpi_device *device)
> >  		acpi_walk_namespace(ACPI_TYPE_ANY, handle, ACPI_UINT32_MAX,
> >  				    NULL, acpi_bus_offline, (void *)true,
> >  				    (void **)&errdev);
> > -		if (!errdev || acpi_force_hot_remove)
> > +		if (!errdev)
> >  			acpi_bus_offline(handle, 0, (void *)true,
> >  					 (void **)&errdev);
> > -
> > -		if (errdev && !acpi_force_hot_remove) {
> > +		else {
>               ^^^^^^^^^^^^^
> Here should still checks the parent's errdev state then rollback
> parent/children to online state:
> 
> -		if (errdev && !acpi_force_hot_remove) {
> +		if (errdev) {

You are right, I have missed that acpi_bus_offline modifies errdev.
Thanks for spotting that! Updated patch is below.
---
