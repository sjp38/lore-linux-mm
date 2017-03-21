Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26A136B0353
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:14:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b140so3845643wme.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 09:14:19 -0700 (PDT)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id k6si20476761wma.165.2017.03.21.09.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 09:14:17 -0700 (PDT)
Date: Wed, 22 Mar 2017 00:13:56 +0800
From: joeyli <jlee@suse.com>
Subject: Re: memory hotplug and force_remove
Message-ID: <20170321161356.GA20835@linux-l9pv.suse>
References: <20170320192938.GA11363@dhcp22.suse.cz>
 <2735706.OR0SQDpVy6@aspire.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2735706.OR0SQDpVy6@aspire.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Michal Hocko <mhocko@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Mon, Mar 20, 2017 at 10:24:42PM +0100, Rafael J. Wysocki wrote:
> On Monday, March 20, 2017 03:29:39 PM Michal Hocko wrote:
> > Hi Rafael,
> 
> Hi,
> 
> > we have been chasing the following BUG() triggering during the memory
> > hotremove (remove_memory):
> > 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> > 				check_memblock_offlined_cb);
> > 	if (ret)
> > 		BUG();
> > 
> > and it took a while to learn that the issue is caused by
> > /sys/firmware/acpi/hotplug/force_remove being enabled. I was really
> > surprised to see such an option because at least for the memory hotplug
> > it cannot work at all. Memory hotplug fails when the memory is still
> > in use. Even if we do not BUG() here enforcing the hotplug operation
> > will lead to problematic behavior later like crash or a silent memory
> > corruption if the memory gets onlined back and reused by somebody else.
> > 
> > I am wondering what was the motivation for introducing this behavior and
> > whether there is a way to disallow it for memory hotplug. Or maybe drop
> > it completely. What would break in such a case?
> 
> Honestly, I don't remember from the top of my head and I haven't looked at
> that code for several months.
> 
> I need some time to recall that.
>

IMHO. 
In the second pass offline in acpi_scan_try_to_offline(), when force_remove flag
enabled, it's still run offline on the parent device even there have any child
device offline failed. And it doesn't return the error from acpi_bus_offline() to
caller. 

	errdev = NULL;
	acpi_walk_namespace(ACPI_TYPE_ANY, handle, ACPI_UINT32_MAX, 
			    NULL, acpi_bus_offline, (void *)true,
			    (void **)&errdev);
	if (!errdev || acpi_force_hot_remove)                 
		acpi_bus_offline(handle, 0, (void *)true, 
				 (void **)&errdev);

In this situation, the parent device or any child device may not really
offline successfully. But acpi_scan_hot_remove, the caller doesn't know that.
Then it cause the later acpi_bus_trim() process failed.

acpi_bus_trim()
	-> handler->detach()
		-> acpi_memory_device_remove()
			-> remove_memory() -> BUG()  

because some memory doesn't really offline. 

Thanks a lot!
Joey Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
