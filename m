Received: by mu-out-0910.google.com with SMTP id i2so1705434mue.6
        for <linux-mm@kvack.org>; Mon, 09 Jun 2008 23:20:51 -0700 (PDT)
Message-ID: <484E1D03.7050400@gmail.com>
Date: Tue, 10 Jun 2008 08:19:47 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: sock lockup -> process in D state [Was: 2.6.26-rc5-mm1]
References: <20080609053908.8021a635.akpm@linux-foundation.org>	<484DAF9D.5080702@gmail.com> <20080609160154.218f3e69.akpm@linux-foundation.org>
In-Reply-To: <20080609160154.218f3e69.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/10/2008 01:01 AM, Andrew Morton wrote:
> On Tue, 10 Jun 2008 00:33:01 +0200
> Jiri Slaby <jirislaby@gmail.com> wrote:
> 
>> On 06/09/2008 02:39 PM, Andrew Morton wrote:
>>>   ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm1/
>> I don't know how to reproduce it so far, but posting anyway:
>>
>> httpd2-prefor D 00000000ffffffff     0  3697   2811
>>   ffff810055bd7198 0000000000000046 ffff810055bd7160 ffff810055bd715c
>>   ffffffff80728000 ffff810063896700 ffff81007d093380 ffff810063896980
>>   00000001781e1700 00000001005585a6 ffff810063896980 0000000000000600
>> Call Trace:
>>   [<ffffffff8049d6fd>] lock_sock_nested+0x8d/0xd0
[...]
> 
> Looks like it tried to go BUG then deadlocked.  Didn't it print BUG
> stuff into the logs?
> 
> And I'd guess that you hit the unlock_page() BUG (Subject: Re:
> 2.6.26-rc5-mm1: kernel BUG at mm/filemap.c:575!).

Yeah, you're right. I didn't notice it earlier, since 2 unsuccessful suspends 
tainted logs with task stacks.

This is the first Oops. The same with httpd is in the logs too.

------------[ cut here ]------------
kernel BUG at /home/l/latest/xxx/mm/filemap.c:575!
invalid opcode: 0000 [1] SMP
last sysfs file: /sys/devices/virtual/net/tun0/statistics/collisions
CPU 0
Modules linked in: usbhid hid ohci1394 floppy ff_memless ieee1394 rtc_cmos evdev 
[last unloaded: freq_table]
Pid: 27195, comm: find Not tainted 2.6.26-rc5-mm1_64 #417
RIP: 0010:[<ffffffff80277ec7>]  [<ffffffff80277ec7>] unlock_page+0x17/0x40
RSP: 0018:ffff810059851618  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffe20000679b70 RCX: 0000000000000035
RDX: 0000000000000000 RSI: ffffe20000679b70 RDI: ffffe20000679b70
RBP: ffff810059851628 R08: db80000000000000 R09: e000000000000000
R10: ffffe20000a494c8 R11: ffff81002f05fa50 R12: ffffe20000679b98
R13: ffff810059851898 R14: ffff8100598519b8 R15: 0000000000000000
FS:  00007fa7478a56f0(0000) GS:ffffffff806d2300(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f62ec2fe000 CR3: 00000000591ac000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process find (pid: 27195, threadinfo ffff810059850000, task ffff810078346700)
Stack:  ffff810059851628 ffffe20000679b70 ffff810059851768 ffffffff8028386d
  ffff810059851728 ffff8100598516e8 ffff810059851658 0000000000000000
  0000001400000000 0000000000000002 0000000000000002 0000000000000001
Call Trace:
  [<ffffffff8028386d>] shrink_page_list+0x2fd/0x720
  [<ffffffff80282ad3>] ? isolate_pages_global+0x1c3/0x270
  [<ffffffff80283ed0>] shrink_list+0x240/0x5e0
  [<ffffffff802844c3>] shrink_zone+0x253/0x330
  [<ffffffff80285441>] try_to_free_pages+0x251/0x3e0
  [<ffffffff80282910>] ? isolate_pages_global+0x0/0x270
  [<ffffffff8027e8ff>] __alloc_pages_internal+0x20f/0x4e0
  [<ffffffff802a0e04>] __slab_alloc+0x6d4/0x6f0
  [<ffffffff80308a45>] ? ext3_alloc_inode+0x15/0x40
  [<ffffffff802a1165>] kmem_cache_alloc+0x95/0xa0
  [<ffffffff80308a45>] ext3_alloc_inode+0x15/0x40
  [<ffffffff802bbdac>] alloc_inode+0x1c/0x1b0
  [<ffffffff802bbfb0>] iget_locked+0x70/0x170
  [<ffffffff802ffd87>] ext3_iget+0x17/0x3f0
  [<ffffffff80306cf8>] ext3_lookup+0xa8/0x100
  [<ffffffff802ba6c3>] ? d_alloc+0x123/0x1b0
  [<ffffffff802adb36>] do_lookup+0x1c6/0x220
  [<ffffffff802af4bb>] __link_path_walk+0x37b/0x1030
  [<ffffffff8029ee95>] ? check_object+0x265/0x270
  [<ffffffff8029e6c0>] ? init_object+0x50/0x90
  [<ffffffff802b01d6>] path_walk+0x66/0xd0
  [<ffffffff802b0492>] do_path_lookup+0xa2/0x240
  [<ffffffff802b142c>] __user_walk_fd+0x4c/0x80
  [<ffffffff802a89cb>] vfs_lstat_fd+0x2b/0x70
  [<ffffffff802a8ba3>] ? cp_new_stat+0xe3/0xf0
  [<ffffffff802c011a>] ? mntput_no_expire+0x2a/0x190
  [<ffffffff802a8c0c>] sys_newfstatat+0x5c/0x80
  [<ffffffff802a640d>] ? fput+0x1d/0x30
  [<ffffffff802a2b9b>] ? filp_close+0x5b/0x90
  [<ffffffff802a2c7d>] ? sys_close+0xad/0x100
  [<ffffffff8020c42b>] system_call_after_swapgs+0x7b/0x80

Code: 1f 44 00 00 eb c5 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 
48 89 fb 48 83 ec 08 f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 f0 ee ff 
ff 48 89 de 48 89 c7 31 d2 e8 c3 60 fd
RIP  [<ffffffff80277ec7>] unlock_page+0x17/0x40
  RSP <ffff810059851618>
---[ end trace 2a52a1962aabcbb2 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
