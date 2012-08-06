Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 619D06B005D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 11:15:06 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so3343890vbk.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 08:15:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120805223611.GC6946@thunk.org>
References: <20120805223611.GC6946@thunk.org>
Date: Mon, 6 Aug 2012 08:15:05 -0700
Message-ID: <CANsGZ6Yd9ku=01QkFirsfLC2dTD00G3er7z-uNX-nhEaUpK1cg@mail.gmail.com>
Subject: Re: [bugzilla-daemon@bugzilla.kernel.org: [Bug 45621] New: Kernel
 ooops: BUG: unable to handle kernel paging request at 000000080000001c]
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Markus Doits <markus.doits@googlemail.com>

On Sun, Aug 5, 2012 at 3:36 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> Hi, I'm hoping this rings a bell with an mm developer:
>
>         https://bugzilla.kernel.org/show_bug.cgi?id=45621
>
> It looks like the user is reporting a OOPS which was caused by the
> inode's mapping->page_tree having gotten corrupted.  The call stack
> was from a write system call while the system was undergoing heavy
> I/O, on a v3.4.7 kernel.
>
> If someone could take a quick look at this, I'd really appreciate it.
> Thanks!!

It looks exactly like a classic bitflip from bad DRAM.

The faulting instruction is  where find_get_page()'s call to
page_cache_get_speculative(page) tries to access page->_count, at
offset 0x1c into struct page.

The page pointer found in the radix tree slot should have been NULL
(quite normal when writing like this, I'm a little surprised we mark
that as "unlikely"),
but it's got that 0x800000000 bit set.

Markus, you say that you sometimes get that oops: it might be helpful
if you could attach a few more examples to the bugzilla entry.  I've
not stopped to see whether the address of the radix tree slot in
question is actually still in the registers or on the stack shown, but
if it is, then seeing the same or nearby addresses in other cases
would tend to confirm bad memory.

Worth checking with memtest86 or memtest86+.  But of course, it could
also be a kernel bug putting that bit of corruption there.

Hugh

