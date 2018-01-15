Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA1E6B025E
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 09:28:21 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y13so3188265pfl.16
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 06:28:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w24sor806628plq.51.2018.01.15.06.28.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 06:28:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801152325.FGE87548.tSLMFOVHFJOFQO@I-love.SAKURA.ne.jp>
References: <CACT4Y+bkuk3dkwdn7QCbWWWJ=R_nW8Qi6+y35VofLEHYu+6m7w@mail.gmail.com>
 <201801151944.FII09821.FMVQFJtHOOOSLF@I-love.SAKURA.ne.jp>
 <CACT4Y+ZE_7wuJV1V8J+zO2E+CKp8wpCsVfUMqCLXazmjrCRrUQ@mail.gmail.com>
 <201801152256.HDH17623.tSJHFLFOFMVOQO@I-love.SAKURA.ne.jp>
 <CACT4Y+Z2d6aV86rj5OYiv5Xw=D9xi=vW7RpdzP2X+vTnUjFqfQ@mail.gmail.com> <201801152325.FGE87548.tSLMFOVHFJOFQO@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 15 Jan 2018 15:27:58 +0100
Message-ID: <CACT4Y+abO438-ncA83M296BQUMi+Ya0ZZRzY35uMD9QfOobhAA@mail.gmail.com>
Subject: Re: INFO: task hung in filemap_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Hannes Reinecke <hare@suse.de>, Omar Sandoval <osandov@fb.com>, shli@fb.com

On Mon, Jan 15, 2018 at 3:25 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> >> I am not completely following. You previously mentioned raw.log, which
>> >> is a collection of multiple programs, but now you seem to be talking
>> >> about a single reproducer. When syzbot manages to reproduce the bug
>> >> only with syzkaller program but not with a corresponding C program, it
>> >> provides only syzkaller program. It such case it can sense to convert.
>> >> But the case you pointed to actually contains C program. So there is
>> >> no need to do the conversion at all... What am I missing?
>> >>
>> >
>> > raw.log is not readable for me.
>> > I want to see C program even if syzbot did not manage to reproduce the bug.
>> > If C program is available, everyone can try reproducing the bug with manually
>> > trimmed C program.
>>
>> If it did not manage to reproduce the bug, there is no C program.
>> There is no program at all.
>>
>
> What!? Then, what does raw.log contain? I want to read raw.log as C program.


raw.log is not a _program_, it's hundreds of separate programs that
were executed before the crash. It's also very compressed
representation as compared to equivalent C programs. For example for
this program:

mmap(&(0x7f0000000000/0xfff000)=nil, 0xfff000, 0x3, 0x32,
0xffffffffffffffff, 0x0)
r0 = socket$nl_generic(0x10, 0x3, 0x10)
sendmsg$nl_generic(r0,
&(0x7f0000b3e000-0x38)={&(0x7f0000d4a000-0xc)={0x10, 0x0, 0x0, 0x0},
0xc, &(0x7f0000007000)={&(0x7f0000f7c000-0x15c)={0x24, 0x1c, 0x109,
0xffffffffffffffff, 0xffffffffffffffff, {0x4, 0x0, 0x0},
[@nested={0x10, 0x9, [@typed={0xc, 0x0, @u32=0x0}]}]}, 0x24}, 0x1,
0x0, 0x0, 0x0}, 0x0)

you can get up to this amount of C code:
https://gist.githubusercontent.com/dvyukov/eeaeb4e4ac45c3a251f72098c9295bf9/raw/700cd583507eca90711ba11b42e406f317553371/gistfile1.txt

that is, 700 lines of C source for 3 line program. So instead of a 1MB
file that will be 100MB, and then it probably should be a gzip archive
with hundreds of separate C files. There are people on this list
complaining even about 200K of attachments. I don't see that this will
be better and well accepted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
