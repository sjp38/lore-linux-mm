Message-ID: <3E317E6A.7020507@cyberone.com.au>
Date: Sat, 25 Jan 2003 04:56:58 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.59-mm5 got stuck during boot
References: <20030123195044.47c51d39.akpm@digeo.com> <3E3146BC.4D0A1A64@aitel.hist.no> <200301241244.05268.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:

>On January 24, 2003 08:59 am, Helge Hafting wrote:
>
>>Andrew Morton wrote:
>>
>>>.  -mm5 has the first cut of Nick Piggin's anticipatory I/O scheduler.
>>>
>>Interesting, but it didn't boot completely.
>>It came all the way to mount root from /dev/md0  (dirty raid1)
>>freed 316k of kernel memory, and then nothing happened.
>>numloc and capslock worked, and so did sysrq.
>>It was as if the kernel "forgot" to run init.
>>Nothing happened, but it wasn't hanging either.
>>
>>sysrq "show pc" told me something about default idle.
>>I noticed that the root raid-1 came up dirty. (2.5.X
>>seems unable to shut down a raid-1 device "clean" if
>>it  happens to be the root fs.  So there's _always_
>>a bootup resync that starts as soon as the raid
>>is autodetected. (Before mounting root)
>>
>>
>>This is a UP P4, preempt, no module support,
>>compiled with gcc 2.95.4 from debian.
>>
>>Stock 2.5.59 works, the only config change is to enable
>>that new CONFIG_HANGCHECK_TIMER.
>>
>
>Same story here - almost.  No raid, using debian and the same
>compiler along with multiple disks and fs(es).
>
>Following are the messages and a sysrq+T:
>
>Hope this helps,
>
Yes thanks for the nice report.

>
>                         free                        sibling
>  task             PC    stack   pid father child younger older
>init          D 00000086 12112     1      0     2               (NOTLB)
>Call Trace:
> [<c0113f5a>] io_schedule+0xe/0x18
> [<c0127654>] __lock_page+0x90/0xac
> [<c0114694>] autoremove_wake_function+0x0/0x38
> [<c0114694>] autoremove_wake_function+0x0/0x38
> [<c01284cb>] filemap_nopage+0x16b/0x2ac
> [<c01322d4>] do_no_page+0x78/0x2b4
> [<c013257d>e] handle_mm_fau+0x6d/0x10c
> [<c0111cb7>] do_page_fault+0x137/0x414
> [<c0111b80>] do_page_fault+0x0/0x414
> [<c013e9aa>] __fput+0xe6/0x108
> [<c0133f01>] unmap_vma+0x69/0x70
> [<c0133f1c>] unmap_vma_list+0x14/0x20
> [<c013423b>] do_munmap+0x127/0x134
> [<c013428c>] sys_munmap+0x44/0x60
> [<c0108cbd>] error_code+0x2d/0x40
>
Processes get sleep waiting for a page and never wake up.
It doesn't seem to be an anticipatory scheduling problem but
if you have time, try changing drivers/block/deadline-iosched.c

static int antic_expire = HZ / 25;
to
static int antic_expire = 0;

And see if you can reproduce.

Nick




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