>
>                                                 - Ted
>
>
>            Summary: Kernel ooops: BUG: unable to handle kernel paging
>                     request at 000000080000001c
>            Product: File System
>            Version: 2.5
>     Kernel Version: 3.4.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: ext4
>         AssignedTo: fs_ext4@kernel-bugs.osdl.org
>         ReportedBy: markus.doits@googlemail.com
>         Regression: No
>
>
> During heavy io on my ext4 filesystems, I sometimes get this oops:
>
>
> [10645.902287] BUG: unable to handle kernel paging request at 000000080000001c
> [10645.902881] IP: [<ffffffff8110c4d1>] find_get_page+0x41/0xa0
> [10645.903359] PGD 1e21cb067 PUD 0
> [10645.903638] Oops: 0000 [#1] PREEMPT SMP
> [10645.903986] CPU 1
> [10645.904147] Modules linked in: md5 aes_x86_64 aes_generic xts gf128mul
> dm_crypt dm_mod usb_storage uas nfsd exportfs tun w83627ehf hwmon_vid
> iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4
> nf_defrag_ipv4 nf_conntrack ip_tables x_tables rc_dib0700_rc5 dvb_usb_dib0700
> dib3000mc dib8000 dib0070 dib7000m dib7000p dibx000_common dib0090 dvb_usb
> dvb_core microcode i915 iTCO_wdt i2c_algo_bit drm_kms_helper intel_agp
> iTCO_vendor_support drm psmouse ghash_clmulni_intel mei(C) evdev atl1c rc_core
> intel_gtt pcspkr serio_raw i2c_i801 i2c_core acpi_cpufreq mperf processor
> cryptd coretemp crc32c_intel video button loop fuse nfs nfs_acl lockd
> auth_rpcgss sunrpc fscache ext4 crc16 jbd2 mbcache sd_mod ahci libahci ehci_hcd
> xhci_hcd libata scsi_mod usbcore usb_common
> [10645.910482]
> [10645.910602] Pid: 2958, comm: rsync Tainted: G         C   3.4.7-1-ARCH #1 To
> Be Filled By O.E.M. To Be Filled By O.E.M./H61M/U3S3
> [10645.911595] RIP: 0010:[<ffffffff8110c4d1>]  [<ffffffff8110c4d1>]
> find_get_page+0x41/0xa0
> [10645.912276] RSP: 0018:ffff8801fe1eba28  EFLAGS: 00010246
> [10645.912713] RAX: ffff880100ad1198 RBX: 0000000800000000 RCX:
> 00000000fffffffa
> [10645.913303] RDX: 0000000000000001 RSI: ffff880100ad1198 RDI:
> 0000000000000000
> [10645.913893] RBP: ffff8801fe1eba48 R08: 0000000800000000 R09:
> ffff880100ad0f88
> [10645.914481] R10: ffffffffa0188e00 R11: 0000000000000000 R12:
> ffff88008a307058
> [10645.915071] R13: 00000000000084bf R14: 000000000102005a R15:
> 0000000000000050
> [10645.915663] FS:  00007f8c4d7f4700(0000) GS:ffff88021f280000(0000)
> knlGS:0000000000000000
> [10645.916333] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [10645.916807] CR2: 000000080000001c CR3: 00000001d296a000 CR4:
> 00000000000407e0
> [10645.917393] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [10645.917985] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [10645.918574] Process rsync (pid: 2958, threadinfo ffff8801fe1ea000, task
> ffff880211fcafa0)
> [10645.919250] Stack:
> [10645.919413]  ffff8801fe1eba48 ffff88008a307050 00000000000084bf
> 00000000000084bf
> [10645.920059]  ffff8801fe1eba78 ffffffff8110c6d6 ffff8801fe1eba68
> ffffffffa00558d3
> [10645.920702]  0000000000000004 ffff88008a307050 ffff8801fe1ebac8
> ffffffff8110cdf2
> [10645.921344] Call Trace:
> [10645.942181]  [<ffffffff8110c6d6>] find_lock_page+0x26/0x80
> [10645.963412]  [<ffffffffa00558d3>] ? jbd2_journal_start+0x13/0x20 [jbd2]
> [10645.984833]  [<ffffffff8110cdf2>] grab_cache_page_write_begin+0x72/0x100
> [10645.984853]  [<ffffffffa0149bf0>] ext4_da_write_begin+0xa0/0x230 [ext4]
> [10645.984858]  [<ffffffffa014c47d>] ? ext4_da_write_end+0xad/0x390 [ext4]
> [10645.984861]  [<ffffffff8110be74>] generic_file_buffered_write+0x124/0x2b0
> [10645.984864]  [<ffffffff8110da4a>] __generic_file_aio_write+0x22a/0x440
> [10645.984868]  [<ffffffff8146775e>] ? __mutex_lock_slowpath+0x24e/0x340
> [10645.984871]  [<ffffffff8110dcd1>] generic_file_aio_write+0x71/0xe0
> [10645.984876]  [<ffffffffa014334f>] ext4_file_write+0xaf/0x260 [ext4]
> [10645.984879]  [<ffffffff8116e286>] do_sync_write+0xe6/0x120
> [10645.984883]  [<ffffffff811f8a9c>] ? security_file_permission+0x2c/0xb0
> [10645.984885]  [<ffffffff8116e871>] ? rw_verify_area+0x61/0xf0
> [10645.984887]  [<ffffffff8116eb88>] vfs_write+0xa8/0x180
> [10645.984888]  [<ffffffff8116eeca>] sys_write+0x4a/0xa0
> [10645.984891]  [<ffffffff8146aaa9>] system_call_fastpath+0x16/0x1b
> [10645.984892] Code: 89 f5 4c 8d 63 08 e8 3f 8e fc ff 4c 89 ee 4c 89 e7 e8 f4
> 77 13 00 48 85 c0 48 89 c6 74 44 48 8b 18 48 85 db 74 22 f6 c3 03 75 3f <8b> 53
> 1c 85 d2 74 d9 8d 7a 01 89 d0 f0 0f b1 7b 1c 39 c2 75 26
> [10645.984908] RIP  [<ffffffff8110c4d1>] find_get_page+0x41/0xa0
> [10645.984910]  RSP <ffff8801fe1eba28>
> [10645.984911] CR2: 000000080000001c
> [10646.075497] ---[ end trace 9841da8b9a0cb390 ]---
>
> Using archlinux stable.
>
> Anything else I can do to hunt this bug down?
>
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
