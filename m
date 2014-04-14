Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3BB6B00E0
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 09:34:32 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so6654597eek.4
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 06:34:30 -0700 (PDT)
Received: from datenkhaos.de (datenkhaos.de. [81.89.99.198])
        by mx.google.com with ESMTPS id u5si21159605een.353.2014.04.14.06.34.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Apr 2014 06:34:29 -0700 (PDT)
Date: Mon, 14 Apr 2014 15:34:24 +0200
From: Johannes Hirte <johannes.hirte@datenkhaos.de>
Subject: Re: [PATCH -next] slub: Replace __this_cpu_inc usage w/ SLUB_STATS
Message-ID: <20140414153424.0eca4c7d@datenkhaos.de>
In-Reply-To: <20140306182941.GH18529@joshc.qualcomm.com>
References: <20140306194821.3715d0b6212cc10415374a68@canb.auug.org.au>
	<20140306155316.GG18529@joshc.qualcomm.com>
	<20140306182941.GH18529@joshc.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Cartwright <joshc@codeaurora.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Thu, 6 Mar 2014 12:29:41 -0600
Josh Cartwright <joshc@codeaurora.org> wrote:

> On Thu, Mar 06, 2014 at 09:53:16AM -0600, Josh Cartwright wrote:
> > Booting on my Samsung Series 9 laptop gives me loads and loads of
> > BUGs triggered by __this_cpu_add(), making making the system
> > completely unusable:
> > 
> > [    5.808326] BUG: using __this_cpu_add() in preemptible
> > [00000000] code: swapper/0/1 [    5.812331] caller is
> > __this_cpu_preempt_check+0x2b/0x30 [    5.815654] CPU: 0 PID: 1
> > Comm: swapper/0 Not tainted
> > 3.14.0-rc5-next-20140306-joshc-08290-g0ffb2fe #1 [    5.819553]
> > Hardware name: SAMSUNG ELECTRONICS CO., LTD.
> > 900X3C/900X3D/900X3E/900X4C/900X4D/NP900X3E-A02US, BIOS P07ABK
> > 04/09/2013 [    5.823558]  ffff8801182157c0 ffff880118215790
> > ffffffff81a64cec 0000000000000000 [    5.827177]  ffff8801182157b0
> > ffffffff81462360 ffff8800c3d553e0 ffffea00030f5500 [    5.830744]
> > ffff8801182157e8 ffffffff814623bb 635f736968745f5f 29286464615f7570
> > [    5.834134] Call Trace: [    5.836848]  [<ffffffff81a64cec>]
> > dump_stack+0x4e/0x7a [    5.839943]  [<ffffffff81462360>]
> > check_preemption_disabled+0xd0/0xe0 [    5.842997]
> > [<ffffffff814623bb>] __this_cpu_preempt_check+0x2b/0x30
> > [    5.846022]  [<ffffffff81a6331d>] __slab_free+0x38/0x590
> > [    5.848863]  [<ffffffff811759dd>] ? get_parent_ip+0xd/0x50
> > [    5.850467] BUG: using __this_cpu_add() in preemptible
> > [00000000] code: khubd/36 [    5.850472] caller is
> > __this_cpu_preempt_check+0x2b/0x30 [    5.859125]
> > [<ffffffff81175b3b>] ? preempt_count_sub+0x6b/0xf0 [    5.862521]
> > [<ffffffff81a7175a>] ? _raw_spin_unlock_irqrestore+0x4a/0x80
> > [    5.865599]  [<ffffffff81462e5e>] ?
> > __debug_check_no_obj_freed+0x13e/0x240 [    5.868738]
> > [<ffffffff814623bb>] ? __this_cpu_preempt_check+0x2b/0x30
> > [    5.871799]  [<ffffffff81287327>] kfree+0x2f7/0x300
> 
> FWIW, it looks like the magic combination of options are:
> 	- CONFIG_DEBUG_PREEMPT=y
> 	- CONFIG_SLUB=y
> 	- CONFIG_SLUB_STATS=y
> 
> Looks like the new percpu() checks are complaining about SLUB's use of
> __this_cpu_inc() for maintaining it's stat counters.  The below patch
> seems to fix it.
> 
> Although, I'm wondering how exact these statistics need to be.  Is
> making them preemption safe even a concern?
> 

Looks like there is a similar issue in touch_softlockup_watchdog too:

