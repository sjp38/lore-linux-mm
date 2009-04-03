Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9886B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:34:31 -0400 (EDT)
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id n33LYwCk029028
	for <linux-mm@kvack.org>; Fri, 3 Apr 2009 22:34:59 +0100
Received: from wf-out-1314.google.com (wfg23.prod.google.com [10.142.7.23])
	by zps19.corp.google.com with ESMTP id n33LYvLf017651
	for <linux-mm@kvack.org>; Fri, 3 Apr 2009 14:34:57 -0700
Received: by wf-out-1314.google.com with SMTP id 23so1270604wfg.2
        for <linux-mm@kvack.org>; Fri, 03 Apr 2009 14:34:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090403094110.GB18569@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
	 <200904022224.31060.nickpiggin@yahoo.com.au>
	 <20090402113400.GC3010@duck.suse.cz>
	 <200904030251.22197.nickpiggin@yahoo.com.au>
	 <604427e00904021044n73302f4uc39ca09fe96caf57@mail.gmail.com>
	 <604427e00904021552m7ef58163n5392bbe54d902c21@mail.gmail.com>
	 <20090402233908.GA22206@duck.suse.cz>
	 <604427e00904021829j6a9aba65gafcc67df9c842a86@mail.gmail.com>
	 <20090403094110.GB18569@duck.suse.cz>
Date: Fri, 3 Apr 2009 14:34:56 -0700
Message-ID: <604427e00904031434m38433cddu578fefa98d11a14f@mail.gmail.com>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 3, 2009 at 2:41 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 02-04-09 18:29:21, Ying Han wrote:
>> On Thu, Apr 2, 2009 at 4:39 PM, Jan Kara <jack@suse.cz> wrote:
>> > On Thu 02-04-09 15:52:19, Ying Han wrote:
>> >> On Thu, Apr 2, 2009 at 10:44 AM, Ying Han <yinghan@google.com> wrote:
>> >> > On Thu, Apr 2, 2009 at 8:51 AM, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>> >> >> On Thursday 02 April 2009 22:34:01 Jan Kara wrote:
>> >> >>> On Thu 02-04-09 22:24:29, Nick Piggin wrote:
>> >> >>> > On Thursday 02 April 2009 09:36:13 Ying Han wrote:
>> >> >>> > > Hi Jan:
>> >> >>> > >     I feel that the problem you saw is kind of differnt than mine. As
>> >> >>> > > you mentioned that you saw the PageError() message, which i don't see
>> >> >>> > > it on my system. I tried you patch(based on 2.6.21) on my system and
>> >> >>> > > it runs ok for 2 days, Still, since i don't see the same error message
>> >> >>> > > as you saw, i am not convineced this is the root cause at least for
>> >> >>> > > our problem. I am still looking into it.
>> >> >>> > >     So, are you seeing the PageError() every time the problem happened?
>> >> >>> >
>> >> >>> > So I asked if you could test with my workaround of taking truncate_mutex
>> >> >>> > at the start of ext2_get_blocks, and report back. I never heard of any
>> >> >>> > response after that.
>> >> >>> >
>> >> >>> > To reiterate: I was able to reproduce a problem with ext2 (I was testing
>> >> >>> > on brd to get IO rates high enough to reproduce it quite frequently).
>> >> >>> > I think I narrowed the problem down to block allocation or inode block
>> >> >>> > tree corruption because I was unable to reproduce it with that hack in
>> >> >>> > place.
>> >> >>>   Nick, what load did you use for reproduction? I'll try to reproduce it
>> >> >>> here so that I can debug ext2...
>> >> >>
>> >> >> OK, I set up the filesystem like this:
>> >> >>
>> >> >> modprobe rd rd_size=$[3*1024*1024]   #almost fill memory so we reclaim buffers
>> >> >> dd if=/dev/zero of=/dev/ram0 bs=4k   #prefill brd so we don't get alloc deadlock
>> >> >> mkfs.ext2 -b1024 /dev/ram0           #1K buffers
>> >> >>
>> >> >> Test is basically unmodified except I use 64MB files, and start 8 of them
>> >> >> at once to (8 core system, so improve chances of hitting the bug). Although I
>> >> >> do see it with only 1 running it takes longer to trigger.
>> >> >>
>> >> >> I also run a loop doing 'sync ; echo 3 > /proc/sys/vm/drop_caches' but I don't
>> >> >> know if that really helps speed up reproducing it. It is quite random to hit,
>> >> >> but I was able to hit it IIRC in under a minute with that setup.
>> >> >>
>> >> >
>> >> > Here is how i reproduce it:
>> >> > Filesystem is ext2 with blocksize 4096
>> >> > Fill up the ram with 95% anon memory and mlockall ( put enough memory
>> >> > pressure which will trigger page reclaim and background writeout)
>> >> > Run one thread of the test program
>> >> >
>> >> > and i will see "bad pages" within few minutes.
>> >>
>> >> And here is the "top" and stdout while it is getting "bad pages"
>> >> top
>> >>
>> >>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>> >>  3487 root      20   0 52616  50m  284 R   95  0.3   3:58.85 usemem
>> >>  3810 root      20   0  129m  99m  99m D   41  0.6   0:01.87 ftruncate_mmap
>> >>   261 root      15  -5     0    0    0 D    4  0.0   0:31.08 kswapd0
>> >>   262 root      15  -5     0    0    0 D    3  0.0   0:10.26 kswapd1
>> >>
>> >> stdout:
>> >>
>> >> while true; do
>> >>     ./ftruncate_mmap;
>> >> done
>> >> Running 852 bad page
>> >> Running 315 bad page
>> >> Running 999 bad page
>> >> Running 482 bad page
>> >> Running 24 bad page
>> >  Thanks, for the help. I've debugged the problem to a bug in
>> > ext2_get_block(). I've already sent out a patch which should fix the issue
>> > (at least it fixes the problem for me).
>> >  The fix is also attached if you want to try it.
>>
>> hmm, now i do see that get_block() returns ENOSPC by printk the err.
>> So did you applied the patch which redirty_page_for_writepage as well
>> as this one together?
>  No, my patch contained only a fix in ext2_get_block(). When you see
> ENOSPC, that's a completely separate issue. You may apply that patch but
> with ext2 it would be enough to make the file fit the ram disk. I.e. first
> try with dd how big file fits there and then run your tester with at most
> as big file so that you don't hit ENOSPC...
>
>> I will start the test with kernel applied both patches and leave it for running.
>  OK.

