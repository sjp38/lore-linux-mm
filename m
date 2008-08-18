Received: by gv-out-0910.google.com with SMTP id l14so1348277gvf.19
        for <linux-mm@kvack.org>; Mon, 18 Aug 2008 14:22:58 -0700 (PDT)
Message-ID: <48A9E82E.3060009@gmail.com>
Date: Mon, 18 Aug 2008 23:22:54 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm_owner: fix cgroup null dereference
References: <1218745013-9537-1-git-send-email-jirislaby@gmail.com> <48A49C78.7070100@linux.vnet.ibm.com>
In-Reply-To: <48A49C78.7070100@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 08/14/2008 10:58 PM, Balbir Singh wrote:
> Jiri Slaby wrote:
>> Hi,
>>
>> found this in mmotm, a fix for
>> mm-owner-fix-race-between-swap-and-exit.patch
>>
> 
> Thanks for catching this

Hmm, unfortunately there is one more issue with this patch.
memrlimit_cgroup_subsys doesn't expect NULL new cgroup and NULL task.
memrlimit_cgroup_mm_owner_changed blows up (called from
cgroup_mm_owner_callbacks as ss->mm_owner_changed).

I'm out for few days, please solve it somehow. Full oops message follows.

BUG: unable to handle kernel NULL pointer dereference at 00000000000004ac
IP: [<ffffffff8056c469>] _spin_lock+0x9/0x20
PGD 3ef84067 PUD 0
Oops: 0002 [2] SMP
last sysfs file: /sys/devices/platform/coretemp.1/temp1_input
CPU 0
Modules linked in: usblp ath5k mac80211 cfg80211 arc4 ecb cryptomgr aead
crypto_blkcipher crypto_algapi usbhid ohci1394 hid led_class ieee1394 evdev
rtc_cmos floppy ff_memless [last unloaded: cfg80211]
Pid: 27360, comm: automount Tainted: G      D W 2.6.27-rc3-mm1_64 #441
RIP: 0010:[<ffffffff8056c469>]  [<ffffffff8056c469>] _spin_lock+0x9/0x20
RSP: 0018:ffff88007839fd98  EFLAGS: 00010282
RAX: 0000000000000100 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff807d5f28 RDI: 00000000000004ac
RBP: ffff88007839fd98 R08: 00000000cc62b515 R09: 00000000f8f36e74
R10: 0000000000000001 R11: 0000000000000000 R12: 00000000000004ac
R13: ffffffff807d5f28 R14: ffff880047e2e500 R15: ffff880047e2e680
FS:  00007fca50fa66f0(0000) GS:ffffffff8070a480(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000000004ac CR3: 000000004510f000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process automount (pid: 27360, threadinfo ffff88007839e000, task ffff880047e2e500)
Stack:  ffff88007839fdb8 ffffffff80238ab3 ffffffff80589750 0000000000000000
 ffff88007839fde8 ffffffff802b3f4b ffff8800010205b0 ffffffff80589750
 0000000000000000 0000000000000000 ffff88007839fe18 ffffffff80270446
Call Trace:
 [<ffffffff80238ab3>] get_task_mm+0x23/0x60
 [<ffffffff802b3f4b>] memrlimit_cgroup_mm_owner_changed+0x1b/0x80
 [<ffffffff80270446>] cgroup_mm_owner_callbacks+0x76/0x90
 [<ffffffff8023d4d4>] mm_update_next_owner+0x1c4/0x240
 [<ffffffff8023d65a>] exit_mm+0x10a/0x150
 [<ffffffff8023f2ac>] do_exit+0x1dc/0x940
 [<ffffffff8023375b>] ? wake_up_state+0xb/0x10
 [<ffffffff802485c8>] ? signal_wake_up+0x38/0x40
 [<ffffffff8023fa50>] do_group_exit+0x40/0xb0
 [<ffffffff8023fad2>] sys_exit_group+0x12/0x20
 [<ffffffff8020c65b>] system_call_fastpath+0x16/0x1b
Code: 00 00 55 48 89 e5 fa f0 81 2f 00 00 00 01 74 05 e8 dd 17 de ff c9 c3 66 66
2e 0f 1f 84 00 00 00 00 00 55 b8 00 01 00 00 48 89 e5 <f0> 66 0f c1 07 38 e0 74
06 f3 90 8a 07 eb f6 c9 c3 66 0f 1f 44
RIP  [<ffffffff8056c469>] _spin_lock+0x9/0x20
 RSP <ffff88007839fd98>
CR2: 00000000000004ac
---[ end trace 4eaa2a86a8e2da22 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
