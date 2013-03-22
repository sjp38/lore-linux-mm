Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 17C436B0002
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 00:18:10 -0400 (EDT)
Date: Fri, 22 Mar 2013 00:18:09 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1456466672.4897467.1363925889061.JavaMail.root@redhat.com>
In-Reply-To: <1089649229.4894208.1363925156257.JavaMail.root@redhat.com>
Subject: BUG at kmem_cache_alloc
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: stable@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>

Starting to see those on 3.8.4 (never saw in 3.8.2) stable kernel on a few systems
during LTP run,

[11297.597242] BUG: unable to handle kernel paging request at 00000000fffffffe 
[11297.598022] IP: [] kmem_cache_alloc+0x68/0x1e0 
[11297.598022] PGD 7b9eb067 PUD 0  
[11297.598022] Oops: 0000 [#2] SMP  
[11297.598022] Modules linked in: cmtp kernelcapi bnep scsi_transport_iscsi rfcomm l2tp_ppp l2tp_netlink l2tp_core hidp ipt_ULOG af_key nfc rds pppoe pppox ppp_generic slhc af_802154 atm ip6table_filter ip6_tables iptable_filter ip_tables btrfs zlib_deflate vfat fat nfs_layout_nfsv41_files nfsv4 auth_rpcgss nfsv3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_log nfnetlink bluetooth rfkill arc4 md4 nls_utf8 cifs dns_resolver nf_tproxy_core nls_koi8_u nls_cp932 ts_kmp sctp sg kvm_amd kvm virtio_balloon i2c_piix4 pcspkr xfs libcrc32c ata_generic pata_acpi cirrus drm_kms_helper ttm ata_piix virtio_net drm libata virtio_blk i2c_core floppy dm_mirror dm_region_hash dm_log dm_mod [last unloaded: ipt_REJECT] 
[11297.598022] CPU 1  
[11297.598022] Pid: 14134, comm: ltp-pan Tainted: G      D      3.8.4+ #1 Bochs Bochs 
[11297.598022] RIP: 0010:[]  [] kmem_cache_alloc+0x68/0x1e0 
[11297.598022] RSP: 0018:ffff8800447dbdd0  EFLAGS: 00010246 
[11297.598022] RAX: 0000000000000000 RBX: ffff88007c169970 RCX: 00000000018acdcd 
[11297.598022] RDX: 000000000006c104 RSI: 00000000000080d0 RDI: ffff88007d04ac00 
[11297.598022] RBP: ffff8800447dbe10 R08: 0000000000017620 R09: ffffffff810fe2e2 
[11297.598022] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000fffffffe 
[11297.598022] R13: 00000000000080d0 R14: ffff88007d04ac00 R15: ffff88007d04ac00 
[11297.598022] FS:  00007f09c29b4740(0000) GS:ffff88007fd00000(0000) knlGS:00000000f74d86c0 
[11297.598022] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b 
[11297.598022] CR2: 00000000fffffffe CR3: 0000000037213000 CR4: 00000000000006e0 
[11297.598022] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
[11297.598022] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
[11297.598022] Process ltp-pan (pid: 14134, threadinfo ffff8800447da000, task ffff8800551ab2e0) 
[11297.598022] Stack: 
[11297.598022]  ffffffff810fe2e2 ffffffff8108cf0f 0000000001200011 ffff88007c169970 
[11297.598022]  0000000000000000 00007f09c29b4a10 0000000000000000 ffff88007c169970 
[11297.598022]  ffff8800447dbe30 ffffffff810fe2e2 0000000000000000 0000000001200011 
[11297.598022] Call Trace: 
[11297.598022]  [] ? __delayacct_tsk_init+0x22/0x40 
[11297.598022]  [] ? prepare_creds+0xdf/0x190 
[11297.598022]  [] __delayacct_tsk_init+0x22/0x40 
[11297.598022]  [] copy_process.part.25+0x31f/0x13f0 
[11297.598022]  [] do_fork+0xa9/0x350 
[11297.598022]  [] sys_clone+0x16/0x20 
[11297.598022]  [] stub_clone+0x69/0x90 
[11297.598022]  [] ? system_call_fastpath+0x16/0x1b 
[11297.598022] Code: 90 4d 89 fe 4d 8b 06 65 4c 03 04 25 c8 db 00 00 49 8b 50 08 4d 8b 20 4d 85 e4 0f 84 2b 01 00 00 49 63 46 20 4d 8b 06 41 f6 c0 0f <49> 8b 1c 04 0f 85 55 01 00 00 48 8d 4a 01 4c 89 e0 65 49 0f c7  
[11297.598022] RIP  [] kmem_cache_alloc+0x68/0x1e0 
[11297.598022]  RSP  
[11297.598022] CR2: 00000000fffffffe 
[11297.727799] ---[ end trace 037bde72f23b34d2 ]---

Never saw this in mainline but only something like this wondering could be related
(that kmem_cache_alloc also in the trace).

[12124.201919] INFO: task kworker/2:1:166 blocked for more than 120 seconds. 
[12124.242758] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message. 
[12124.289801] kworker/2:1     D ffff88081fc54440     0   166      2 0x00000000 
[12124.330784]  ffff88081361ba68 0000000000000046 ffff880813568000 ffff88081361bfd8 
[12124.373694]  ffff88081361bfd8 ffff88081361bfd8 ffff8808144fb2e0 ffff880813568000 
[12124.416896]  0000000000000000 ffff880813568000 ffff8808133f8930 0000000000000002 
[12124.458674] Call Trace: 
[12124.473291]  [] schedule+0x29/0x70 
[12124.502143]  [] rwsem_down_failed_common+0xda/0x230 
[12124.539311]  [] rwsem_down_write_failed+0x13/0x20 
[12124.575585]  [] call_rwsem_down_write_failed+0x13/0x20 
[12124.614129]  [] ? down_write+0x32/0x40 
[12124.644703]  [] xlog_cil_push+0x89/0x3c0 [xfs] 
[12124.680046]  [] ? up+0x32/0x50 
[12124.706083]  [] ? flush_work+0x113/0x170 
[12124.738078]  [] xlog_cil_force_lsn+0xf7/0x160 [xfs] 
[12124.776062]  [] ? xfs_trans_free_items+0x88/0xb0 [xfs] 
[12124.814503]  [] _xfs_log_force_lsn+0x5a/0x2e0 [xfs] 
[12124.851512]  [] xfs_trans_commit+0x263/0x270 [xfs] 
[12124.887996]  [] xfs_fs_log_dummy+0x61/0x90 [xfs] 
[12124.924015]  [] ? xfs_log_need_covered+0x93/0xc0 [xfs] 
[12124.963079]  [] xfs_log_worker+0x48/0x50 [xfs] 
[12124.997404]  [] process_one_work+0x174/0x3d0 
[12125.031408]  [] worker_thread+0x10f/0x390 
[12125.062936]  [] ? busy_worker_rebind_fn+0xb0/0xb0 
[12125.098924]  [] kthread+0xc0/0xd0 
[12125.126124]  [] ? kthread_create_on_node+0x120/0x120 
[12125.162995]  [] ret_from_fork+0x7c/0xb0 
[12125.193516]  [] ? kthread_create_on_node+0x120/0x120 
[12125.229431] INFO: task beah-beaker-bac:3331 blocked for more than 120 seconds. 
[12125.269795] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disabfd5bb59b0 0000000000000086 ffff881fbf770000 ffff881fd5bb5fd8 
[12129.329892]  ffff881fd5bb5fd8 ffff8Trace: 
[12134.346772]  [] schedule+0x29/0x70 
[12134.401771] 30 
[12136.376743]  [] ? kmem_cache_alloc+0x35/0x1e0 
[12136.411867]  [] rwsem_down_read_failed+0x15/0x17 
[12136.448141]  [] call_rwsem_down_read_failed+0x14/0x30 
[12136.487438]  [] ? kmem_alloc+0x67/0xf0 [xfs] 
[12136.521108]  [] ? down_read+0x24/0x2b 
[12136.549333]  [] xfs_log_commit_cil+0x1a6/0x4a0 [xfs] 
[12136.586227]  [] ? kmem_zone_alloc+0x67/0xf0 [xfs] 
[12136.621792]  [] xfs_trans_commit+0x134/0x270 [xfs] 
[12136.658163]  [] xfs_vn_update_time+0xf7/0x1a0 [xfs] 
[12136.694257]  [] update_time+0x23/0xc0 
[12136.722821]  [] ? mnt_clone_write+0x12/0x30 
[12136.755240]  [] file_update_time+0x98/0xf0 
[12136.785989]  [] xfs_file_aio_write_checks+0xdb/0xf0 [xfs] 
[12136.825592]  [] xfs_file_buffered_aio_write+0x7b/0x1a0 [xfs] 
[12136.868827]  [] xfs_file_aio_write+0xf9/0x160 [xfs] 
[12136.907037]  [] do_sync_write+0xa7/0xe0 
[12136.939287]  [] vfs_write+0xac/0x180 
[12136.969067]  [] sys_pwrite64+0x9a/0xb0 
[12137.000528]  [] system_call_fastpath+0x16/0x1b 
[12137.036022] INFO: task master:3497 blocked for more than 120 seconds. 
[12137.073730] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message. 
[12137.117609] master          D ffff88101fd54440     0  3497      1 0x00000080 
[12137.155846]  ffff8808091a3a60 0000000000000082 ffff880813079970 ffff8808091a3fd8 
[12137.197460]  ffff8808091a3fd8 ffff8808091a3fd8 ffff8808145432e0 ffff880813079970 
[12137.239430]  ffff8808091a3a88 ffff880813079970 ffff8808133f8930 0000000000000001 
[12137.279786] Call Trace: 
[12137.293627]  [] schedule+0x29/0x70 
[12137.321390]  [] rwsem_down_failed_common+0xda/0x230 
[12137.357677]  [] ? __enqueue_entity+0x78/0x80 
[12137.390943]  [] ? kmem_cache_alloc+0x35/0x1e0 
[12137.426089]  [] rwsem_down_read_failed+0x15/0x17 
[12137.462395]  [] call_rwsem_down_read_failed+0x14/0x30 
[12137.502332]  [] ? kmem_alloc+0x67/0xf0 [xfs] 
[12137.537843]  [] ? down_read+0x24/

Any idea?

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
