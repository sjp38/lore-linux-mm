Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40B316B02B8
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 06:52:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id y2-v6so47593pll.16
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 03:52:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8-v6sor4607705plk.26.2018.07.09.03.52.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 03:52:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+a=8NOg+h6fBzpmVHiZ-vNUiG7SW4QgQvK3vD=KBqQ3_Q@mail.gmail.com>
References: <0000000000004a7da505708a9915@google.com> <20180709101558.63vkwppwcgzcv3dg@kshutemo-mobl1>
 <CACT4Y+a=8NOg+h6fBzpmVHiZ-vNUiG7SW4QgQvK3vD=KBqQ3_Q@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 9 Jul 2018 12:52:21 +0200
Message-ID: <CACT4Y+baBmOHwH6rUL3DjKhGk-JjBAvKOmnq65_4z6b96ohrBQ@mail.gmail.com>
Subject: Re: kernel BUG at mm/memory.c:LINE!
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: syzbot <syzbot+3f84280d52be9b7083cc@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>, ying.huang@intel.com

On Mon, Jul 9, 2018 at 12:48 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Mon, Jul 9, 2018 at 12:15 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
>> On Sun, Jul 08, 2018 at 10:51:03PM -0700, syzbot wrote:
>>> Hello,
>>>
>>> syzbot found the following crash on:
>>>
>>> HEAD commit:    b2d44d145d2a Merge tag '4.18-rc3-smb3fixes' of git://git.s..
>>> git tree:       upstream
>>> console output: https://syzkaller.appspot.com/x/log.txt?x=11d07748400000
>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=2ca6c7a31d407f86
>>> dashboard link: https://syzkaller.appspot.com/bug?extid=3f84280d52be9b7083cc
>>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>>>
>>> Unfortunately, I don't have any reproducer for this crash yet.
>>>
>>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>>> Reported-by: syzbot+3f84280d52be9b7083cc@syzkaller.appspotmail.com
>>>
>>> next ffff8801ce5e7040 prev ffff8801d20eca50 mm ffff88019c1e13c0
>>> prot 27 anon_vma ffff88019680cdd8 vm_ops 0000000000000000
>>> pgoff 0 file ffff8801b2ec2d00 private_data 0000000000000000
>>> flags: 0xff(read|write|exec|shared|mayread|maywrite|mayexec|mayshare)
>>> ------------[ cut here ]------------
>>> kernel BUG at mm/memory.c:1422!
>>
>> Looks like vma_is_anonymous() false-positive.
>>
>> Any clues what file is it? I would guess some kind of socket, but it's not
>> clear from log which exactly.
>
>
> From the log it looks like it was this program (number 3 matches Comm:
> syz-executor3):
>
> 08:39:32 executing program 3:
> r0 = socket$nl_route(0x10, 0x3, 0x0)
> bind$netlink(r0, &(0x7f00000002c0)={0x10, 0x0, 0x0, 0x100000}, 0xc)
> getsockname(r0, &(0x7f0000000000)=@pppol2tpv3in6={0x0, 0x0, {0x0,
> <r1=>0xffffffffffffffff, 0x0, 0x0, 0x0, 0x0, {0x0, 0x0, 0x0,
> @loopback}}}, &(0x7f00000000c0)=0x3a)
> mmap(&(0x7f0000e00000/0x200000)=nil, 0x200000, 0x7fdff, 0x11, r1, 0x0)
> ioctl$FIBMAP(r0, 0x1, &(0x7f0000000100)=0x9)
> r2 = socket$inet6(0xa, 0x1000000000002, 0x0)
> ioctl(r2, 0x8912, &(0x7f00000001c0)="796d05ad441e829115ac7fd77200")
> r3 = syz_open_dev$vcsa(&(0x7f0000000140)='/dev/vcsa#\x00', 0x3, 0x2)
> ioctl$VHOST_SET_VRING_ENDIAN(r3, 0x4008af13, &(0x7f0000000180)={0x0, 0x8})
> sendto$inet(0xffffffffffffffff, &(0x7f0000a88f88), 0xffffffffffffff31,
> 0x0, &(0x7f0000e68000)={0x2, 0x0, @multicast2=0xe0000002},
> 0xfffffffffffffeb3)
> ftruncate(r1, 0x6)
> mmap(&(0x7f0000e00000/0x200000)=nil, 0x200000, 0x0, 0x11, r0, 0x0)
> setsockopt$SO_TIMESTAMPING(r1, 0x1, 0x25, &(0x7f0000000080)=0x804, 0x4)
>
> But take what happens here with a grain of salt, it can pretend that
> it's doing one thing, but actually do something different.
> So that r1 passed to ftruncate is something that getsockname returned
> somewhere in the middle of address. And since the socket is not
> actually ppp, it can be just some bytes in the middle of netlink
> address, that than happened to be small and match some existing fd...


This also happened only once so far:
https://syzkaller.appspot.com/bug?extid=3f84280d52be9b7083cc
and I can't reproduce it rerunning this program. So it's either a very
subtle race, or fd in the middle of netlink address magically matched
some fd once, or something else...