Apr 14 14:56:01 localhost kernel: BUG: using __this_cpu_write() in
preemptible [00000000] code: systemd-udevd/1307
Apr 14 14:56:01 localhost kernel: caller is
touch_softlockup_watchdog+0x11/0x1f
Apr 14 14:56:01 localhost kernel: CPU: 0 PID: 1307 Comm: systemd-udevd
Tainted: G        W     3.15.0-rc1 #44
Apr 14 14:56:01 localhost kernel: Hardware name: Hewlett-Packard HP
ProBook 6450b/146D, BIOS 68CDE Ver. F.23 06/13/2012
Apr 14 14:56:01 localhost kernel: 0000000000000000 ffffffff815b6385
0000000000000000 ffffffff813005a4
Apr 14 14:56:01 localhost kernel: 0000000000000000 0000000000000032
00000000000003e8 ffffffff810c63bc
Apr 14 14:56:01 localhost kernel: ffffffff81332592 ffff8800b4ea8800
0000000000000000 ffff8800b686e030
Apr 14 14:56:01 localhost kernel: Call Trace:
Apr 14 14:56:01 localhost kernel: [<ffffffff815b6385>] ?
dump_stack+0x4a/0x75
Apr 14 14:56:01 localhost kernel: [<ffffffff813005a4>] ?
check_preemption_disabled+0xd6/0xe5
Apr 14 14:56:01 localhost kernel: [<ffffffff810c63bc>] ?
touch_softlockup_watchdog+0x11/0x1f
Apr 14 14:56:01 localhost kernel: [<ffffffff81332592>] ?
acpi_os_stall+0x2f/0x36
Apr 14 14:56:01 localhost kernel: [<ffffffff8134b64a>] ?
acpi_ex_system_do_stall+0x34/0x37
Apr 14 14:56:01 localhost kernel: [<ffffffff813411d4>] ?
acpi_ds_exec_end_op+0xcc/0x3d5
Apr 14 14:56:01 localhost kernel: [<ffffffff81351fcf>] ?
acpi_ps_parse_loop+0x50c/0x564
Apr 14 14:56:01 localhost kernel: [<ffffffff81352a21>] ?
acpi_ps_parse_aml+0x93/0x26f
Apr 14 14:56:01 localhost kernel: [<ffffffff813531eb>] ?
acpi_ps_execute_method+0x1b6/0x25f
Apr 14 14:56:01 localhost kernel: [<ffffffff8134debe>] ?
acpi_ns_evaluate+0x1ba/0x247
Apr 14 14:56:01 localhost kernel: [<ffffffff81350557>] ?
acpi_evaluate_object+0x122/0x231
Apr 14 14:56:01 localhost kernel: [<ffffffffa005a230>] ?
lis3lv02d_acpi_init+0x1c/0x27 [hp_accel]
Apr 14 14:56:01 localhost kernel: [<ffffffffa005320a>] ?
lis3lv02d_poweron+0xe/0xca [lis3lv02d]
Apr 14 14:56:01 localhost kernel: [<ffffffffa0053b16>] ?
lis3lv02d_init_device+0x22a/0x4e5 [lis3lv02d]
Apr 14 14:56:01 localhost kernel: [<ffffffffa005a347>] ?
lis3lv02d_add+0x10c/0x18a [hp_accel]
Apr 14 14:56:01 localhost kernel: [<ffffffff81335d82>] ?
acpi_device_probe+0x3d/0xeb
Apr 14 14:56:01 localhost kernel: [<ffffffff81418e8b>] ?
driver_probe_device+0x97/0x1b8
Apr 14 14:56:01 localhost kernel: [<ffffffff8141903a>] ?
__driver_attach+0x58/0x78
Apr 14 14:56:01 localhost kernel: [<ffffffff81418fe2>] ?
__device_attach+0x36/0x36
Apr 14 14:56:01 localhost kernel: [<ffffffff81417650>] ?
bus_for_each_dev+0x73/0x7d
Apr 14 14:56:01 localhost kernel: [<ffffffff814186f4>] ?
bus_add_driver+0x105/0x1ce
Apr 14 14:56:01 localhost kernel: [<ffffffff81419577>] ?
driver_register+0x88/0xc0
Apr 14 14:56:01 localhost kernel: [<ffffffffa005f000>] ?
0xffffffffa005efff
Apr 14 14:56:01 localhost kernel: [<ffffffff8100029e>] ?
do_one_initcall+0x7d/0x101
Apr 14 14:56:01 localhost kernel: [<ffffffff815be854>] ?
notifier_call_chain+0x37/0x57
Apr 14 14:56:01 localhost kernel: [<ffffffff81076cd2>] ?
__blocking_notifier_call_chain+0x53/0x60
Apr 14 14:56:01 localhost kernel: [<ffffffff810b0740>] ?
load_module+0x19f6/0x1ba7
Apr 14 14:56:01 localhost kernel: [<ffffffff810ad754>] ?
module_flags+0x74/0x74
Apr 14 14:56:01 localhost kernel: [<ffffffff810b09de>] ?
SyS_finit_module+0x4f/0x63
Apr 14 14:56:01 localhost kernel: [<ffffffff815c199f>] ?
tracesys+0xdd/0xe2

kernel/watchdog.c:

void touch_softlockup_watchdog(void)
{
        __this_cpu_write(watchdog_touch_ts, 0);
}
EXPORT_SYMBOL(touch_softlockup_watchdog);

Don't know if the change to this_cpu_write() is the right way here too.

regards,
  Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
