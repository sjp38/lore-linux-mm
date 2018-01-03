Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1878A6B0340
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 06:31:05 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id 64so228513lfx.16
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 03:31:05 -0800 (PST)
Received: from cloudserver094114.home.pl (cloudserver094114.home.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id u11si306676ljd.392.2018.01.03.03.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jan 2018 03:31:03 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: ACPI issues on cold power on [bisected]
Date: Wed, 03 Jan 2018 12:29:57 +0100
Message-ID: <1992532.LQVZdPLcZi@aspire.rjw.lan>
In-Reply-To: <20180103103812.klxncszqtq3lj3rr@earth.li>
References: <20171208151159.urdcrzl5qpfd6jnu@earth.li> <20180103021129.GB26517@js1304-P5Q-DELUXE> <20180103103812.klxncszqtq3lj3rr@earth.li>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan McDowell <noodles@earth.li>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Rafael J. Wysocki" <rafael@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, netdev@vger.kernel.org

On Wednesday, January 3, 2018 11:38:12 AM CET Jonathan McDowell wrote:
> On Wed, Jan 03, 2018 at 11:11:29AM +0900, Joonsoo Kim wrote:
> > On Tue, Jan 02, 2018 at 11:25:01AM +0100, Rafael J. Wysocki wrote:
> > > On Tue, Jan 2, 2018 at 3:54 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > > On Fri, Dec 29, 2017 at 04:36:59PM +0000, Jonathan McDowell wrote:
> > > >> On Fri, Dec 22, 2017 at 09:21:09AM +0900, Joonsoo Kim wrote:
> > > >> > On Fri, Dec 08, 2017 at 03:11:59PM +0000, Jonathan McDowell wrote:
> > > >> > > I've been sitting on this for a while and should have spent time to
> > > >> > > investigate sooner, but it's been an odd failure mode that wasn't quite
> > > >> > > obvious.
> > > >> > >
> > > >> > > In 4.9 if I cold power on my laptop (Dell E7240) it fails to boot - I
> > > >> > > don't see anything after grub says its booting. In 4.10 onwards the
> > > >> > > laptop boots, but I get an Oops as part of the boot and ACPI is unhappy
> > > >> > > (no suspend, no clean poweroff, no ACPI buttons). The Oops is below;
> > > >> > > taken from 4.12 as that's the most recent error dmesg I have saved but
> > > >> > > also seen back in 4.10. It's always address 0x30 for the dereference.
> > > >> > >
> > > >> > > Rebooting the laptop does not lead to these problems; it's *only* from a
> > > >> > > complete cold boot that they arise (which didn't help me in terms of
> > > >> > > being able to reliably bisect). Once I realised that I was able to
> > > >> > > bisect, but it leads me to an odd commit:
> > > >> > >
> > > >> > > 86d9f48534e800e4d62cdc1b5aaf539f4c1d47d6
> > > >> > > (mm/slab: fix kmemcg cache creation delayed issue)
> > > >> > >
> > > >> > > If I revert this then I can cold boot without problems.
> > > >> > >
> > > >> > > Also I don't see the problem with a stock Debian kernel, I think because
> > > >> > > the ACPI support is modularised.
> > > >> >
> > > >> > Sorry for late response. I was on a long vacation.
> > > >>
> > > >> No problem. I've been trying to get around to diagnosing this for a
> > > >> while now anyway and this isn't a great time of year for fast responses.
> > > >>
> > > >> > I have tried to solve the problem however I don't find any clue yet.
> > > >> >
> > > >> > >From my analysis, oops report shows that 'struct sock *ssk' passed to
> > > >> > netlink_broadcast_filtered() is NULL. It means that some of
> > > >> > netlink_kernel_create() returns NULL. Maybe, it is due to slab
> > > >> > allocation failure. Could you check it by inserting some log on that
> > > >> > part? The issue cannot be reproducible in my side so I need your help.
> > > >>
> > > >> I've added some debug in acpi_bus_generate_netlink_event +
> > > >> genlmsg_multicast and the problem seems to be that genlmsg_multicast is
> > > >> getting called when init_net.genl_sock has not yet been initialised,
> > > >> leading to the NULL deference.
> > > >>
> > > >> Full dmesg output from a cold 4.14.8 boot at:
> > > >>
> > > >> https://the.earth.li/~noodles/acpi-problem/dmesg-4.14.8-broken
> > > >>
> > > >> And the same kernel after a reboot ("shutdown -r now"):
> > > >>
> > > >> https://the.earth.li/~noodles/acpi-problem/dmesg-4.14.8-working
> > > >>
> > > >> Patch that I've applied is at
> > > >>
> > > >> https://the.earth.li/~noodles/acpi-problem/debug-acpi.diff
> > > >>
> > > >
> > > > Thanks for testing! It's very helpful.
> > > >
> > > >> The interesting difference seems to be:
> > > >>
> > > >>  PCI: Using ACPI for IRQ routing
> > > >> +ACPI: Generating event type 208 (:9DBB5994-A997-11DA-B012-B622A1EF5492)
> > > >> +ERROR: init_net.genl_sock is NULL
> > > >> +BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
> > > >> +IP: netlink_broadcast_filtered+0x20/0x3d0
> > > >> +PGD 0 P4D 0
> > > >> +Oops: 0000 [#1] SMP
> > > >> +Modules linked in:
> > > >> +CPU: 0 PID: 29 Comm: kworker/0:1 Not tainted 4.14.8+ #1
> > > >> +Hardware name: Dell Inc. Latitude E7240/07RPNV, BIOS A22 10/18/2017
> > > >> +Workqueue: kacpi_notify acpi_os_execute_deferred
> > > >>
> > > >> 9DBB5994-A997-11DA-B012-B622A1EF5492 is the Dell WMI event GUID and
> > > >> there's no visible event for it on a reboot, just on a cold power on.
> > > >> Some sort of ordering issues such that genl_sock is being initialised
> > > >> later with the slab change?
> > > >
> > > > I have checked that there is an ordering issue.
> > > >
> > > > genl_init() which initializes init_net->genl_sock is called on
> > > > subsys_initcall().
> > > >
> > > > acpi_wmi_init() which schedules acpi_wmi_notify_handler() to the
> > > > workqueue is called on subsys_initcall(), too.
> > > > (acpi_wmi_notify_handler() -> acpi_bus_generate_netlink_event() ->
> > > > netlink_broadcast())
> > > >
> > > > In my system, acpi_wmi_init() is called before the genl_init().
> > > > Therefore, if the worker is scheduled before genl_init() is done, NULL
> > > > derefence would happen.
> > > 
> > > Does it help to change the subsys_initcall() in wmi.c to subsys_initcall_sync()?
> > 
> > I guess that it would work. I cannot reproduce the issue so it needs
> > to be checked by Jonathan. Jonathan, could you check the problem
> > is disappeared with above change?
> 
> I have confirmed that the problem also occurs when using SLUB instead of
> SLAB, and that switching drivers/platform/x86/wmi.c to use
> subsys_initcall_sync() instead of subsys_initcall() fixes the problem
> for both. Weirdly I don't see the ACPI 208 event at boot time being
> raised once that patch is in place.

Interesting.

Anyway, let me send this change as a proper patch.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
