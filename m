Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1F183900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 21:34:02 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p3U1Xw89030927
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 18:33:59 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by kpbe19.cbf.corp.google.com with ESMTP id p3U1Xs7H005723
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 18:33:56 -0700
Received: by qwk3 with SMTP id 3so1944641qwk.19
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 18:33:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110429232039.GA1780@barrios-desktop>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
	<20110429164415.GA2006@barrios-desktop>
	<BANLkTik6D5OYTLS0FcQ9BYDpy_J1+kpD6A@mail.gmail.com>
	<BANLkTi=5ZeTV+CCRHDWy_1fwXrD9_2zj-A@mail.gmail.com>
	<20110429232039.GA1780@barrios-desktop>
Date: Fri, 29 Apr 2011 18:33:54 -0700
Message-ID: <BANLkTi=tj0NnnVDEbk5S3E_nOOoYt=EHgQ@mail.gmail.com>
Subject: Re: [PATCH 0/2] memcg: add the soft_limit reclaim in global direct reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, Apr 29, 2011 at 4:20 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, Apr 29, 2011 at 11:58:34AM -0700, Ying Han wrote:
>> On Fri, Apr 29, 2011 at 10:19 AM, Ying Han <yinghan@google.com> wrote:
>> > On Fri, Apr 29, 2011 at 9:44 AM, Minchan Kim <minchan.kim@gmail.com> w=
rote:
>> >> Hi Ying,
>> >>
>> >> On Thu, Apr 28, 2011 at 03:37:04PM -0700, Ying Han wrote:
>> >>> We recently added the change in global background reclaim which coun=
ts the
>> >>> return value of soft_limit reclaim. Now this patch adds the similar =
logic
>> >>> on global direct reclaim.
>> >>>
>> >>> We should skip scanning global LRU on shrink_zone if soft_limit recl=
aim does
>> >>> enough work. This is the first step where we start with counting the=
 nr_scanned
