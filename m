Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id BC4336B0034
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 11:16:08 -0400 (EDT)
Date: Thu, 20 Jun 2013 17:16:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130620151607.GE27196@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618062623.GA20528@localhost.localdomain>
 <20130619071346.GA9545@dhcp22.suse.cz>
 <20130619142801.GA21483@dhcp22.suse.cz>
 <20130620141136.GA3351@localhost.localdomain>
 <20130620151201.GD27196@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130620151201.GD27196@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 20-06-13 17:12:01, Michal Hocko wrote:
> On Thu 20-06-13 18:11:38, Glauber Costa wrote:
> [...]
> > > [84091.219056] ------------[ cut here ]------------
> > > [84091.220015] kernel BUG at mm/list_lru.c:42!
> > > [84091.220015] invalid opcode: 0000 [#1] SMP 
> > > [84091.220015] Modules linked in: edd nfsv3 nfs_acl nfs fscache lockd sunrpc af_packet bridge stp llc cpufreq_conservative cpufreq_userspace cpufreq_powersave fuse loop dm_mod powernow_k8 tg3 kvm_amd kvm ptp e1000 pps_core shpchp edac_core i2c_amd756 amd_rng pci_hotplug k8temp sg i2c_amd8111 edac_mce_amd serio_raw sr_mod pcspkr cdrom button ohci_hcd ehci_hcd usbcore usb_common processor thermal_sys scsi_dh_emc scsi_dh_rdac scsi_dh_hp_sw scsi_dh ata_generic sata_sil pata_amd
> > > [84091.220015] CPU 1 
> > > [84091.220015] Pid: 32545, comm: rm Not tainted 3.9.0mmotmdebugging1+ #1472 AMD A8440/WARTHOG
> > > [84091.220015] RIP: 0010:[<ffffffff81127fff>]  [<ffffffff81127fff>] list_lru_del+0xcf/0xe0
> > > [84091.220015] RSP: 0018:ffff88001de85df8  EFLAGS: 00010286
> > > [84091.220015] RAX: ffffffffffffffff RBX: ffff88001e1ce2c0 RCX: 0000000000000002
> > > [84091.220015] RDX: ffff88001e1ce2c8 RSI: ffff8800087f4220 RDI: ffff88001e1ce2c0
> > > [84091.220015] RBP: ffff88001de85e18 R08: 0000000000000000 R09: 0000000000000000
> > > [84091.220015] R10: ffff88001d539128 R11: ffff880018234882 R12: ffff8800087f4220
> > > [84091.220015] R13: ffff88001c68bc40 R14: 0000000000000000 R15: ffff88001de85ea8
> > > [84091.220015] FS:  00007f43adb30700(0000) GS:ffff88001f100000(0000) knlGS:0000000000000000
> > > [84091.220015] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > [84091.220015] CR2: 0000000001ffed30 CR3: 000000001e02e000 CR4: 00000000000007e0
> > > [84091.220015] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > [84091.220015] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > [84091.220015] Process rm (pid: 32545, threadinfo ffff88001de84000, task ffff88001c22e5c0)
> > > [84091.220015] Stack:
> > > [84091.220015]  ffff8800087f4130 ffff8800087f41b8 ffff88001c68b800 0000000000000000
> > > [84091.220015]  ffff88001de85e48 ffffffff81184357 ffff88001de85e48 ffff8800087f4130
> > > [84091.220015]  ffff88001e005000 ffff880014e4eb40 ffff88001de85e68 ffffffff81184418
> > > [84091.220015] Call Trace:
> > > [84091.220015]  [<ffffffff81184357>] iput_final+0x117/0x190
> > > [84091.220015]  [<ffffffff81184418>] iput+0x48/0x60
> > > [84091.220015]  [<ffffffff8117a804>] do_unlinkat+0x214/0x240
> > > [84091.220015]  [<ffffffff8117aa4d>] sys_unlinkat+0x1d/0x40
> > > [84091.220015]  [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > > [84091.220015] Code: 5c 41 5d b8 01 00 00 00 41 5e c9 c3 49 8d 45 08 f0 45 0f b3 75 08 eb db 0f 1f 40 00 66 83 03 01 5b 41 5c 41 5d 31 c0 41 5e c9 c3 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 ba 00 00 
> > > [84091.220015] RIP  [<ffffffff81127fff>] list_lru_del+0xcf/0xe0
> > > [84091.220015]  RSP <ffff88001de85df8>
> > > [84091.470390] ---[ end trace e6915e8ee0f5f079 ]---
> > > 
> > > Which is BUG_ON(nlru->nr_items < 0) from iput_final path. So it seems
> > > that there is still a race there.
> > 
> > I am still looking at this - still can't reproduce, still don't know what is going
> > on.
> 
> I am bisecting it again. It is quite tedious, though, because good case
> is hard to be sure about.

And my test case runs the following (there is very same B.run, both of
them run in its own group):
#JOBS=4
#KERNEL_CONFIG="./config"
#KERNEL_TAR="./linux-3.7-rc5.tar.bz2"
#KERNEL_OUT="build/$CGROUP/kernel"
#CGROUP=A
$ cat A.run
KERNEL_DIR="$KERNEL_OUT/${KERNEL_TAR%.tar.bz2}"
mkdir -p "$KERNEL_DIR"

tar -xf $KERNEL_TAR -C $KERNEL_OUT || fail "get the source for $KERNEL_TAR->$KERNEL_OUT"
cp "$KERNEL_CONFIG" "$KERNEL_DIR/.config" || fail "Get the config"

LOG="`pwd`/$LOG_OUT_DIR"
mkdir -p "$LOG"

old_path="`pwd`"
cd "$KERNEL_DIR"
info "$CGROUP starting build jobs:$JOBS"
TIMESTAMP=`date +%s`
( /usr/bin/time -v make -j$JOBS vmlinux >/dev/null ) > $LOG/time.$CGROUP.$TIMESTAMP 2>&1 || fail "Build the kernel at $KERNEL_DIR"
cd "$old_path"
rm -rf "$KERNEL_OUT"
sync
echo 3 > /proc/sys/vm/drop_caches
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
