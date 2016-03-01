Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8E86B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 10:27:49 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p65so40410679wmp.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 07:27:49 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id a13si26007613wmd.86.2016.03.01.07.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 07:27:48 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id p65so38530401wmp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 07:27:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160229113448.GC7935@e104818-lin.cambridge.arm.com>
References: <CACT4Y+bZticikTpnc0djxRBLCWhj=2DqQk=KRf5zDvrLdHzEbQ@mail.gmail.com>
 <CACT4Y+a+L3+VUEV7c2Q6c7tb8A57dpsitM=P6KVSHV=WYrpahw@mail.gmail.com>
 <20160228234657.GA28225@MBP.local> <CACT4Y+a-J5_t2xsHn6RGWoHPE-huJ2zJ0S01zR1kJew=c6SUsQ@mail.gmail.com>
 <20160229113448.GC7935@e104818-lin.cambridge.arm.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 1 Mar 2016 16:27:28 +0100
Message-ID: <CACT4Y+bXyxLZgt5VXPQJPQ-VpO1SmHT0meKqds5tr5JaZ-867g@mail.gmail.com>
Subject: Re: tty: memory leak in tty_register_driver
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, LKML <linux-kernel@vger.kernel.org>, Peter Hurley <peter@hurleysoftware.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, J Freyensee <james_p_freyensee@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paul Bolle <pebolle@tiscali.nl>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>

