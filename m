From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86: bad pte in pageattr_test
Date: Thu, 9 Jun 2016 23:34:19 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1606092240030.28031@nanos>
References: <CACT4Y+YwV++Eb8n-1q94zW7_rOOX=p8_+8ERD9L07cjrBf7ysw@mail.gmail.com> <CACT4Y+ZTFGqVjokXUefFMJOrhAn+go3hPKvQRdAhgRRhab5GrQ@mail.gmail.com> <CACT4Y+b8f7=ZnvXnzP17nDwa_jvDeTTQY_Wy7wsiohRssDULhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+b8f7=ZnvXnzP17nDwa_jvDeTTQY_Wy7wsiohRssDULhQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>
List-Id: linux-mm.kvack.org

On Tue, 7 Jun 2016, Dmitry Vyukov wrote:
> >> I've got the following WARNING while running syzkaller fuzzer:
> >>
> >> CPA ffff880054118000: bad pte after revert 8000000054118363
> 
> > CPA ffff880059990000: bad pte 8000000059990060

In both cases the PTE bit which the test modifies is in the wrong state.

> Should we delete this test if it is not important?

No. There is something badly wrong.

PAGE_BIT_CPA_TEST is the same as PAGE_BIT_SPECIAL. And the latter is used by
the mm code to mark user space mappings. The test code only modifies the
direct mapping, i.e. the kernel side one.

So something sets PAGE_BIT_SPECIAL on a kernel PTE. And that's definitely a
bug.

These are the last entries from your syzkaller log file of the first incident:

r0 = perf_event_open(&(0x7f000000f000-0x78)={0x2, 0x78, 0x11, 0x7, 0xd537, 0x6, 0x0, 0xc1, 0xffff, 0x5, 0x0, 0x40, 0x4, 0x9, 0x5369, 0x8, 0x7, 0x8508, 0x3, 0x80, 0x0}, 0x0, 0xffffffff, 0xffffffffffffffff, 0x0)
mmap(&(0x7f0000cbb000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
r1 = syz_open_dev$mouse(&(0x7f0000cbb000)="2f6465762f696e7075742f6d6f7573652300", 0x100, 0xa00)
mmap(&(0x7f0000cbc000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
setsockopt$BT_SNDMTU(r1, 0x112, 0xc, &(0x7f0000cbc000)=0x5, 0x2)
mmap(&(0x7f0000cbb000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
ioctl$EVIOCGEFFECTS(r1, 0x80044584, &(0x7f0000cbc000-0x942)=nil)
r2 = fcntl$dupfd(r0, 0x406, r0)
mmap(&(0x7f0000cbc000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
mmap(&(0x7f00002bf000)=nil, (0x1000), 0x3, 0x8010, 0xffffffffffffffff, 0x0)
mmap(&(0x7f0000000000)=nil, (0x0), 0x3, 0x32, 0xffffffffffffffff, 0x0)
pwritev(r2, &(0x7f00007e9000)=[{&(0x7f0000cbc000)=....

Do you have log of the second one available as well?

CC'ing mm and perf folks.

Thanks,

	tglx
