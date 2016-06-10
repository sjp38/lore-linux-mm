Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50BFE6B0262
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 06:18:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k184so34381625wme.3
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 03:18:42 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id v77si6408675lfd.295.2016.06.10.03.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 03:18:41 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id q132so5414399lfe.3
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 03:18:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1606092240030.28031@nanos>
References: <CACT4Y+YwV++Eb8n-1q94zW7_rOOX=p8_+8ERD9L07cjrBf7ysw@mail.gmail.com>
 <CACT4Y+ZTFGqVjokXUefFMJOrhAn+go3hPKvQRdAhgRRhab5GrQ@mail.gmail.com>
 <CACT4Y+b8f7=ZnvXnzP17nDwa_jvDeTTQY_Wy7wsiohRssDULhQ@mail.gmail.com> <alpine.DEB.2.11.1606092240030.28031@nanos>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 10 Jun 2016 12:18:20 +0200
Message-ID: <CACT4Y+YWqcCU0z+LS5BboJOxMRYys_sbUPQTA5to5GcUUQK4LQ@mail.gmail.com>
Subject: Re: x86: bad pte in pageattr_test
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 9, 2016 at 11:34 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 7 Jun 2016, Dmitry Vyukov wrote:
>> >> I've got the following WARNING while running syzkaller fuzzer:
>> >>
>> >> CPA ffff880054118000: bad pte after revert 8000000054118363
>>
>> > CPA ffff880059990000: bad pte 8000000059990060
>
> In both cases the PTE bit which the test modifies is in the wrong state.
>
>> Should we delete this test if it is not important?
>
> No. There is something badly wrong.
>
> PAGE_BIT_CPA_TEST is the same as PAGE_BIT_SPECIAL. And the latter is used by
> the mm code to mark user space mappings. The test code only modifies the
> direct mapping, i.e. the kernel side one.
>
> So something sets PAGE_BIT_SPECIAL on a kernel PTE. And that's definitely a
> bug.
>
> These are the last entries from your syzkaller log file of the first incident:
>
> r0 = perf_event_open(&(0x7f000000f000-0x78)={0x2, 0x78, 0x11, 0x7, 0xd537, 0x6, 0x0, 0xc1, 0xffff, 0x5, 0x0, 0x40, 0x4, 0x9, 0x5369, 0x8, 0x7, 0x8508, 0x3, 0x80, 0x0}, 0x0, 0xffffffff, 0xffffffffffffffff, 0x0)
> mmap(&(0x7f0000cbb000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
> r1 = syz_open_dev$mouse(&(0x7f0000cbb000)="2f6465762f696e7075742f6d6f7573652300", 0x100, 0xa00)
> mmap(&(0x7f0000cbc000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
> setsockopt$BT_SNDMTU(r1, 0x112, 0xc, &(0x7f0000cbc000)=0x5, 0x2)
> mmap(&(0x7f0000cbb000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
> ioctl$EVIOCGEFFECTS(r1, 0x80044584, &(0x7f0000cbc000-0x942)=nil)
> r2 = fcntl$dupfd(r0, 0x406, r0)
> mmap(&(0x7f0000cbc000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
> mmap(&(0x7f00002bf000)=nil, (0x1000), 0x3, 0x8010, 0xffffffffffffffff, 0x0)
> mmap(&(0x7f0000000000)=nil, (0x0), 0x3, 0x32, 0xffffffffffffffff, 0x0)
> pwritev(r2, &(0x7f00007e9000)=[{&(0x7f0000cbc000)=....
>
> Do you have log of the second one available as well?
>
> CC'ing mm and perf folks.


Here is the second log:
https://gist.githubusercontent.com/dvyukov/dd7970a5daaa7a30f6d37fa5592b56de/raw/f29182024538e604c95d989f7b398816c3c595dc/gistfile1.txt

I've hit only twice. The first time I tried hard to reproduce it, with
no success. So unfortunately that's all we have.

Re logs: my setup executes up to 16 programs in parallel. So for
normal BUGs any of the preceding 16 programs can be guilty. But since
this check is asynchronous, it can be just any preceding program in
the log.

I would expect that it is triggered by some rarely-executing poorly
tested code. Maybe mmap of some device?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
