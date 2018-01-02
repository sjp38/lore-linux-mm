Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29F956B0290
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 21:53:30 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 34so21456691plm.23
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 18:53:30 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l14si21444071pgc.608.2018.01.01.18.53.28
        for <linux-mm@kvack.org>;
        Mon, 01 Jan 2018 18:53:28 -0800 (PST)
Date: Tue, 2 Jan 2018 11:54:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: ACPI issues on cold power on [bisected]
Message-ID: <20180102025417.GA20740@js1304-P5Q-DELUXE>
References: <20171208151159.urdcrzl5qpfd6jnu@earth.li>
 <20171222002108.GB1729@js1304-P5Q-DELUXE>
 <20171229163659.c5ccfvww4ebvyz54@earth.li>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171229163659.c5ccfvww4ebvyz54@earth.li>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan McDowell <noodles@earth.li>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Fri, Dec 29, 2017 at 04:36:59PM +0000, Jonathan McDowell wrote:
> On Fri, Dec 22, 2017 at 09:21:09AM +0900, Joonsoo Kim wrote:
> > On Fri, Dec 08, 2017 at 03:11:59PM +0000, Jonathan McDowell wrote:
> > > I've been sitting on this for a while and should have spent time to
> > > investigate sooner, but it's been an odd failure mode that wasn't quite
> > > obvious.
> > > 
> > > In 4.9 if I cold power on my laptop (Dell E7240) it fails to boot - I
> > > don't see anything after grub says its booting. In 4.10 onwards the
> > > laptop boots, but I get an Oops as part of the boot and ACPI is unhappy
> > > (no suspend, no clean poweroff, no ACPI buttons). The Oops is below;
> > > taken from 4.12 as that's the most recent error dmesg I have saved but
> > > also seen back in 4.10. It's always address 0x30 for the dereference.
> > > 
> > > Rebooting the laptop does not lead to these problems; it's *only* from a
> > > complete cold boot that they arise (which didn't help me in terms of
> > > being able to reliably bisect). Once I realised that I was able to
> > > bisect, but it leads me to an odd commit:
> > > 
> > > 86d9f48534e800e4d62cdc1b5aaf539f4c1d47d6
> > > (mm/slab: fix kmemcg cache creation delayed issue)
> > > 
> > > If I revert this then I can cold boot without problems.
> > > 
> > > Also I don't see the problem with a stock Debian kernel, I think because
> > > the ACPI support is modularised.
> > 
> > Sorry for late response. I was on a long vacation.
> 
> No problem. I've been trying to get around to diagnosing this for a
> while now anyway and this isn't a great time of year for fast responses.
> 
> > I have tried to solve the problem however I don't find any clue yet.
> > 
> > >From my analysis, oops report shows that 'struct sock *ssk' passed to
> > netlink_broadcast_filtered() is NULL. It means that some of
> > netlink_kernel_create() returns NULL. Maybe, it is due to slab
> > allocation failure. Could you check it by inserting some log on that
> > part? The issue cannot be reproducible in my side so I need your help.
> 
> I've added some debug in acpi_bus_generate_netlink_event +
> genlmsg_multicast and the problem seems to be that genlmsg_multicast is
> getting called when init_net.genl_sock has not yet been initialised,
> leading to the NULL deference.
> 
> Full dmesg output from a cold 4.14.8 boot at:
> 
> https://the.earth.li/~noodles/acpi-problem/dmesg-4.14.8-broken
> 
> And the same kernel after a reboot ("shutdown -r now"):
> 
> https://the.earth.li/~noodles/acpi-problem/dmesg-4.14.8-working
> 
> Patch that I've applied is at
> 
> https://the.earth.li/~noodles/acpi-problem/debug-acpi.diff
> 

Thanks for testing! It's very helpful.

> The interesting difference seems to be:
> 
>  PCI: Using ACPI for IRQ routing
> +ACPI: Generating event type 208 (:9DBB5994-A997-11DA-B012-B622A1EF5492)
> +ERROR: init_net.genl_sock is NULL
> +BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
> +IP: netlink_broadcast_filtered+0x20/0x3d0
> +PGD 0 P4D 0 
> +Oops: 0000 [#1] SMP
> +Modules linked in:
> +CPU: 0 PID: 29 Comm: kworker/0:1 Not tainted 4.14.8+ #1
> +Hardware name: Dell Inc. Latitude E7240/07RPNV, BIOS A22 10/18/2017
> +Workqueue: kacpi_notify acpi_os_execute_deferred
> 
> 9DBB5994-A997-11DA-B012-B622A1EF5492 is the Dell WMI event GUID and
> there's no visible event for it on a reboot, just on a cold power on.
> Some sort of ordering issues such that genl_sock is being initialised
> later with the slab change?

I have checked that there is an ordering issue.

genl_init() which initializes init_net->genl_sock is called on
subsys_initcall().

acpi_wmi_init() which schedules acpi_wmi_notify_handler() to the
workqueue is called on subsys_initcall(), too.
(acpi_wmi_notify_handler() -> acpi_bus_generate_netlink_event() ->
netlink_broadcast())

In my system, acpi_wmi_init() is called before the genl_init().
Therefore, if the worker is scheduled before genl_init() is done, NULL
derefence would happen.

Although slab change revealed this problem, I think that problem is on
ACPI side and need to be fixed there.

Anyway, I'm not sure why it doesn't happen before. These ACPI
initialization code looks not changed for a long time. Could you test
this problem with the slub?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