>> >>> and nr_reclaimed from soft_limit reclaim into global scan_control.
>> >>>
>> >>> The patch is based on mmotm-04-14 and i triggered kernel BUG at mm/v=
mscan.c:1058!
>> >>
>> >> Could you tell me exact patches?
>> >> mmtom-04-14 + just 2 patch of this? or + something?
>> >>
>> >> These day, You and Kame produces many patches.
>> >> Do I have to apply something of them?
>> > No, I applied my patch on top of mmotm and here is the last commit
>> > before my patch.
>> >
>> > commit 66a3827927351e0f88dc391919cf0cda10d42dd7
>> > Author: Andrew Morton <akpm@linux-foundation.org>
>> > Date: =A0 Thu Apr 14 15:51:34 2011 -0700
>> >
>> >>
>> >>>
>> >>> [ =A0938.242033] kernel BUG at mm/vmscan.c:1058!
>> >>> [ =A0938.242033] invalid opcode: 0000 [#1] SMP=B7
>> >>> [ =A0938.242033] last sysfs file: /sys/devices/pci0000:00/0000:00:1f=
.2/device
>> >>> [ =A0938.242033] Pid: 546, comm: kswapd0 Tainted: G =A0 =A0 =A0 =A0W=
 =A0 2.6.39-smp-direct_reclaim
>> >>> [ =A0938.242033] RIP: 0010:[<ffffffff810ed174>] =A0[<ffffffff810ed17=
4>] isolate_pages_global+0x18c/0x34f
>> >>> [ =A0938.242033] RSP: 0018:ffff88082f83bb50 =A0EFLAGS: 00010082
>> >>> [ =A0938.242033] RAX: 00000000ffffffea RBX: ffff88082f83bc90 RCX: 00=
00000000000401
>> >>> [ =A0938.242033] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ff=
ffea001ca653e8
>> >>> [ =A0938.242033] RBP: ffff88082f83bc20 R08: 0000000000000000 R09: ff=
ff88085ffb6e00
>> >>> [ =A0938.242033] R10: ffff88085ffb73d0 R11: ffff88085ffb6e00 R12: ff=
ff88085ffb6e00
>> >>> [ =A0938.242033] R13: ffffea001ca65410 R14: 0000000000000001 R15: ff=
ffea001ca653e8
>> >>> [ =A0938.242033] FS: =A00000000000000000(0000) GS:ffff88085fd00000(0=
000) knlGS:0000000000000000
>> >>> [ =A0938.242033] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> >>> [ =A0938.242033] CR2: 00007f5c3405c320 CR3: 0000000001803000 CR4: 00=
000000000006e0
>> >>> [ =A0938.242033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00=
00000000000000
>> >>> [ =A0938.242033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00=
00000000000400
>> >>> [ =A0938.242033] Process kswapd0 (pid: 546, threadinfo ffff88082f83a=
000, task ffff88082fe52080)
>> >>> [ =A0938.242033] Stack:
>> >>> [ =A0938.242033] =A0ffff88085ffb6e00 ffffea0000000002 00000000000000=
21 0000000000000000
>> >>> [ =A0938.242033] =A00000000000000000 ffff88082f83bcb8 ffffea00108eec=
80 ffffea00108eecb8
>> >>> [ =A0938.242033] =A0ffffea00108eecf0 0000000000000004 ffffffffffffff=
fc 0000000000000020
>> >>> [ =A0938.242033] Call Trace:
>> >>> [ =A0938.242033] =A0[<ffffffff810ee8a5>] shrink_inactive_list+0x185/=
0x418
>> >>> [ =A0938.242033] =A0[<ffffffff810366cc>] ? __switch_to+0xea/0x212
>> >>> [ =A0938.242033] =A0[<ffffffff810e8b35>] ? determine_dirtyable_memor=
y+0x1a/0x2c
>> >>> [ =A0938.242033] =A0[<ffffffff810ef19b>] shrink_zone+0x380/0x44d
>> >>> [ =A0938.242033] =A0[<ffffffff810e5188>] ? zone_watermark_ok_safe+0x=
a1/0xae
>> >>> [ =A0938.242033] =A0[<ffffffff810efbd8>] kswapd+0x41b/0x76b
>> >>> [ =A0938.242033] =A0[<ffffffff810ef7bd>] ? zone_reclaim+0x2fb/0x2fb
>> >>> [ =A0938.242033] =A0[<ffffffff81088569>] kthread+0x82/0x8a
>> >>> [ =A0938.242033] =A0[<ffffffff8141b0d4>] kernel_thread_helper+0x4/0x=
10
>> >>> [ =A0938.242033] =A0[<ffffffff810884e7>] ? kthread_worker_fn+0x112/0=
x112
>> >>> [ =A0938.242033] =A0[<ffffffff8141b0d0>] ? gs_change+0xb/0xb
>> >>>
>> >>
>> >> It seems there is active page in inactive list.
>> >> As I look deactivate_page, lru_deactivate_fn clears PageActive before
>> >> add_page_to_lru_list and it should be protected by zone->lru_lock.
>> >> In addiion, PageLRU would protect with race with isolation functions.
>> >>
>> >> Hmm, I don't have any clue now.
>> >> Is it reproducible easily?
>> > I can manage to reproduce it on my host by adding lots of memory
>> > pressure and then trigger the global
>> > reclaim.
>> >
>> >>
>> >> Could you apply below debugging patch and report the result?
>> >>
>> >> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
>> >> index 8f7d247..f39b53a 100644
>> >> --- a/include/linux/mm_inline.h
>> >> +++ b/include/linux/mm_inline.h
>> >> @@ -25,6 +25,8 @@ static inline void
>> >> =A0__add_page_to_lru_list(struct zone *zone, struct page *page, enum =
lru_list l,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *head)
>> >> =A0{
>> >> + =A0 =A0 =A0 VM_BUG_ON(PageActive(page) && (
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l =3D=3D LRU_INACTIVE_A=
NON || l =3D=3D LRU_INACTIVE_FILE));
>> >> =A0 =A0 =A0 =A0list_add(&page->lru, head);
>> >> =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_=
pages(page));
>> >> =A0 =A0 =A0 =A0mem_cgroup_add_lru_list(page, l);
>> >> diff --git a/mm/swap.c b/mm/swap.c
>> >> index a83ec5a..5f7c3c8 100644
>> >> --- a/mm/swap.c
>> >> +++ b/mm/swap.c
>> >> @@ -454,6 +454,8 @@ static void lru_deactivate_fn(struct page *page, =
void *arg)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * The page's writeback ends up during=
 pagevec
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We moves tha page into tail of inac=
tive.
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(PageActive(page) && (
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru =3D=3D LRU_INACTIVE=
_ANON || lru =3D=3D LRU_INACTIVE_FILE));
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move_tail(&page->lru, &zone->lru[=
lru].list);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_rotate_reclaimable_page(pag=
e);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_event(PGROTATED);
>> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >> index b3a569f..3415896 100644
>> >> --- a/mm/vmscan.c
>> >> +++ b/mm/vmscan.c
>> >> @@ -963,7 +963,7 @@ int __isolate_lru_page(struct page *page, int mod=
e, int file)
>> >>
>> >> =A0 =A0 =A0 =A0/* Only take pages on the LRU. */
>> >> =A0 =A0 =A0 =A0if (!PageLRU(page))
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> >>
>> >> =A0 =A0 =A0 =A0/*
>> >> =A0 =A0 =A0 =A0 * When checking the active state, we need to be sure =
we are
>> >> @@ -971,10 +971,10 @@ int __isolate_lru_page(struct page *page, int m=
ode, int file)
>> >> =A0 =A0 =A0 =A0 * of each.
>> >> =A0 =A0 =A0 =A0 */
>> >> =A0 =A0 =A0 =A0if (mode !=3D ISOLATE_BOTH && (!PageActive(page) !=3D =
!mode))
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 2;
>> >>
>> >> =A0 =A0 =A0 =A0if (mode !=3D ISOLATE_BOTH && page_is_file_cache(page)=
 !=3D file)
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 3;
>> >>
>> >> =A0 =A0 =A0 =A0/*
>> >> =A0 =A0 =A0 =A0 * When this function is being called for lumpy reclai=
m, we
>> >> @@ -982,7 +982,7 @@ int __isolate_lru_page(struct page *page, int mod=
e, int file)
>> >> =A0 =A0 =A0 =A0 * unevictable; only give shrink_page_list evictable p=
ages.
>> >> =A0 =A0 =A0 =A0 */
>> >> =A0 =A0 =A0 =A0if (PageUnevictable(page))
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 4;
>> >>
>> >> =A0 =A0 =A0 =A0ret =3D -EBUSY;
>> >>
>> >> @@ -1035,13 +1035,14 @@ static unsigned long isolate_lru_pages(unsign=
ed long nr_to_scan,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long end_pfn;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long page_pfn;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int zone_id;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D lru_to_page(src);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prefetchw_prev_lru_page(page, src, fla=
gs);
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0VM_BUG_ON(!PageLRU(page));
>> >>
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (__isolate_lru_page(page, mode, =
file)) {
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (ret =3D __isolate_lru_page(page=
, mode, file)) {
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 0:
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&page->lru, =
dst);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_del_lru(pag=
e);
>> >> @@ -1055,6 +1056,7 @@ static unsigned long isolate_lru_pages(unsigned=
 long nr_to_scan,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "ret %d=
\n", ret);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> >>
>> >>> Thank you Minchan for the pointer. I reverted the following commit a=
nd I
>> >>> haven't seen the problem with the same operation. I haven't looked d=
eeply
>> >>> on the patch yet, but figured it would be a good idea to post the du=
mp.
>> >>> The dump looks not directly related to this patchset, but ppl can us=
e it to
>> >>> reproduce the problem.
>> >>
>> >> I tested the patch with rsync + fadvise several times
>> >> in my machine(2P, 2G DRAM) but I didn't have ever seen the BUG.
>> >> But I didn't test it in memcg. As I look dump, it seems not related t=
o memcg.
>> >> Anyway, I tried it to reproduce it in my machine.
>> >> Maybe I will start testing after next week. Sorry.
>> >>
>> >> I hope my debugging patch givse some clues.
>> >> Thanks for the reporting, Ying.
>> >
>> > Sure, i will try the patch and post the result.
>>
>> Minchan:
>>
>> Here is the stack trace after applying your patch. We used
>> trace_printk instead since the printk doesn't give me the message. The
>> ret =3D=3D 4 , so looks like we are failing at the check =A0if
>> (PageUnevictable(page))
>>
>> kernel is based on tag: mmotm-2011-04-14-15-08 plus my the two memcg
>> patches in the thread, and also the debugging patch.
>>
>> [ =A0426.696004] kernel BUG at mm/vmscan.c:1061!
>> [ =A0426.696004] invalid opcode: 0000 [#1] SMP=B7
>> [ =A0426.696004] Dumping ftrace buffer:
>> [ =A0426.696004] ---------------------------------
>> [ =A0426.696004] =A0 =A0<...>-546 =A0 =A0 4d... 426442418us : isolate_pa=
ges_global: ret 4
>> [ =A0426.696004] ---------------------------------
>> [ =A0426.696004] RIP: 0010:[<ffffffff810ed1b2>] =A0[<ffffffff810ed1b2>]
>> isolate_pages_global+0x1ba/0x37d
>> [ =A0426.696004] RSP: 0000:ffff88082f8dfb50 =A0EFLAGS: 00010086
>> [ =A0426.696004] RAX: 0000000000000001 RBX: ffff88082f8dfc90 RCX: 000000=
0000000000
>> [ =A0426.696004] RDX: 0000000000000006 RSI: 0000000000000046 RDI: ffff88=
085f805f80
>> [ =A0426.696004] RBP: ffff88082f8dfc20 R08: 0000000000000000 R09: 000000=
0000000007
>> [ =A0426.696004] R10: 0000000000000005 R11: 0000000000000000 R12: ffff88=
085ffb6e00
>> [ =A0426.696004] R13: ffffea001ca66c58 R14: 0000000000000004 R15: ffffea=
001ca66c30
>> [ =A0426.696004] FS: =A00000000000000000(0000) GS:ffff88085fd00000(0000)
>> knlGS:0000000000000000
>> [ =A0426.696004] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [ =A0426.696004] CR2: 00007f0c65c6f320 CR3: 000000082b66f000 CR4: 000000=
00000006e0
>> [ =A0426.696004] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000=
0000000000
>> [ =A0426.696004] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000=
0000000400
>> [ =A0426.696004] Process kswapd0 (pid: 546, threadinfo ffff88082f8de000,
>> task ffff88082f83b8e0)
>> [ =A0426.696004] Stack:
>> [ =A0426.696004] =A0ffff88085ffb6e00 ffffea0000000002 0000000000000020
>> 0000000000000000
>> [ =A0426.696004] =A00000000000000000 ffff88082f8dfcb8 ffffea00158f58d8
>> ffffea00158f5868
>> [ =A0426.696004] =A0ffffea00158f5de0 0000000000000001 ffffffffffffffff
>> 0000000000000020
>> [ =A0426.696004] Call Trace:
>> [ =A0426.696004] =A0[<ffffffff810ee8e7>] shrink_inactive_list+0x185/0x3c=
9
>> [ =A0426.696004] =A0[<ffffffff8107a3fc>] ? lock_timer_base+0x2c/0x52
>> [ =A0426.696004] =A0[<ffffffff810e8b2d>] ? determine_dirtyable_memory+0x=
1a/0x2c
>> [ =A0426.696004] =A0[<ffffffff810ef17c>] shrink_zone+0x380/0x44d
>> [ =A0426.696004] =A0[<ffffffff810e5180>] ? zone_watermark_ok_safe+0xa1/0=
xae
>> [ =A0426.696004] =A0[<ffffffff810efbb9>] kswapd+0x41b/0x76b
>> [ =A0426.696004] =A0[<ffffffff810ef79e>] ? zone_reclaim+0x2fb/0x2fb
>> [ =A0426.696004] =A0[<ffffffff81088561>] kthread+0x82/0x8a
>> [ =A0426.696004] =A0[<ffffffff8141af54>] kernel_thread_helper+0x4/0x10
>> [ =A0426.696004] =A0[<ffffffff810884df>] ? kthread_worker_fn+0x112/0x112
>> [ =A0426.696004] =A0[<ffffffff8141af50>] ? gs_change+0xb/0xb
>> [ =A0426.696004] Code: 01 00 00 89 c6 48 c7 c7 69 52 70 81 31 c0 e8 c1
>> 46 32 00 48 8b 35 37 2b 79 00 44 89 f2 48 c7 c7 8a d1 0e 81 31 c0 e8
>> 09 e2 fd ff <0f> 0b eb fe 49 8b 45 d8 48 b9 00 00 00 00 00 16 00 00 4c
>> 8b 75=B7
>> [ =A0426.696004] RIP =A0[<ffffffff810ed1b2>] isolate_pages_global+0x1ba/=
0x37d
>> [ =A0426.696004] =A0RSP <ffff88082f8dfb50>
>> [ =A0426.696004] ---[ end trace fbb25b41a0373361 ]---
>> [ =A0426.696004] Kernel panic - not syncing: Fatal exception
>> [ =A0426.696004] Pid: 546, comm: kswapd0 Tainted: G =A0 =A0 =A0D W
>> 2.6.39-smp-Minchan #28
>> [ =A0426.696004] Call Trace:
>> [ =A0426.696004] =A0[<ffffffff81411758>] panic+0x91/0x194
>> [ =A0426.696004] =A0[<ffffffff81414708>] oops_end+0xae/0xbe
>> [ =A0426.696004] =A0[<ffffffff81039906>] die+0x5a/0x63
>> [ =A0426.696004] =A0[<ffffffff814141a1>] do_trap+0x121/0x130
>> [ =A0426.696004] =A0[<ffffffff81037e85>] do_invalid_op+0x96/0x9f
>> [ =A0426.696004] =A0[<ffffffff810ed1b2>] ? isolate_pages_global+0x1ba/0x=
37d
>> [ =A0426.696004] =A0[<ffffffff810c414a>] ? ring_buffer_lock_reserve+0x6a=
/0x78
>> [ =A0426.696004] =A0[<ffffffff810c2e3e>] ? rb_commit+0x76/0x78
>> [ =A0426.696004] =A0[<ffffffff810c2eab>] ? ring_buffer_unlock_commit+0x2=
1/0x25
>> [ =A0426.696004] =A0[<ffffffff8141add5>] invalid_op+0x15/0x20
>> [ =A0426.696004] =A0[<ffffffff810ed1b2>] ? isolate_pages_global+0x1ba/0x=
37d
>> [ =A0426.696004] =A0[<ffffffff810ee8e7>] shrink_inactive_list+0x185/0x3c=
9
>> [ =A0426.696004] =A0[<ffffffff8107a3fc>] ? lock_timer_base+0x2c/0x52
>> [ =A0426.696004] =A0[<ffffffff810e8b2d>] ? determine_dirtyable_memory+0x=
1a/0x2c
>> [ =A0426.696004] =A0[<ffffffff810ef17c>] shrink_zone+0x380/0x44d
>> [ =A0426.696004] =A0[<ffffffff810e5180>] ? zone_watermark_ok_safe+0xa1/0=
xae
>> [ =A0426.696004] =A0[<ffffffff810efbb9>] kswapd+0x41b/0x76b
>> [ =A0426.696004] =A0[<ffffffff810ef79e>] ? zone_reclaim+0x2fb/0x2fb
>> [ =A0426.696004] =A0[<ffffffff81088561>] kthread+0x82/0x8a
>> [ =A0426.696004] =A0[<ffffffff8141af54>] kernel_thread_helper+0x4/0x10
>> [ =A0426.696004] =A0[<ffffffff810884df>] ? kthread_worker_fn+0x112/0x112
>> [ =A0426.696004] =A0[<ffffffff8141af50>] ? gs_change+0xb/0xb
>>
>> --Ying
>
> Thanks for the testing.
> I missed mprotect case in your scenario.
> Yes. I didn't test it at that time. :(
> So, it wasn't related to your patch and memcg.
> The mprotect makes many unevictable page and it seems my deactive_page co=
uld move
> it into inactive list. Totally, it's my fault.
> Could you test below patch?
>
> From b852da870d3b8bcfed567a8dd224a60b7552abc4 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Sat, 30 Apr 2011 08:04:18 +0900
> Subject: [PATCH] Check PageUnevictable in lru_deactivate_fn
>
> The lru_deactivate_fn should not move page which in on unevictable lru
> into inactive list. Otherwise, we can meet BUG when we use isolate_lru_pa=
ges
> as __isolate_lru_page could return -EINVAL.
> It's really BUG.
>
> Reported-by: Ying Han <yinghan@google.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
> =A0mm/swap.c | =A0 =A03 +++
> =A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index a83ec5a..298f372 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -426,6 +426,9 @@ static void lru_deactivate_fn(struct page *page, void=
 *arg)
> =A0 =A0 =A0 =A0bool active;
> =A0 =A0 =A0 =A0struct zone *zone =3D page_zone(page);
>
> + =A0 =A0 =A0 if (PageUnevictable(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> =A0 =A0 =A0 =A0if (!PageLRU(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;

I tested the patch with the same workload, and the BUG doesn't happen
when it normally triggers quickly. So I believe the patch fixes the
problem. Please go ahead post the patch and I will give tested by.

Thanks

--Ying

> --
> 1.7.1
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
