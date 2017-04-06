Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 750126B0432
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 10:25:45 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p64so30588883oif.0
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 07:25:45 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0111.outbound.protection.outlook.com. [104.47.2.111])
        by mx.google.com with ESMTPS id e66si788956oig.154.2017.04.06.07.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 07:25:42 -0700 (PDT)
Subject: Re: [RFC][PATCH] mm: Tighten x86 /dev/mem with zeroing
References: <20170406000059.GA136863@beast>
From: Tommi Rantala <tommi.t.rantala@nokia.com>
Message-ID: <2c43b55e-db82-d67f-10d5-aed84cda58e0@nokia.com>
Date: Thu, 6 Apr 2017 17:25:34 +0300
MIME-Version: 1.0
In-Reply-To: <20170406000059.GA136863@beast>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On 06.04.2017 03:00, Kees Cook wrote:
> This changes the x86 exception for the low 1MB by reading back zeros for
> RAM areas instead of blindly allowing them. (It may be possible for heap
> to end up getting allocated in low 1MB RAM, and then read out, possibly
> tripping hardened usercopy.)
>
> Unfinished: this still needs mmap support.
>
> Reported-by: Tommi Rantala <tommi.t.rantala@nokia.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> Tommi, can you check and see if this fixes what you're seeing? I want to
> make sure this actually works first. (x86info uses seek/read not mmap.)

Hi, I can confirm that it works (after adding CONFIG_STRICT_DEVMEM), no 
more kernel bugs when running x86info.


open("/dev/mem", O_RDONLY)              = 3
lseek(3, 1038, SEEK_SET)                = 1038
read(3, "\300\235", 2)                  = 2
lseek(3, 646144, SEEK_SET)              = 646144
read(3, 
"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
1024) = 1024
lseek(3, 1043, SEEK_SET)                = 1043
read(3, "w\2", 2)                       = 2
lseek(3, 645120, SEEK_SET)              = 645120
read(3, 
"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
1024) = 1024
lseek(3, 654336, SEEK_SET)              = 654336
read(3, 
"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
1024) = 1024
lseek(3, 983040, SEEK_SET)              = 983040
read(3, 
"IFE$\245S\0\0\1\0\0\0\0\360y\0\0\360\220\260\30\237{=\23\10\17\0000\276\17\0"..., 
65536) = 65536
lseek(3, 917504, SEEK_SET)              = 917504
read(3, 
"\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"..., 
65536) = 65536
lseek(3, 524288, SEEK_SET)              = 524288
read(3, 
"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
65536) = 65536
lseek(3, 589824, SEEK_SET)              = 589824
read(3, 
"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
65536) = 65536


dd works too:

# LANG=C dd if=/dev/mem of=/dev/null bs=4096 count=256
256+0 records in
256+0 records out
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0874073 s, 12.0 MB/s


> ---
>
>  arch/x86/mm/init.c | 41 +++++++++++++++++++--------
>  drivers/char/mem.c | 82 ++++++++++++++++++++++++++++++++++--------------------
>  2 files changed, 82 insertions(+), 41 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
