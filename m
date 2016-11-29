Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2686B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:34:14 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j92so304252536ioi.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:34:14 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id y69si44873427ioi.107.2016.11.29.08.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Nov 2016 08:34:13 -0800 (PST)
Date: Tue, 29 Nov 2016 08:34:06 -0800
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20161129163406.treuewaqgt4fy4kh@merlins.org>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129160751.GC9796@dhcp22.suse.cz>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Nov 29, 2016 at 05:07:51PM +0100, Michal Hocko wrote:
> On Tue 29-11-16 07:55:37, Marc MERLIN wrote:
> > On Mon, Nov 28, 2016 at 08:23:15AM +0100, Michal Hocko wrote:
> > > Marc, could you try this patch please? I think it should be pretty clear
> > > it should help you but running it through your use case would be more
> > > than welcome before I ask Greg to take this to the 4.8 stable tree.
> > 
> > I ran it overnight and copied 1.4TB with it before it failed because
> > there wasn't enough disk space on the other side, so I think it fixes
> > the problem too.
> 
> Can I add your Tested-by?

Done.

Now, probably unrelated, but hard to be sure, doing those big copies
causes massive hangs on my system. I hit a few of the 120s hangs,
but more generally lots of things hang, including shells, my DNS server,
monitoring reading from USB and timing out, and so forth.
Examples below. 
I have a hard time telling what is the fault, but is there a chance it
might be memory allocation pressure?
I already have a preempt kernel, so I can't make it more preempt than
that.
Now, to be fair, this is not a new problem, it's just varying degrees of
bad and usually only happens when I do a lot of I/O with btrfs.
That said, btrfs may very well just be suffering from memory allocation
issues and hanging as a result, with everything else on my system also
hanging for similar reasons until the memory pressure goes away with the
copy or scrub are finished.

What do you think?

[28034.954435] INFO: task btrfs:5618 blocked for more than 120 seconds.
[28034.975471]       Tainted: G     U          4.8.10-amd64-preempt-sysrq-20161121vb3tj1 #12
[28035.000964] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[28035.025429] btrfs           D ffff91154d33fc70     0  5618   5372 0x00000080
[28035.047717]  ffff91154d33fc70 0000000000200246 ffff911842f880c0 ffff9115a4cf01c0
[28035.071020]  ffff91154d33fc58 ffff91154d340000 ffff91165493bca0 ffff9115623773f0
[28035.094252]  0000000000001000 0000000000000001 ffff91154d33fc88 ffffffffb86cf1a6
[28035.117538] Call Trace:
[28035.125791]  [<ffffffffb86cf1a6>] schedule+0x8b/0xa3
[28035.141550]  [<ffffffffb82bd18e>] btrfs_start_ordered_extent+0xce/0x122
[28035.162457]  [<ffffffffb809af6c>] ? wake_up_atomic_t+0x2c/0x2c
[28035.180891]  [<ffffffffb82bd434>] btrfs_wait_ordered_range+0xa9/0x10d
[28035.201723]  [<ffffffffb82aec04>] btrfs_truncate+0x40/0x24b
[28035.219269]  [<ffffffffb82af437>] btrfs_setattr+0x1da/0x2d7
[28035.237032]  [<ffffffffb81c7507>] notify_change+0x252/0x39c
[28035.254566]  [<ffffffffb81ad35b>] do_truncate+0x81/0xb4
[28035.271057]  [<ffffffffb81ad467>] vfs_truncate+0xd9/0xf9
[28035.287782]  [<ffffffffb81ad4ea>] do_sys_truncate+0x63/0xa7

I get other hangs like:

[10338.968912] perf: interrupt took too long (3927 > 3917), lowering kernel.perf_event_max_sample_rate to 50750

[12971.047705] ftdi_sio ttyUSB15: usb_serial_generic_read_bulk_callback - urb stopped: -32

[17761.122238] usb 4-1.4: USB disconnect, device number 39
[17761.141063] usb 4-1.4: usbfs: USBDEVFS_CONTROL failed cmd hub-ctrl rqt 160 rq 6 len 1024 ret -108
[17761.263252] usb 4-1: reset SuperSpeed USB device number 2 using xhci_hcd
[17761.938575] usb 4-1.4: new SuperSpeed USB device number 40 using xhci_hcd

[24130.574425] hpet1: lost 2306 rtc interrupts
[24156.034950] hpet1: lost 1628 rtc interrupts
[24173.314738] hpet1: lost 1104 rtc interrupts
[24180.129950] hpet1: lost 436 rtc interrupts
[24257.557955] hpet1: lost 4954 rtc interrupts
[24267.522656] hpet1: lost 637 rtc interrupts

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/                         | PGP 1024R/763BE901

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