I applied the patch(based on 2.6.26) in the attachment and the test
itself runs fine so far without reporting "bad pages", however, i
seems get deadlock in the varlog, here is the message and i turned on
lockdep.

kernel: 1 lock held by kswapd1/264:
kernel: #0:  (&ei->truncate_mutex){--..}, at: [<ffffffff8031d529>]
ext2_get_block+0x109/0x960
kernel: INFO: task ftruncate_mmap:2950 blocked for more than 120 seconds.
kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
kernel: ftruncate_mma D ffff81047e733a80     0  2950   2858
kernel: ffff8101798516f8 0000000000000092 0000000000000000 0000000000000046
kernel: ffff81047e0a1260 ffff81047f070000 ffff81047e0a15c0 0000000100130c66
kernel: 00000000ffffffff ffffffff8025740d 0000000000000000 0000000000000000
kernel: Call Trace:
kernel: [<ffffffff8025740d>] mark_held_locks+0x3d/0x80
kernel: [<ffffffff804d78bd>] mutex_lock_nested+0x14d/0x280
kernel: [<ffffffff804d7855>] mutex_lock_nested+0xe5/0x280
kernel: [<ffffffff8031d529>] ext2_get_block+0x109/0x960
kernel: [<ffffffff802ca2e3>] create_empty_buffers+0x43/0xb0
kernel: [<ffffffff802ca2e3>] create_empty_buffers+0x43/0xb0
kernel: [<ffffffff802ca217>] alloc_page_buffers+0x97/0x120
kernel: [<ffffffff802cbfb6>] __block_write_full_page+0x206/0x320
kernel: [<ffffffff802cbe70>] __block_write_full_page+0xc0/0x320
kernel: [<ffffffff8031d420>] ext2_get_block+0x0/0x960
kernel: [<ffffffff8027c74e>] shrink_page_list+0x4fe/0x650
kernel: [<ffffffff80257ee8>] __lock_acquire+0x3b8/0x1080
kernel: [<ffffffff8027be18>] isolate_lru_pages+0x88/0x230
kernel: [<ffffffff8027c9ea>] shrink_inactive_list+0x14a/0x3f0
kernel: [<ffffffff8027cd43>] shrink_zone+0xb3/0x130
kernel: [<ffffffff80249e90>] autoremove_wake_function+0x0/0x30
kernel: [<ffffffff8027d1a8>] try_to_free_pages+0x268/0x3e0
kernel: [<ffffffff8027bfc0>] isolate_pages_global+0x0/0x40
kernel: [<ffffffff802774f7>] __alloc_pages_internal+0x1d7/0x4a0
kernel: [<ffffffff80279b94>] __do_page_cache_readahead+0x124/0x270
kernel: [<ffffffff8027314f>] filemap_fault+0x18f/0x400
kernel: [<ffffffff80280925>] __do_fault+0x65/0x450
kernel: [<ffffffff80257ee8>] __lock_acquire+0x3b8/0x1080
kernel: [<ffffffff803475dd>] __down_read_trylock+0x1d/0x60
kernel: [<ffffffff8028389a>] handle_mm_fault+0x18a/0x7a0
kernel: [<ffffffff804dba1c>] do_page_fault+0x29c/0x930
kernel: [<ffffffff804d8b46>] trace_hardirqs_on_thunk+0x35/0x3a
kernel: [<ffffffff804d94dd>] error_exit+0x0/0xa9
kernel:
kernel: 2 locks held by ftruncate_mmap/2950:
kernel: #0:  (&mm->mmap_sem){----}, at: [<ffffffff804db9af>]
do_page_fault+0x22f/0x930
kernel: #1:  (&ei->truncate_mutex){--..}, at: [<ffffffff8031d529>]
ext2_get_block+0x109/0x960

--Ying

>
>                                                                                Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
