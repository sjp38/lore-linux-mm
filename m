Date: Sun, 3 Jun 2007 20:30:03 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: tmpfs and numa mempolicy
Message-Id: <20070603203003.64fd91a8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi,

If someone mounts tmpfs as in

> mount -t tmpfs -o size=10g,nr_inodes=10k,mode=777,mpol=prefer:1 \
	tmpfs /mytmpfs

but does not have a node 1, bad things happen when /mytmpfs is accessed.
(CONFIG_NUMA=y)


Is this just a case of shoot self in foot, DDT (don't do that)?


a.  cp somefile /mytmpfs

Unable to handle kernel paging request at 00000000000019e8 RIP: 
 [<ffffffff8026c369>] __alloc_pages+0x3e/0x2c6
PGD 3851f067 PUD 384f5067 PMD 0 
Oops: 0000 [1] SMP 
CPU 0 
Modules linked in: snd_pcm_oss snd_mixer_oss snd_seq loop snd_via82xx snd_ac97_codec ac97_b
us snd_pcm snd_timer snd_page_alloc snd_mpu401_uart snd_rawmidi snd_seq_device snd soundcor
e lp
Pid: 3762, comm: cp Not tainted 2.6.22-rc3 #2
RIP: 0010:[<ffffffff8026c369>]  [<ffffffff8026c369>] __alloc_pages+0x3e/0x2c6
RSP: 0018:ffff810038629cd8  EFLAGS: 00010202
RAX: 0000000000000246 RBX: 0000000000000000 RCX: ffff810038629db8
RDX: 00000000000019e0 RSI: 00000000000004c7 RDI: ffffffff805f8bcf
RBP: ffff810038629d38 R08: 0000000000000000 R09: ffff810038629db8
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000000280d2
R13: 00000000000019e0 R14: ffff810039e42760 R15: 0000000000000000
FS:  00002af4c02d6ec0(0000) GS:ffffffff806bd000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000000019e8 CR3: 00000000384e3000 CR4: 00000000000006e0
Process cp (pid: 3762, threadinfo ffff810038628000, task ffff810039e42760)
Stack:  0000000000000001 0000000000000000 0000001038629d18 ffffffff8028494d
 0000000000000000 00000000ffffffe5 ffff810039836450 0000000000000000
 ffff810038629db8 00000000000280d2 ffff810039836418 0000000000000000
Call Trace:
 [<ffffffff8028494d>] shmem_swp_entry+0x4b/0x14a
 [<ffffffff8028330a>] alloc_page_vma+0x7c/0x85
 [<ffffffff8028548f>] shmem_getpage+0x453/0x6e8
 [<ffffffff802868d1>] shmem_file_write+0x124/0x217
 [<ffffffff8028c32d>] vfs_write+0xae/0x137
 [<ffffffff8028c895>] sys_write+0x47/0x70
 [<ffffffff8020948e>] system_call+0x7e/0x83

Code: 49 83 7d 08 00 75 0d 48 c7 45 b8 00 00 00 00 e9 61 02 00 00 
RIP  [<ffffffff8026c369>] __alloc_pages+0x3e/0x2c6
 RSP <ffff810038629cd8>
CR2: 00000000000019e8


b.  umount /mytmpfs

kernel BUG at mm/shmem.c:775!
invalid opcode: 0000 [2] SMP 
CPU 0 
Modules linked in: snd_pcm_oss snd_mixer_oss snd_seq loop snd_via82xx snd_ac97_codec ac97_b
us snd_pcm snd_timer snd_page_alloc snd_mpu401_uart snd_rawmidi snd_seq_device snd soundcor
e lp
Pid: 3810, comm: umount Not tainted 2.6.22-rc3 #2
RIP: 0010:[<ffffffff802865eb>]  [<ffffffff802865eb>] shmem_delete_inode+0xc6/0xfa
RSP: 0018:ffff810038031d28  EFLAGS: 00010202
RAX: ffff810038031cc8 RBX: ffff8100398364f8 RCX: ffff810039836418
RDX: 0000000000000000 RSI: 00000000319494db RDI: 0000000004020010
RBP: ffff810038031d48 R08: 0000000000000000 R09: ffff81003afa1bb8
R10: ffff81003afa1aa8 R11: ffff810038031d88 R12: ffff810039836508
R13: ffff81003d742b40 R14: 0000000000000001 R15: 000000000060ba30
FS:  00002b16c0aedb00(0000) GS:ffffffff806bd000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00002b236e37e000 CR3: 000000003848d000 CR4: 00000000000006e0
Process umount (pid: 3810, threadinfo ffff810038030000, task ffff81003c9288a0)
Stack:  ffff81003d7a81c8 ffffffff80286525 ffff810039836508 ffff81003d7a81c8
 ffff810038031d68 ffffffff8029e5bd ffff810039836508 ffff8100384f45f8
 ffff810038031d88 ffffffff8029db6f ffff810038031d88 ffff81003d7a8158
Call Trace:
 [<ffffffff80286525>] shmem_delete_inode+0x0/0xfa
 [<ffffffff8029e5bd>] generic_delete_inode+0x7b/0xfb
 [<ffffffff8029db6f>] iput+0x7c/0x80
 [<ffffffff8029bcc6>] shrink_dcache_for_umount_subtree+0x20e/0x262
 [<ffffffff803275bb>] __down_read_trylock+0x3f/0x46
 [<ffffffff8029cca4>] shrink_dcache_for_umount+0x37/0x47
 [<ffffffff8028d89a>] generic_shutdown_super+0x1a/0xd8
 [<ffffffff8028d992>] kill_anon_super+0x11/0x41
 [<ffffffff8028d9e4>] kill_litter_super+0x22/0x26
 [<ffffffff8028da34>] deactivate_super+0x4c/0x61
 [<ffffffff802a06b7>] mntput_no_expire+0x59/0x8d
 [<ffffffff80292765>] path_release_on_umount+0x1d/0x21
 [<ffffffff802a0eea>] sys_umount+0x1fd/0x232
 [<ffffffff8028ef11>] sys_newstat+0x22/0x3c
 [<ffffffff8020948e>] system_call+0x7e/0x83

Code: 0f 0b eb fe 49 83 7d 10 00 74 18 49 8d 5d 30 48 89 df e8 f9 
RIP  [<ffffffff802865eb>] shmem_delete_inode+0xc6/0xfa
 RSP <ffff810038031d28>

Thanks.
---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