On Mon, Feb 29, 2016 at 12:34 PM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> On Mon, Feb 29, 2016 at 11:22:58AM +0100, Dmitry Vyukov wrote:
>> On Mon, Feb 29, 2016 at 12:47 AM, Catalin Marinas
>> <catalin.marinas@arm.com> wrote:
>> > On Sun, Feb 28, 2016 at 05:42:24PM +0100, Dmitry Vyukov wrote:
>> >> On Mon, Feb 15, 2016 at 11:42 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> >> > When I am running the following program in a parallel loop, kmemleak
>> >> > starts reporting memory leaks of objects allocated in
>> >> > tty_register_driver during boot. These leaks start popping up
>> >> > chaotically and as you can see they originate in different drivers
>> >> > (synclinkmp_init, isdn_init, chr_dev_init, sysfs_init).
>> >> >
>> >> > On commit 388f7b1d6e8ca06762e2454d28d6c3c55ad0fe95 (4.5-rc3).
>> > [...]
>> >> > unreferenced object 0xffff88006708dc20 (size 8):
>> >> >   comm "swapper/0", pid 1, jiffies 4294672590 (age 930.839s)
>> >> >   hex dump (first 8 bytes):
>> >> >     74 74 79 53 4c 4d 38 00                          ttySLM8.
>> >> >   backtrace:
>> >> >     [<ffffffff81765d10>] __kmalloc_track_caller+0x1b0/0x320 mm/slub.c:4068
>> >> >     [<ffffffff816b37a9>] kstrdup+0x39/0x70 mm/util.c:53
>> >> >     [<ffffffff816b3826>] kstrdup_const+0x46/0x60 mm/util.c:74
>> >> >     [<ffffffff8194e5bb>] __kernfs_new_node+0x2b/0x2b0 fs/kernfs/dir.c:536
>> >> >     [<ffffffff81951c70>] kernfs_new_node+0x80/0xe0 fs/kernfs/dir.c:572
>> >> >     [<ffffffff81957223>] kernfs_create_link+0x33/0x150 fs/kernfs/symlink.c:32
>> >> >     [<ffffffff81959c4b>] sysfs_do_create_link_sd.isra.2+0x8b/0x120
>> > [...]
>> >> +Catalin (kmemleak maintainer)
>> >>
>> >> I am noticed a weird thing. I am not 100% sure but it seems that the
>> >> leaks are reported iff I run leak checking concurrently with the
>> >> programs running. And if I run the program several thousand times and
>> >> then run leak checking, then no leaks reported.
>> >>
>> >> Catalin, it is possible that it is a kmemleak false positive?
>> >
>> > Yes, it's possible. If you run kmemleak scanning continuously (or at
>> > very short intervals) and especially in parallel with some intensive
>> > tasks, it will miss pointers that may be stored in registers (on other
>> > CPUs) or moved between task stacks, other memory locations. Linked lists
>> > are especially prone to such false positives.
>> >
>> > Kmemleak tries to work around this by checksumming each object, so it
>> > will only be reported if it hasn't changed on two consecutive scans.
>> > Since the default scanning is 10min, it is very unlikely to trigger
>> > false positives in such scenarios. However, if you reduce the scanning
>> > time (or trigger it manually in a loop), you can hit this condition.
>> >
>> >> I see that kmemleak just scans thread stacks one-by-one. I would
>> >> expect that kmemleak should stop all threads, then scan all stacks and
>> >> all registers of all threads, and then restart threads. If it does not
>> >> scan registers or does not stop threads, then I think it should be
>> >> possible that a pointer value can sneak off kmemleak. Does it make
>> >> sense?
>> >
>> > Given how long it takes to scan the memory, stopping the threads is not
>> > really feasible. You could do something like stop_machine() only for
>> > scanning the current stack on all CPUs but it still wouldn't catch
>> > pointers being moved around in memory unless you stop the system
>> > completely for a full scan. The heuristic about periodic scanning and
>> > checksumming seems to work fine in normal usage scenarios.
>> >
>> > For your tests, I would recommend that you run the tests for a long(ish)
>> > time and only do two kmemleak scans at the end after they finished (and
>> > with a few seconds delay between them). Continuous scanning is less
>> > reliable.
>>
>> Let me describe my usage scenario first. I am running automatic
>> testing 24x7. Currently a VM executes a dozen of small programs (a
>> dozen of syscalls each), then I run manual leak scanning.
>
> IIUC, you said that the leak reporting happens iff you run leak checking
> concurrently with the test programs running. If you run the kmemleak
> scanning afterwards, there are no leaks reported. As I explained, that's
> the normal usage I would expect.
>
>> I can't run significantly more programs between scans, because then I
>> won't be able to restore reproducers for bugs and they will be
>> unactionable. I could run leak checking after each program, but it
>> will increase overhead significantly. So a dozen of programs is a
>> trade-off. And I disable automatic scanning.
>
> That's fine, not an issue here.
>
>> False positives are super unpleasant in automatic testing. If a tool
>> false positive rate if high, I just disable it, it is unusable. It is
>> not that bad for leak checking. But each false positive consumes human
>> (my) time.
>
> Indeed. I've spent a significant amount of time in the early kmemleak
> days just trying to prove whether it's a real leak or not but these days
> with the automatic scanning, false positives seem to be very low ratio.
>
>> So I need to run scanning twice, because the first one never reports leaks.
>
> That's because of the checksumming. For example, you have objects stored
> in a list. On some delete or insert, the list_head is temporarily
> modified, possibly stored in CPU registers on another CPU. For this
> brief time, kmemleak may no longer detect a pointer to the rest of the
> list, hence reporting a big part of it as leaked objects.
>
> Since list deletion/insertion requires a modification of an object
> list_head, it's checksum changes, hence if this value has changed since
> the previous scan, kmemleak will not report the object, assuming it is
> something transient. If you run two scans in quick succession, it
> possible that the transient condition hasn't cleared yet, so you risk a
> false positive. Of course, I could place some random delay in kmemleak
> between successive scans but I assumed that most people would leave it
> running on the default 10min scan.
>
> I had other heuristics like object age but checksumming proved to be the
> most efficient, with the minor drawback that you'd have to run the
> scanning twice before reporting. And any kind of delayed reporting (e.g.
> X secs since the last checksum modification) would most likely break
> your testing workflow.
>
>> For the false positives due to registers/pointer jumping, will it help
>> if I run scanning one more time if leaks are detected? I mean: run
>> scanning twice, if leaks are found sleep for several seconds and run
>> scanning third time. Since leaks are usually not detected I can afford
>> to sleep more and do one or two additional scans.
>
> This should work.
>
>> The question here: will kmemleak _remove_ an object for leaked
>> objects, if it discovered reachable or contents change on subsequent
>> scans?
>
> Yes, it will remove them from /sys/kernel/debug/kmemleak even if they
> were previously reported.
>
>> Regarding stopping all threads and doing proper scan, why is not it
>> feasible? Will kernel break if we stall all CPUs for seconds? In
>> automatic testing scenarios a stalled for several seconds machine is
>> not a problem. But on the other hand, absence of false positives is a
>> must. And it would improve testing bandwidth, because we don't need
>> sleep and second scan.
>
> Scanning time is the main issue with it taking minutes on some slow ARM
> machines (my primary testing target). Such timing was significantly
> improved with commit 93ada579b0ee ("mm: kmemleak: optimise kmemleak_lock
> acquiring during kmemleak_scan") but even if it is few seconds, it is
> not suitable for a live, interactive system.
>
> What we could do though, since you already trigger the scanning
> manually, is to add a "stopscan" command that you echo into
> /sys/kernel/debug/kmemleak and performs a stop_machine() during memory
> scanning. If you have time, please feel free to give it a try ;).


Stopscan would be useful for me, but I don't feel like I am ready to
tackle it. To be absolutely sure that we don't miss pointers we would
also need to scan all registers from stopped CPUs, and I don't know
how to obtain that.

For now I did several changes in my test driver:
 - try harder to ensure that there are no concurrent activities during scanning
 - scan twice with second delay
 - if something is discovered, wait another second and scan again
Will monitor how it affects false positive rate.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
