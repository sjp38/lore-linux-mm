Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 175226B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 05:00:31 -0400 (EDT)
Message-ID: <02c101cacbf8$d21d1650$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <03ca01cacb92$195adf50$0400a8c0@dcccs><2375c9f91003242029p1efbbea1v8e313e460b118f14@mail.gmail.com> <20100325153110.6be9a3df.kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Somebody take a look please! (some kind of kernel bug?)
Date: Thu, 25 Mar 2010 09:54:38 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="UTF-8";
	reply-type=original
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


----- Original Message ----- 
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
To: "AmA(C)rico Wang" <xiyou.wangcong@gmail.com>
Cc: "Janos Haar" <janos.haar@netcenter.hu>; <linux-kernel@vger.kernel.org>; 
<linux-mm@kvack.org>
Sent: Thursday, March 25, 2010 7:31 AM
Subject: Re: Somebody take a look please! (some kind of kernel bug?)


> On Thu, 25 Mar 2010 11:29:25 +0800
> AmA(C)rico Wang <xiyou.wangcong@gmail.com> wrote:
>
>> (Cc'ing linux-mm)
>>
> Hmm..here is summary of corruption (from log), but no idea.
>
> ==
> process's address pte       pnf->pte->page
>
> 00000037b4008000   2bf1e025 -> PG_reserved
> 00000037b400a000 d900000000 -> bad swap
> 00000037b400c000   2bfe8025 -> PG_reserved
> 00000037b400d000  12bfe9025 -> belongs to some other files' page cache
> 00000037b400e000 ff00000000 -> bad swap
> 00000037b400f000 5400000000 -> bad swap
> ...
> 00000037b4019000 ff00000000 -> bad swap
> ==
> All ptes are on the same pmd 1535b5067.
> .
> I doubt some kind of buffer overflow bug overwrites page table...
> Because ptes for adddress of 00000037b4008000...00000037b400f000 are on 
> head of

This is only one bit, right? :-)

> a page (used for pmd), some data on page [0x1535b4000..0x1535b5000) caused 
> buffer
> overflow and broke page table in [0x1535b5000...0x1535b6000)
>
> Is this bug found from 2.6.28.10 ?

No, the bug, what i have sent was from 2.6.32.10. (you can check it from the 
messages file in the link)
The story begins about marc 9-10 but unfortunately the system not all the 
time was able to write down the messages file.
(At Mar 13 11:20:09 i have triggered the sysreq's process and memory 
information, you can see it in the link below.)
We have more crashes with the 2.6.28.10 in the next some day and the server 
is removed for testing (7 days hole in the log), but looks stable

Here is more serious crashes from the 2.6.28.10:

http://download.netcenter.hu/bughunt/20100324/marc11-14

