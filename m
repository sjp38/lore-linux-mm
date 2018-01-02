Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 899AA6B029F
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 05:25:03 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v137so22235868oia.21
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 02:25:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c50sor13392446otc.261.2018.01.02.02.25.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jan 2018 02:25:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180102025417.GA20740@js1304-P5Q-DELUXE>
References: <20171208151159.urdcrzl5qpfd6jnu@earth.li> <20171222002108.GB1729@js1304-P5Q-DELUXE>
 <20171229163659.c5ccfvww4ebvyz54@earth.li> <20180102025417.GA20740@js1304-P5Q-DELUXE>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 2 Jan 2018 11:25:01 +0100
Message-ID: <CAJZ5v0hSkEvmcubFzW03COW0f1TwB6W1d7vwJoF9qpJJ6Jc5JQ@mail.gmail.com>
Subject: Re: ACPI issues on cold power on [bisected]
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jonathan McDowell <noodles@earth.li>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, netdev@vger.kernel.org

On Tue, Jan 2, 2018 at 3:54 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Fri, Dec 29, 2017 at 04:36:59PM +0000, Jonathan McDowell wrote:
>> On Fri, Dec 22, 2017 at 09:21:09AM +0900, Joonsoo Kim wrote:
>> > On Fri, Dec 08, 2017 at 03:11:59PM +0000, Jonathan McDowell wrote:
>> > > I've been sitting on this for a while and should have spent time to
>> > > investigate sooner, but it's been an odd failure mode that wasn't quite
>> > > obvious.
>> > >
>> > > In 4.9 if I cold power on my laptop (Dell E7240) it fails to boot - I
>> > > don't see anything after grub says its booting. In 4.10 onwards the
>> > > laptop boots, but I get an Oops as part of the boot and ACPI is unhappy
>> > > (no suspend, no clean poweroff, no ACPI buttons). The Oops is below;
>> > > taken from 4.12 as that's the most recent error dmesg I have saved but
>> > > also seen back in 4.10. It's always address 0x30 for the dereference.
>> > >
>> > > Rebooting the laptop does not lead to these problems; it's *only* from a
>> > > complete cold boot that they arise (which didn't help me in terms of
>> > > being able to reliably bisect). Once I realised that I was able to
>> > > bisect, but it leads me to an odd commit:
>> > >
>> > > 86d9f48534e800e4d62cdc1b5aaf539f4c1d47d6
>> > > (mm/slab: fix kmemcg cache creation delayed issue)
>> > >
>> > > If I revert this then I can cold boot without problems.
>> > >
>> > > Also I don't see the problem with a stock Debian kernel, I think because
>> > > the ACPI support is modularised.
>> >
>> > Sorry for late response. I was on a long vacation.
>>
>> No problem. I've been trying to get around to diagnosing this for a
>> while now anyway and this isn't a great time of year for fast responses.
>>
>> > I have tried to solve the problem however I don't find any clue yet.
>> >
>> > >From my analysis, oops report shows that 'struct sock *ssk' passed to
>> > netlink_broadcast_filtered() is NULL. It means that some of
>> > netlink_kernel_create() returns NULL. Maybe, it is due to slab
>> > allocation failure. Could you check it by inserting some log on that
>> > part? The issue cannot be reproducible in my side so I need your help.
>>
>> I've added some debug in acpi_bus_generate_netlink_event +
>> genlmsg_multicast and the problem seems to be that genlmsg_multicast is
>> getting called when init_net.genl_sock has not yet been initialised,
>> leading to the NULL deference.
>>
>> Full dmesg output from a cold 4.14.8 boot at:
>>
>> https://the.earth.li/~noodles/acpi-problem/dmesg-4.14.8-broken
>>
>> And the same kernel after a reboot ("shutdown -r now"):
>>
>> https://the.earth.li/~noodles/acpi-problem/dmesg-4.14.8-working
>>
>> Patch that I've applied is at
>>
>> https://the.earth.li/~noodles/acpi-problem/debug-acpi.diff
>>
>
> Thanks for testing! It's very helpful.
>
>> The interesting difference seems to be:
>>
>>  PCI: Using ACPI for IRQ routing
>> +ACPI: Generating event type 208 (:9DBB5994-A997-11DA-B012-B622A1EF5492)
>> +ERROR: init_net.genl_sock is NULL
>> +BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
>> +IP: netlink_broadcast_filtered+0x20/0x3d0
>> +PGD 0 P4D 0
>> +Oops: 0000 [#1] SMP
>> +Modules linked in:
>> +CPU: 0 PID: 29 Comm: kworker/0:1 Not tainted 4.14.8+ #1
>> +Hardware name: Dell Inc. Latitude E7240/07RPNV, BIOS A22 10/18/2017
>> +Workqueue: kacpi_notify acpi_os_execute_deferred
>>
>> 9DBB5994-A997-11DA-B012-B622A1EF5492 is the Dell WMI event GUID and
>> there's no visible event for it on a reboot, just on a cold power on.
>> Some sort of ordering issues such that genl_sock is being initialised
>> later with the slab change?
>
> I have checked that there is an ordering issue.
>
> genl_init() which initializes init_net->genl_sock is called on
> subsys_initcall().
>
> acpi_wmi_init() which schedules acpi_wmi_notify_handler() to the
> workqueue is called on subsys_initcall(), too.
> (acpi_wmi_notify_handler() -> acpi_bus_generate_netlink_event() ->
> netlink_broadcast())
>
> In my system, acpi_wmi_init() is called before the genl_init().
> Therefore, if the worker is scheduled before genl_init() is done, NULL
> derefence would happen.

Does it help to change the subsys_initcall() in wmi.c to subsys_initcall_sync()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
