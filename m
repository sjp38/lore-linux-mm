Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5476B004D
	for <linux-mm@kvack.org>; Sat, 20 Jun 2009 15:55:48 -0400 (EDT)
Date: Sat, 20 Jun 2009 13:57:31 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: Question about warning and later oops slub/jbd2
Message-ID: <20090620195731.GO19977@parisc-linux.org>
References: <c2fe070d0906201254w75b902e9jc9796efd465a4a80@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2fe070d0906201254w75b902e9jc9796efd465a4a80@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: leandro Costantino <lcostantino@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This isn't a filesystem problem, this is a problem with SLUB.
Redirecting to linux-mm and linux-kernel.

On Sat, Jun 20, 2009 at 03:54:52PM -0400, leandro Costantino wrote:
> Hi, i just wanted to know from people that know about mm/fs subject,
> if the follow
> "oops" its an expected behavior (kinda feature ) or not, since i was
> just touching some files and suddenly started to happen. Please CC me
> since i am not subscribed to the list.
> 
> I consider myself ignorant about this subject to make any asumption,
> so i'll try to explain what's going on.
> 
> Using lastest git kernel (2.6.30-6701-g4b67c5d), and also tested on
> 2.6.28-rc2 both smp.
> 
> (Modules: jbd2 )
> 
> No "oops" reported when:
> Booting with slub_debug=ZPU , the caches are not merged, so doing
> something like this
>  # modprobe jbd2 ( or ext4 )
>  # ls -la /sys/kernel/slab|grep jbd2
> ...
> drwxr-xr-x   2 root root 0 Jun 20 20:50 jbd2_journal_handle
> drwxr-xr-x   2 root root 0 Jun 20 20:50 jbd2_journal_head
> drwxr-xr-x   2 root root 0 Jun 20 20:50 jbd2_revoke_record
> drwxr-xr-x   2 root root 0 Jun 20 20:50 jbd2_revoke_table
> ....
>  Next, when removing the module:  (rmmod jbd2 or modprobe -r ext4 ),
> the jbd2_* files
>  are removed from sys.
> 
> But, when booting with slub_debug=- ( or disabling slub debug directly
> from kernel ), the caches are merged , so  after modprobe ext4 (or
> jbd2)  /sys/kernel/slab|grep jbd2 reports something like:
> lrwxrwxrwx  1 root root 0 Jun 20 21:00 jbd2_journal_handle -> :at-0000040
> lrwxrwxrwx  1 root root 0 Jun 20 21:00 jbd2_journal_head -> :at-0000064
> lrwxrwxrwx  1 root root 0 Jun 20 21:00 jbd2_revoke_record -> :at-0000032
> lrwxrwxrwx  1 root root 0 Jun 20 21:00 jbd2_revoke_table -> :at-0000016
> 
> slabinfo -a reports:
> -------------------------------
> :at-0000016  <- revoke_record revoke_table jbd2_revoke_table
> :at-0000040  <- jbd2_journal_handle journal_handle ext4_free_block_extents
> :at-0000048  <- ext3_xattr ext2_xattr ext4_xattr
> :at-0000064  <- journal_head jbd2_journal_head
> :t-0000008   <- kmalloc-8 dm_rq_clone_bio_info
> :t-0000016   <- inotify_event_private_data kmalloc-16 ip_fib_alias
> dm_target_io dm_snap_tracked_chunk fsnotify_event_holder fasync_cache
> :t-0000024   <- Acpi-Namespace dm_io debug_objects_cache
> dm_snap_exception dnotify_struct scsi_data_buffer nsproxy
> :t-0000032   <- kmalloc-32 fib6_nodes tcp_bind_bucket uhci_urb_priv
> secpath_cache Acpi-Parse
> :t-0000040   <- Acpi-Operand ip_fib_hash eventpoll_pwq
> :t-0000048   <- Acpi-ParseExt sysfs_dir_cache Acpi-State
> :t-0000064   <- inet_peer_cache dm_snap_pending_exception uid_cache
> pid nfs_page kmalloc-64
> :t-0000080   <- blkdev_ioc flow_cache
> :t-0000096   <- inotify_inode_mark_entry cfq_io_context fsnotify_event
> kmalloc-96 dnotify_mark_entry
> :t-0000128   <- request_sock_TCP ip_mrt_cache mnt_cache cred_jar bio-0
> scsi_sense_cache eventpoll_epi request_sock_TCPv6 kmalloc-128
> :t-0000192   <- kiocb biovec-16 skbuff_head_cache kmalloc-192
> scsi_cmd_cache filp key_jar rpc_tasks sgpool-8
> :t-0000256   <- arp_cache kmalloc-256 ndisc_cache ip6_dst_cache ip_dst_cache
> :t-0000320   <- sgpool-16 xfrm_dst_cache
> :t-0000384   <- kioctx nfs_read_data skbuff_fclone_cache
> :t-0000768   <- biovec-64 RAW
> :t-0002048   <- kmalloc-2048 rpc_buffers
> :t-0004096   <- names_cache kmalloc-4096
> -------[eof]-------
> 
> Now , when modprobe -r ext4 ( or rmmod jbd2), the jbd2_* files are
> still listed on /sys/kernel/slab
> and slabinfo start to report some alias errors. I suppose they are not
> remove if they have been merged on some cache that's still being used
> by some "alias" or if they have persistent in-kernel storage.
> Since the "alias" or files are still listed, when doing:
> 
>    # echo 1 > /sys/kernel/slab/jbd2_journal_handle/poison
>    # modprobe ext4 ( or modprobe jbd2 )
> 
> this oops appears and later a bunch of another oops, making the system
> unresponsive.
> 
> [   65.132850] ------------[ cut here ]------------
> [   65.132925] WARNING: at fs/sysfs/dir.c:487 sysfs_add_one+0xf6/0x120()
> [   65.132989] Hardware name: Extensa 5420
> [   65.133069] sysfs: cannot create duplicate filename
> '/kernel/slab/:at-0000040'
> [   65.133154] Modules linked in: jbd2(+) crc16 loop
> snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 ecb snd_hwdep
> cryptomgr aead snd_pcm_oss snd_pcm pcompress crypto_blkcipher
> snd_mixer_oss crypto_hash crypto_algapi snd_seq_oss $
> [   65.135932] Pid: 4507, comm: modprobe Tainted: G    B
> 2.6.30-obelisco-generic #29
> [   65.136026] Call Trace:
> [   65.136087]  [<c113b566>] ? sysfs_add_one+0xf6/0x120
> [   65.136151]  [<c1042c9d>] warn_slowpath_common+0x7d/0xe0
> [   65.136215]  [<c113b566>] ? sysfs_add_one+0xf6/0x120
> [   65.136278]  [<c1042d73>] warn_slowpath_fmt+0x33/0x50
> [   65.136341]  [<c113b566>] sysfs_add_one+0xf6/0x120
> [   65.136403]  [<c113bc6a>] create_dir+0x5a/0xb0
> [   65.136465]  [<c113bcf6>] sysfs_create_dir+0x36/0x60
> [   65.136530]  [<c14cd4fb>] ? _spin_unlock+0x2b/0x50
> [   65.136595]  [<c11c69b4>] kobject_add_internal+0xd4/0x1d0
> [   65.136659]  [<c11c6bdd>] kobject_add_varg+0x3d/0x70
> [   65.136721]  [<c11c6c4e>] kobject_init_and_add+0x3e/0x60
> [   65.136785]  [<c10e1772>] sysfs_slab_add+0x82/0x220
> [   65.136849]  [<c10e1b38>] kmem_cache_create+0xe8/0x2f0
> [   65.137716]  [<f8ae80b5>] ? journal_init+0x0/0xd5 [jbd2]
> [   65.137782]  [<f8ae8153>] journal_init+0x9e/0xd5 [jbd2]
> [   65.137845]  [<c1001155>] do_one_initcall+0x35/0x180
> [   65.137909]  [<c1063b54>] ? up_read+0x24/0x50
> [   65.137972]  [<c1064993>] ? __blocking_notifier_call_chain+0x63/0x90
> [   65.138047]  [<c10649e7>] ? blocking_notifier_call_chain+0x27/0x50
> [   65.138111]  [<c10850a2>] sys_init_module+0xc2/0x210
> [   65.138175]  [<c10032ef>] sysenter_do_call+0x12/0x3c
> [   65.138237] ---[ end trace 16c86c85e40c183d ]---
> [   65.138301] kobject_add_internal failed for :at-0000040 with
> -EEXIST, don't try to register things with the same name in the same
> directory.
> [   65.138390] Pid: 4507, comm: modprobe Tainted: G    B   W
> 2.6.30-obelisco-generic #29
> [   65.138474] Call Trace:
> [   65.138534]  [<c14c99d3>] ? printk+0x23/0x40
> [   65.138596]  [<c11c69f8>] kobject_add_internal+0x118/0x1d0
> [   65.138660]  [<c11c6bdd>] kobject_add_varg+0x3d/0x70
> [   65.138722]  [<c11c6c4e>] kobject_init_and_add+0x3e/0x60
> [   65.138786]  [<c10e1772>] sysfs_slab_add+0x82/0x220
> [   65.138848]  [<c10e1b38>] kmem_cache_create+0xe8/0x2f0
> [   65.138913]  [<f8ae80b5>] ? journal_init+0x0/0xd5 [jbd2]
> [   65.138979]  [<f8ae8153>] journal_init+0x9e/0xd5 [   65.139243]
> [<c10649e7>] ? blocking_notifier_call_chain+0x27/0x50
> [   65.139307]  [<c10850a2>] sys_init_module+0xc2/0x210
> [   65.139369]  [<c10032ef>] sysenter_do_call+0x12/0x3c
> [   65.141247] BUG: unable to handle kernel NULL pointer dereference at (null)
> [   65.141396] IP: [<c11d46a7>] list_del+0x17/0xb0
> [   65.141500] *pde = 00000000
> [   65.141597] Oops: 0000 [#1] SMP
> [   65.141732] last sysfs file: /sys/kernel/slab/:at-0000040/poison
> [   65.141795] Modules linked in: jbd2(+) crc16 loop
> snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 ecb snd_hwdep
> cryptomgr aead snd_pcm_oss snd_pcm pcompress crypto_blkcipher
> snd_mixer_oss crypto_hash crypto_algapi snd_seq_oss $
> [   65.142015]
> [   65.142015] Pid: 4507, comm: modprobe Tainted: G    B   W
> (2.6.30-obelisco-generic #29) Extensa 5420
> [   65.142015] EIP: 0060:[<c11d46a7>] EFLAGS: 00010246 CPU: 0
> [   65.142015] EIP is at list_del+0x17/0xb0
> [   65.142015] EAX: 00000000 EBX: f7374df8 ECX: 00000000 EDX: 00000000
> [   65.142015] ESI: f7374d80 EDI: f8ae0416 EBP: c3633ea0 ESP: c3633e84
> [   65.142015]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [   65.142015] Process modprobe (pid: 4507, ti=c3632000 task=c3a0c060
> task.ti=c3632000)
> [   65.142015] Stack:
> [   65.142015]  00000002 00000000 c10e1b46 fc41b58e f7374d80 fc41b58e
> f7374d80 c3633ef0
> [   65.142015] <0> c10e1b4e 00000028 00000000 00020000 00000000
> 00000000 00020000 00000000
> [   65.142015] <0> 00000028 f7374df8 00000000 00000005 0000002b
> fffffff8 00020000 fc41b58e
> [   65.142015] Call Trace:
> [   65.142015]  [<c10e1b46>] ? kmem_cache_create+0xf6/0x2f0
> [   65.142015]  [<c10e1b4e>] ? kmem_cache_create+0xfe/0x2f0
> [   65.142015]  [<f8ae80b5>] ? journal_init+0x0/0xd5 [jbd2]
> [   65.142015]  [<f8ae8153>] ? journal_init+0x9e/0xd5 [jbd2]
> [   65.142015]  [<c1001155>] ? do_one_initcall+0x35/0x180
> [   65.142015]  [<c1063b54>] ? up_read+0x24/0x50
> [   65.142015]  [<c1064993>] ? __blocking_notifier_call_chain+0x63/0x90
> [   65.142015]  [<c10649e7>] ? blocking_notifier_call_chain+0x27/0x50
> [   65.142015]  [<c10850a2>] ? sys_init_module+0xc2/0x210
> [   65.142015]  [<c10032ef>] ? sysenter_do_call+0x12/0x3c
> [   65.142015] Code: 75 fc 89 ec 5d c3 e8 f9 e7 e6 ff 90 90 90 90 90
> 90 90 90 90 55 89 e5 53 89 c3 83 ec 18 65 a1 14 00 00 00 89 45 f8 31
> c0 8b 43 04 <8b> 00 39 d8 75 5d 8b 13 8b 42 04 39 d8 75 2c 8b 43 04 89
> 42 04
> [   65.142015] EIP: [<c11d46a7>] list_del+0x17/0xb0 SS:ESP 0068:c3633e84
> [   65.142015] CR2: 0000000000000000
> [   65.149731] ---[ end trace 16c86c85e40c183e ]---
> [jbd2]
> [   65.139053]  [<c1001155>] do_one_initcall+0x35/0x180
> [   65.139116]  [<c1063b54>] ? up_read+0x24/0x50
> [   65.139179]  [<c1064993>] ? __blocking_notifier_call_chain+0x63/0x90
> 
> [more oops, related to other operations]
> 
> 
> So to resume all the wrong assumptions i wrote, this is reproducible
> in my case doing:
> 
>         #modprobe jbd2      ( or any dependent module)
>         #rmmod jbd2     ( or any dependent module, [-r] in that case )
>         #echo 1 > /sys/kernel/slab/jbd2_journal_handle/poison
>         #modprobe jbd2
> 
> Is this "behavior" expected since the caches are merged? or i am just
> writing bs and its related to another thing?
> 
> Best Rgds
> Sorry if i make some ppl loose time reading this.
> Costantino Leandro
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