For me looks like all memory, swap and xfs related.
I have tested/repaired all the filesystems offline, corrected the errors 
wich was left by the previous crashes, than disabled the swap, but nothing 
helps. :(

Finally in marc 21, i have replaced the kernel to the 32.10, and the crashes 
looks gone but only for 4 days. (you can see the first dump in my first 
mail)

Thanks for all the help,

Janos Haar


>
> If I investigate this issue, I'll check the owner of page 0x1535b4000 by
> crash dump.
>
> Thanks,
> -Kame
>
>
>
>> 2010/3/25 Janos Haar <janos.haar@netcenter.hu>:
>> > Dear developers,
>> >
>> > This is one of my productive servers, wich suddenly starts to freeze 
>> > (crash)
>> > some weeks before.
>> > I have done all what i can, (i think) please somebody give to me some
>> > suggestion:
>> >
>> > Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd 
>> > pte:2bf1e025
>> > pmd:1535b5067
>> > Mar 24 19:22:28 alfa kernel: page:ffffea0000f1b250 
>> > flags:4000000000000404
>> > count:1 mapcount:-1 mapping:(null) index:0
>> > Mar 24 19:22:28 alfa kernel: addr:00000037b4008000 vm_flags:08000875
>> > anon_vma:(null) mapping:ffff88022b5d25a8 index:8
>> > Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: 
>> > filemap_fault+0x0/0x34d
>> > Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
>> > xfs_file_mmap+0x0/0x33
>> > Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Not tainted 
>> > 2.6.32.10 #2
>> > Mar 24 19:22:28 alfa kernel: Call Trace:
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c2ea3>] 
>> > print_bad_pte+0x210/0x229
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c3c98>] 
>> > unmap_vmas+0x44b/0x787
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c81d5>] exit_mmap+0xb0/0x133
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81041f83>] mmput+0x48/0xb9
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810463b0>] exit_mm+0x105/0x110
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81371287>] ?
>> > tty_audit_exit+0x28/0x85
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810477a0>] do_exit+0x1e9/0x6d2
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81053c37>] ?
>> > __dequeue_signal+0xf1/0x127
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81047d00>] 
>> > do_group_exit+0x77/0xa1
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810560f7>]
>> > get_signal_to_deliver+0x32c/0x37f
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8100a484>]
>> > do_notify_resume+0x90/0x740
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8102724b>] ?
>> > __bad_area_nosemaphore+0x178/0x1a2
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810272b9>] ? 
>> > __bad_area+0x44/0x4d
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8100bba2>] 
>> > retint_signal+0x46/0x84
>> > Mar 24 19:22:28 alfa kernel: Disabling lock debugging due to kernel 
>> > taint
>> > Mar 24 19:22:28 alfa kernel: swap_free: Bad swap file entry 6c800000
>> > Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd
>> > pte:d900000000 pmd:1535b5067
>> > Mar 24 19:22:28 alfa kernel: addr:00000037b400a000 vm_flags:08000875
>> > anon_vma:(null) mapping:ffff88022b5d25a8 index:a
>> > Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: 
>> > filemap_fault+0x0/0x34d
>> > Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
>> > xfs_file_mmap+0x0/0x33
>> > Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Tainted: G B
>> > 2.6.32.10 #2
>> > Mar 24 19:22:28 alfa kernel: Call Trace:
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81044551>] ? add_taint+0x32/0x3e
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c2ea3>] 
>> > print_bad_pte+0x210/0x229
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c3d47>] 
>> > unmap_vmas+0x4fa/0x787
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c81d5>] exit_mmap+0xb0/0x133
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81041f83>] mmput+0x48/0xb9
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810463b0>] exit_mm+0x105/0x110
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81371287>] ?
>> > tty_audit_exit+0x28/0x85
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810477a0>] do_exit+0x1e9/0x6d2
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81053c37>] ?
>> > __dequeue_signal+0xf1/0x127
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81047d00>] 
>> > do_group_exit+0x77/0xa1
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810560f7>]
>> > get_signal_to_deliver+0x32c/0x37f
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8100a484>]
>> > do_notify_resume+0x90/0x740
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8102724b>] ?
>> > __bad_area_nosemaphore+0x178/0x1a2
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810272b9>] ? 
>> > __bad_area+0x44/0x4d
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8100bba2>] 
>> > retint_signal+0x46/0x84
>> > Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd 
>> > pte:2bfe8025
>> > pmd:1535b5067
>> > Mar 24 19:22:28 alfa kernel: page:ffffea0000f1f7c0 
>> > flags:4000000000000404
>> > count:1 mapcount:-1 mapping:(null) index:0
>> > Mar 24 19:22:28 alfa kernel: addr:00000037b400c000 vm_flags:08000875
>> > anon_vma:(null) mapping:ffff88022b5d25a8 index:c
>> > Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: 
>> > filemap_fault+0x0/0x34d
>> > Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
>> > xfs_file_mmap+0x0/0x33
>> > Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Tainted: G B
>> > 2.6.32.10 #2
>> > Mar 24 19:22:28 alfa kernel: Call Trace:
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81044551>] ? add_taint+0x32/0x3e
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c2ea3>] 
>> > print_bad_pte+0x210/0x229
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c3c98>] 
>> > unmap_vmas+0x44b/0x787
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c81d5>] exit_mmap+0xb0/0x133
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81041f83>] mmput+0x48/0xb9
>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810463b0>] exit_mm+0x105/0x110
>> > .....
>> >
>> > The entire log is here:
>> > http://download.netcenter.hu/bughunt/20100324/messages
>> >
>> > The actual kernel is 2.6.32.10, but the crash-series started @ 
>> > 2.6.28.10.
>> >
>> > I have forwarded the tasks to another server, removed this from the 
>> > room,
>> > and the hw survived memtest86 in >7 days continously + i have tested 
>> > the
>> > HDDs one by one with badblocks -vvw, all is good.
>> > For me looks like this is not a hw problem.
>> >
>> > Somebody have any idea?
>> >
>> > Thanks a lot,
>> > Janos Haar
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" 
>> > in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at http://vger.kernel.org/majordomo-info.html
>> > Please read the FAQ at http://www.tux.org/lkml/
>> >
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" 
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/ 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
