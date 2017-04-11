Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7669D6B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 00:50:15 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k3so61218920ioe.6
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 21:50:15 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id 201si782805itw.49.2017.04.10.21.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 21:50:14 -0700 (PDT)
Received: by mail-io0-x22e.google.com with SMTP id t68so90601908iof.0
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 21:50:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2c43b55e-db82-d67f-10d5-aed84cda58e0@nokia.com>
References: <20170406000059.GA136863@beast> <2c43b55e-db82-d67f-10d5-aed84cda58e0@nokia.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 10 Apr 2017 21:50:13 -0700
Message-ID: <CAGXu5jKTXDkYHU6x4ZQtQ771DNa7u=UeOKkBQz0s8320p2Kv8w@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: Tighten x86 /dev/mem with zeroing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Tommi Rantala <tommi.t.rantala@nokia.com>
Cc: Dave Jones <davej@codemonkey.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On Thu, Apr 6, 2017 at 7:25 AM, Tommi Rantala <tommi.t.rantala@nokia.com> wrote:
> On 06.04.2017 03:00, Kees Cook wrote:
>>
>> This changes the x86 exception for the low 1MB by reading back zeros for
>> RAM areas instead of blindly allowing them. (It may be possible for heap
>> to end up getting allocated in low 1MB RAM, and then read out, possibly
>> tripping hardened usercopy.)
>>
>> Unfinished: this still needs mmap support.
>>
>> Reported-by: Tommi Rantala <tommi.t.rantala@nokia.com>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>> Tommi, can you check and see if this fixes what you're seeing? I want to
>> make sure this actually works first. (x86info uses seek/read not mmap.)
>
>
> Hi, I can confirm that it works (after adding CONFIG_STRICT_DEVMEM), no more
> kernel bugs when running x86info.

Great, thanks for testing!

Linus, given that this fixes the problem, are you okay with this patch
as at least the first step? It doesn't solve the mmap exposure case,
but I'm struggling to figure out how to construct zero-page holes in
the mmap vma, and strictly speaking hardened usercopy doesn't trip
over the mmap since it's not using copy_to_user...

-Kees

>
>
> open("/dev/mem", O_RDONLY)              = 3
> lseek(3, 1038, SEEK_SET)                = 1038
> read(3, "\300\235", 2)                  = 2
> lseek(3, 646144, SEEK_SET)              = 646144
> read(3,
> "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1024)
> = 1024
> lseek(3, 1043, SEEK_SET)                = 1043
> read(3, "w\2", 2)                       = 2
> lseek(3, 645120, SEEK_SET)              = 645120
> read(3,
> "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1024)
> = 1024
> lseek(3, 654336, SEEK_SET)              = 654336
> read(3,
> "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1024)
> = 1024
> lseek(3, 983040, SEEK_SET)              = 983040
> read(3,
> "IFE$\245S\0\0\1\0\0\0\0\360y\0\0\360\220\260\30\237{=\23\10\17\0000\276\17\0"...,
> 65536) = 65536
> lseek(3, 917504, SEEK_SET)              = 917504
> read(3,
> "\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"...,
> 65536) = 65536
> lseek(3, 524288, SEEK_SET)              = 524288
> read(3,
> "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
> 65536) = 65536
> lseek(3, 589824, SEEK_SET)              = 589824
> read(3,
> "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
> 65536) = 65536
>
>
> dd works too:
>
> # LANG=C dd if=/dev/mem of=/dev/null bs=4096 count=256
> 256+0 records in
> 256+0 records out
> 1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0874073 s, 12.0 MB/s
>
>
>
>> ---
>>
>>  arch/x86/mm/init.c | 41 +++++++++++++++++++--------
>>  drivers/char/mem.c | 82
>> ++++++++++++++++++++++++++++++++++--------------------
>>  2 files changed, 82 insertions(+), 41 deletions(-)



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
