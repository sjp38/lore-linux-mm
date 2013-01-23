Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6C6A06B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 08:17:01 -0500 (EST)
Date: Wed, 23 Jan 2013 08:16:52 -0500 (EST)
From: Zhouping Liu <zliu@redhat.com>
Message-ID: <956393225.9764718.1358947012010.JavaMail.root@redhat.com>
In-Reply-To: <173180425.9757906.1358945712656.JavaMail.root@redhat.com>
Subject: BUG: soft lockup - CPU#7 stuck for 22s! [numad:564]
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Cc: David Airlie <airlied@redhat.com>, Amos Kong <akong@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Jani Nikula <jani.nikula@intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, CAI Qian <caiqian@redhat.com>, mgorman@suse.de

Hello All,

I hit the following crash in mainline(9a9284153d9 Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux)

-------- snip -------------
[ 1874.514412] BUG: soft lockup - CPU#7 stuck for 22s! [numad:564]
[ 1874.520320] Modules linked in: ebtable_nat bnep bluetooth rfkill iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi vfat fat dm_mirror dm_region_hash dm_log dm_mod iTCO_wdt coretemp i7core_edac iTCO_vendor_support cdc_ether crc32c_intel usbnet lpc_ich edac_core ioatdma bnx2 i2c_i801 mii serio_raw dca shpchp mfd_core pcspkr microcode vhost_net tun macvtap macvlan kvm_intel kvm uinput sr_mod cdrom sd_mod mgag200 i2c_algo_bit crc_t10dif drm_kms_helper ata_piix ttm drm libata i2c_core megaraid_sas
[ 1874.591743] CPU 7
[ 1874.593584] Pid: 564, comm: numad Not tainted 3.8.0-rc4memcg+ #18 IBM IBM System x3400 M3 Server -[7379I08]-/69Y4356
[ 1874.604700] RIP: 0010:[<ffffffff810db965>]  [<ffffffff810db965>] audit_log_start+0x95/0x450
[ 1874.613055] RSP: 0018:ffff88017940fd38  EFLAGS: 00000286
[ 1874.618356] RAX: 000000000000ea60 RBX: 00000001000a75bf RCX: 0000000000000142
[ 1874.625473] RDX: 0000000100180d4b RSI: 0000000000000140 RDI: 000000000000ea60
[ 1874.632589] RBP: ffff88017940fdd8 R08: fffffffeffe8dd15 R09: 0000000000000000
[ 1874.639705] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
[ 1874.646822] R13: 0000000000000286 R14: ffffffff811ba4a9 R15: ffff88017940fcb8
[ 1874.653939] FS:  00007f65b567e740(0000) GS:ffff88027fc60000(0000) knlGS:0000000000000000
[ 1874.662006] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1874.667737] CR2: 0000000002c3c808 CR3: 0000000179606000 CR4: 00000000000007e0
[ 1874.674853] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1874.681970] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1874.689088] Process numad (pid: 564, threadinfo ffff88017940e000, task ffff8801786f32e0)
[ 1874.697153] Stack:
[ 1874.699164]  ffff88017940fd68 ffff880178d59800 000000d000000514 ffff8801786f32e0
[ 1874.706626]  ffff8802785e0c00 ffff88017940fe58 ffff8802727c4000 ffff88017940ff28
[ 1874.714087]  0000000000000000 0000000000000000 ffff8801786f32e0 ffffffff81097970
[ 1874.721549] Call Trace:
[ 1874.724000]  [<ffffffff81097970>] ? try_to_wake_up+0x2d0/0x2d0
[ 1874.729821]  [<ffffffff810e0feb>] audit_log_exit+0x4b/0xfe0
[ 1874.735388]  [<ffffffff811abf11>] ? do_filp_open+0x41/0xa0
[ 1874.740867]  [<ffffffff81185b43>] ? kmem_cache_free+0x33/0x140
[ 1874.746688]  [<ffffffff811a7856>] ? final_putname+0x26/0x50
[ 1874.752249]  [<ffffffff810e2cdf>] __audit_syscall_exit+0x25f/0x2c0
[ 1874.758420]  [<ffffffff81611980>] sysret_audit+0x17/0x21
[ 1874.763720] Code: c7 00 00 48 89 9d 78 ff ff ff 8b 15 a2 9e 83 00 8b 05 d8 9e 83 00 8b 0d 7a 6e b5 00 85 d2 48 63 f8 0f 84 4f 02 00 00 41 8d 34 16 <39> f1 0f 86 43 02 00 00 45 85 e4 0f 84 72 01 00 00 85 c0 0f 84
----------- snip -------------

my environment is 8Gb RAM with 2 NUMA nodes and I enabled 'numad' daemon(# systemctl start numad.service)
the reproducer comes from ltp suite: https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/oom/oom02.c
and I couldn't find the issue when I stopped numad service( # systemctl stop numad.service)

and I bisected the issue and found it just only occurred with the commit 9a928415(Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux)
when I reverted 9a928415(checkout ee61abb32 - module: fix missing module_mutex unlock), the issue is gone.

config file is here: http://sanweiying.fedorapeople.org/configs/config_softlockup
and more error log can be found here: http://sanweiying.fedorapeople.org/log/kernel/softlockup.log

-- 
Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
