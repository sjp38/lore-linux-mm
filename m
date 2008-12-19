Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0A94E6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 03:45:07 -0500 (EST)
Message-ID: <494B5F3B.806@cn.fujitsu.com>
Date: Fri, 19 Dec 2008 16:45:47 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
References: <491DAF8E.4080506@quantum.com>	<200811191526.00036.nickpiggin@yahoo.com.au>	<20081119165819.GE19209@random.random>	<20081218152952.GW24856@random.random> <20081219161911.dcf15331.kamezawa.hiroyu@jp.fujitsu.com> <494B50C9.7080308@cn.fujitsu.com>
In-Reply-To: <494B50C9.7080308@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, FNST-Wang Chen <wangchen@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> KAMEZAWA Hiroyuki wrote:
>> On Thu, 18 Dec 2008 16:29:52 +0100
>> Andrea Arcangeli <aarcange@redhat.com> wrote:
>>
>>> On Wed, Nov 19, 2008 at 05:58:19PM +0100, Andrea Arcangeli wrote:
>>>> On Wed, Nov 19, 2008 at 03:25:59PM +1100, Nick Piggin wrote:
>>>>> The solution either involves synchronising forks and get_user_pages,
>>>>> or probably better, to do copy on fork rather than COW in the case
>>>>> that we detect a page is subject to get_user_pages. The trick is in
>>>>> the details :)
>>> From: Andrea Arcangeli <aarcange@redhat.com>
>>> Subject: fork-o_direct-race
>>>
>>> Think a thread writing constantly to the last 512bytes of a page, while another
>>> thread read and writes to/from the first 512bytes of the page. We can lose
>>> O_DIRECT reads, the very moment we mark any pte wrprotected because a third
>>> unrelated thread forks off a child.
>>>
>>> This fixes it by never wprotecting anon ptes if there can be any direct I/O in
>>> flight to the page, and by instantiating a readonly pte and triggering a COW in
>>> the child. The only trouble here are O_DIRECT reads (writes to memory, read
>>> from disk). Checking the page_count under the PT lock guarantees no
>>> get_user_pages could be running under us because if somebody wants to write to
>>> the page, it has to break any cow first and that requires taking the PT lock in
>>> follow_page before increasing the page count.
>>>
>>> The COW triggered inside fork will run while the parent pte is read-write, this
>>> is not usual but that's ok as it's only a page copy and it doesn't modify the
>>> page contents.
>>>
>>> In the long term there should be a smp_wmb() in between page_cache_get and
>>> SetPageSwapCache in __add_to_swap_cache and a smp_rmb in between the
>>> PageSwapCache and the page_count() to remove the trylock op.
>>>
>>> Fixed version of original patch from Nick Piggin.
>>>
>>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>> Confirmed this fixes the problem.
>>
> 
> We tested with RHEL 5.2 + patch on i386 using the test program provided by
> Tim LaBerge, though the program can pass but sometimes hanged. strace log is
> attached, and we'll test it again with LOCKDEP enabled to see if we can get
> some other information.
> 

# ./dma_thread -a 512

Using 2 workers.

Using alignment 512.

Read buffer: 0xb7e4e000.

Reading file 1.

Reading file 2.

...

Reading file 26.

Reading file 27.


(hang here, Ctrl+C can break the process)


And we modified the program to use 'dma_thread -a 512 -w 1', we can still see
hung in a very low frequency.

==============

Here is a snapshop of call trace:

dma_thread    S 00000035  2872 20296   8797         23256       (NOTLB)
       f7018e78 00000046 1f593e7d 00000035 f7018e84 00000002 00000000 00000006 
       f4c35530 f71ac030 1f5a03da 00000035 0000c55d 00000001 f4c3563c c1a80044 
       f7018f04 f7018f1c b7e4cbd8 00000046 00000000 00000002 00000001 7fffffff 
Call Trace:
 [<c061bd10>] schedule_timeout+0x13/0x8c
 [<c043c435>] do_futex+0x1e2/0xb38
 [<c061d316>] _spin_unlock+0x14/0x1c
 [<c0465938>] do_wp_page+0x3fb/0x405
 [<c0466da0>] __handle_mm_fault+0x858/0x8b8
 [<c041e5f3>] default_wake_function+0x0/0xc
 [<c044e32b>] audit_syscall_entry+0x14b/0x17d
 [<c043ce9c>] sys_futex+0x111/0x127
 [<c0408076>] do_syscall_trace+0xab/0xb1
 [<c0404f53>] syscall_call+0x7/0xb
 =======================
dma_thread    S 00000035  3304 23256   8797 23258         20296 (NOTLB)
       f4e24f50 00000046 1ec0e26d 00000035 c073ea10 416db065 00000046 00000003 
       f70ac030 c1b7eab0 1ec7d7c9 00000035 0006f55c 00000001 f70ac13c c1a80044 
       00005ada f4cc0030 00000000 00000246 ffffffff 00000000 00000000 f53acab0 
Call Trace:
 [<c0426b84>] do_wait+0x8b5/0x9a3
 [<c044e32b>] audit_syscall_entry+0x14b/0x17d
 [<c041e5f3>] default_wake_function+0x0/0xc
 [<c0426c99>] sys_wait4+0x27/0x2a
 [<c0426caf>] sys_waitpid+0x13/0x17
 [<c0404f53>] syscall_call+0x7/0xb
 =======================
dma_thread    R running  3412 23258  23256                     (NOTLB)
...
...
Showing all locks held in the system:
4 locks held by kseriod/82:
 #0:  (serio_mutex){--..}, at: [<c059c7f6>] serio_thread+0x13/0x28d
 #1:  (&serio->drv_mutex){--..}, at: [<c059be7e>] serio_connect_driver+0x16/0x2c
 #2:  (psmouse_mutex){--..}, at: [<c05a41ce>] psmouse_connect+0x18/0x211
 #3:  (&ps2_mutex_key){--..}, at: [<c059e4bd>] ps2_command+0x80/0x2dc

=============================================

> BTW, the patch works fine on IA64.
> 
>> Hmm, but, fork() gets slower. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
