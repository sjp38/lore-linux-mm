Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9356B0038
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 11:37:03 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id f132so10532851wmf.6
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 08:37:03 -0800 (PST)
Received: from the.earth.li (the.earth.li. [2001:41c8:10:b1f:c0ff:ee:15:900d])
        by mx.google.com with ESMTPS id u14si18574752wrg.297.2017.12.29.08.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Dec 2017 08:37:01 -0800 (PST)
Date: Fri, 29 Dec 2017 16:36:59 +0000
From: Jonathan McDowell <noodles@earth.li>
Subject: Re: ACPI issues on cold power on [bisected]
Message-ID: <20171229163659.c5ccfvww4ebvyz54@earth.li>
References: <20171208151159.urdcrzl5qpfd6jnu@earth.li>
 <20171222002108.GB1729@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222002108.GB1729@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Fri, Dec 22, 2017 at 09:21:09AM +0900, Joonsoo Kim wrote:
> On Fri, Dec 08, 2017 at 03:11:59PM +0000, Jonathan McDowell wrote:
> > I've been sitting on this for a while and should have spent time to
> > investigate sooner, but it's been an odd failure mode that wasn't quite
> > obvious.
> > 
> > In 4.9 if I cold power on my laptop (Dell E7240) it fails to boot - I
> > don't see anything after grub says its booting. In 4.10 onwards the
> > laptop boots, but I get an Oops as part of the boot and ACPI is unhappy
> > (no suspend, no clean poweroff, no ACPI buttons). The Oops is below;
> > taken from 4.12 as that's the most recent error dmesg I have saved but
> > also seen back in 4.10. It's always address 0x30 for the dereference.
> > 
> > Rebooting the laptop does not lead to these problems; it's *only* from a
> > complete cold boot that they arise (which didn't help me in terms of
> > being able to reliably bisect). Once I realised that I was able to
> > bisect, but it leads me to an odd commit:
> > 
> > 86d9f48534e800e4d62cdc1b5aaf539f4c1d47d6
> > (mm/slab: fix kmemcg cache creation delayed issue)
> > 
> > If I revert this then I can cold boot without problems.
> > 
> > Also I don't see the problem with a stock Debian kernel, I think because
> > the ACPI support is modularised.
> 
> Sorry for late response. I was on a long vacation.

No problem. I've been trying to get around to diagnosing this for a
while now anyway and this isn't a great time of year for fast responses.

> I have tried to solve the problem however I don't find any clue yet.
> 
> >From my analysis, oops report shows that 'struct sock *ssk' passed to
> netlink_broadcast_filtered() is NULL. It means that some of
> netlink_kernel_create() returns NULL. Maybe, it is due to slab
> allocation failure. Could you check it by inserting some log on that
> part? The issue cannot be reproducible in my side so I need your help.

I've added some debug in acpi_bus_generate_netlink_event +
genlmsg_multicast and the problem seems to be that genlmsg_multicast is
getting called when init_net.genl_sock has not yet been initialised,
leading to the NULL deference.

Full dmesg output from a cold 4.14.8 boot at:

https://the.earth.li/~noodles/acpi-problem/dmesg-4.14.8-broken

And the same kernel after a reboot ("shutdown -r now"):

https://the.earth.li/~noodles/acpi-problem/dmesg-4.14.8-working

Patch that I've applied is at

https://the.earth.li/~noodles/acpi-problem/debug-acpi.diff

The interesting difference seems to be:

 PCI: Using ACPI for IRQ routing
+ACPI: Generating event type 208 (:9DBB5994-A997-11DA-B012-B622A1EF5492)
+ERROR: init_net.genl_sock is NULL
+BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
+IP: netlink_broadcast_filtered+0x20/0x3d0
+PGD 0 P4D 0 
+Oops: 0000 [#1] SMP
+Modules linked in:
+CPU: 0 PID: 29 Comm: kworker/0:1 Not tainted 4.14.8+ #1
+Hardware name: Dell Inc. Latitude E7240/07RPNV, BIOS A22 10/18/2017
+Workqueue: kacpi_notify acpi_os_execute_deferred

9DBB5994-A997-11DA-B012-B622A1EF5492 is the Dell WMI event GUID and
there's no visible event for it on a reboot, just on a cold power on.
Some sort of ordering issues such that genl_sock is being initialised
later with the slab change?

J.

-- 
  Hail Eris. All hail Discordia.   |  .''`.  Debian GNU/Linux Developer
              Fnord?               | : :' :  Happy to accept PGP signed
                                   | `. `'   or encrypted mail - RSA
                                   |   `-    key on the keyservers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
