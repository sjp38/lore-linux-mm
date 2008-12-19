Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7C1506B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 02:43:17 -0500 (EST)
Message-ID: <494B50C9.7080308@cn.fujitsu.com>
Date: Fri, 19 Dec 2008 15:44:09 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
References: <491DAF8E.4080506@quantum.com>	<200811191526.00036.nickpiggin@yahoo.com.au>	<20081119165819.GE19209@random.random>	<20081218152952.GW24856@random.random> <20081219161911.dcf15331.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081219161911.dcf15331.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: multipart/mixed;
 boundary="------------080300060107050009010600"
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, FNST-Wang Chen <wangchen@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080300060107050009010600
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

KAMEZAWA Hiroyuki wrote:
> On Thu, 18 Dec 2008 16:29:52 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
>> On Wed, Nov 19, 2008 at 05:58:19PM +0100, Andrea Arcangeli wrote:
>>> On Wed, Nov 19, 2008 at 03:25:59PM +1100, Nick Piggin wrote:
>>>> The solution either involves synchronising forks and get_user_pages,
>>>> or probably better, to do copy on fork rather than COW in the case
>>>> that we detect a page is subject to get_user_pages. The trick is in
>>>> the details :)
> 
>> From: Andrea Arcangeli <aarcange@redhat.com>
>> Subject: fork-o_direct-race
>>
>> Think a thread writing constantly to the last 512bytes of a page, while another
>> thread read and writes to/from the first 512bytes of the page. We can lose
>> O_DIRECT reads, the very moment we mark any pte wrprotected because a third
>> unrelated thread forks off a child.
>>
>> This fixes it by never wprotecting anon ptes if there can be any direct I/O in
>> flight to the page, and by instantiating a readonly pte and triggering a COW in
>> the child. The only trouble here are O_DIRECT reads (writes to memory, read
>> from disk). Checking the page_count under the PT lock guarantees no
>> get_user_pages could be running under us because if somebody wants to write to
>> the page, it has to break any cow first and that requires taking the PT lock in
>> follow_page before increasing the page count.
>>
>> The COW triggered inside fork will run while the parent pte is read-write, this
>> is not usual but that's ok as it's only a page copy and it doesn't modify the
>> page contents.
>>
>> In the long term there should be a smp_wmb() in between page_cache_get and
>> SetPageSwapCache in __add_to_swap_cache and a smp_rmb in between the
>> PageSwapCache and the page_count() to remove the trylock op.
>>
>> Fixed version of original patch from Nick Piggin.
>>
>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Confirmed this fixes the problem.
> 

We tested with RHEL 5.2 + patch on i386 using the test program provided by
Tim LaBerge, though the program can pass but sometimes hanged. strace log is
attached, and we'll test it again with LOCKDEP enabled to see if we can get
some other information.

BTW, the patch works fine on IA64.

> Hmm, but, fork() gets slower. 

--------------080300060107050009010600
Content-Type: text/x-log;
 name="strace.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="strace.log"

xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5193
futex(0xb6a18bd8, FUTEX_WAIT, 5192, NULL) = 0
futex(0xb7419bd8, FUTEX_WAIT, 5193, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5191, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5200
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5201
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5202
futex(0xb7419bd8, FUTEX_WAIT, 5201, NULL) = 0
futex(0xb6a18bd8, FUTEX_WAIT, 5202, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5200, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5207
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5208
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5209
futex(0xb6a18bd8, FUTEX_WAIT, 5208, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5207, NULL) = -1 EAGAIN (Resource temporarily unavailable)
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5221
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5222
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5223
futex(0xb7419bd8, FUTEX_WAIT, 5222, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5221, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5228
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5229
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5230
futex(0xb6a18bd8, FUTEX_WAIT, 5229, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5228, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5234
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5235
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5236
futex(0xb7419bd8, FUTEX_WAIT, 5235, NULL) = 0
futex(0xb6a18bd8, FUTEX_WAIT, 5236, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5234, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5241
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5242
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5243
futex(0xb6a18bd8, FUTEX_WAIT, 5242, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5241, NULL) = 0
close(3)                                = 0
close(4)                                = 0
open("test_0060.tmp", O_RDONLY|O_DIRECT) = 3
open("test_0060.tmp", O_RDONLY|O_DIRECT) = 4
write(1, "Reading file 60.\n", 17Reading file 60.
)      = 17
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5248
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5249
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5250
futex(0xb7419bd8, FUTEX_WAIT, 5249, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5248, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5257
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5258
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5259
futex(0xb6a18bd8, FUTEX_WAIT, 5258, NULL) = 0
futex(0xb7419bd8, FUTEX_WAIT, 5259, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5257, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5266
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5267
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5268
futex(0xb7419bd8, FUTEX_WAIT, 5267, NULL) = 0
futex(0xb6a18bd8, FUTEX_WAIT, 5268, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5266, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5279
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5280
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5281
futex(0xb6a18bd8, FUTEX_WAIT, 5280, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5279, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5288
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5289
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5290
futex(0xb7419bd8, FUTEX_WAIT, 5289, NULL) = 0
futex(0xb6a18bd8, FUTEX_WAIT, 5290, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5288, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5297
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5298
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5299
futex(0xb6a18bd8, FUTEX_WAIT, 5298, NULL) = 0
futex(0xb7419bd8, FUTEX_WAIT, 5299, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5297, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5306
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5307
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5308
futex(0xb7419bd8, FUTEX_WAIT, 5307, NULL) = 0
futex(0xb6a18bd8, FUTEX_WAIT, 5308, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5306, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5313
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5314
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5315
futex(0xb6a18bd8, FUTEX_WAIT, 5314, NULL) = 0
futex(0xb7419bd8, FUTEX_WAIT, 5315, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5313, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5320
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5321
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5322
futex(0xb7419bd8, FUTEX_WAIT, 5321, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5320, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5328
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5329
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5331
futex(0xb6a18bd8, FUTEX_WAIT, 5329, NULL) = -1 EAGAIN (Resource temporarily unavailable)
futex(0xb7419bd8, FUTEX_WAIT, 5331, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5328, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5337
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5338
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5339
futex(0xb7419bd8, FUTEX_WAIT, 5338, NULL) = 0
futex(0xb6a18bd8, FUTEX_WAIT, 5339, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5337, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5356
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5357
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5358
futex(0xb6a18bd8, FUTEX_WAIT, 5357, NULL) = 0
futex(0xb7419bd8, FUTEX_WAIT, 5358, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5356, NULL) = 0
close(3)                                = 0
close(4)                                = 0
open("test_0061.tmp", O_RDONLY|O_DIRECT) = 3
open("test_0061.tmp", O_RDONLY|O_DIRECT) = 4
write(1, "Reading file 61.\n", 17Reading file 61.
)      = 17
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5366
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5367
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5369
futex(0xb7419bd8, FUTEX_WAIT, 5367, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5366, NULL) = 0
clone(child_stack=0xb7e1a4b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7e1abd8, {entry_number:6, base_addr:0xb7e1ab90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7e1abd8) = 5372
clone(child_stack=0xb6a184b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb6a18bd8, {entry_number:6, base_addr:0xb6a18b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6a18bd8) = 5373
clone(child_stack=0xb74194b4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb7419bd8, {entry_number:6, base_addr:0xb7419b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb7419bd8) = 5375
futex(0xb6a18bd8, FUTEX_WAIT, 5373, NULL) = 0
futex(0xb7419bd8, FUTEX_WAIT, 5375, NULL) = 0
futex(0xb7e1abd8, FUTEX_WAIT, 5372, NULL


--------------080300060107050009010600--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
