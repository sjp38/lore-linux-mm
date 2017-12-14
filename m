Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 77A966B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 00:28:41 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id s9so2114072oie.2
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:28:41 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id c46si1195670oth.175.2017.12.13.21.28.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 21:28:40 -0800 (PST)
Subject: Re: [PATCH 2/2] mmap.2: MAP_FIXED updated documentation
References: <20171213092550.2774-1-mhocko@kernel.org>
 <20171213093110.3550-1-mhocko@kernel.org>
 <20171213093110.3550-2-mhocko@kernel.org>
 <CAG48ez0JZ3PVW3vgSXDmDijS+a_5bSX9qNuyggnsB6JTSkKngA@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1d9061d5-eb18-e083-a786-1997d34e8707@nvidia.com>
Date: Wed, 13 Dec 2017 21:28:37 -0800
MIME-Version: 1.0
In-Reply-To: <CAG48ez0JZ3PVW3vgSXDmDijS+a_5bSX9qNuyggnsB6JTSkKngA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyril Hrubis <chrubis@suse.cz>, Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@suse.com>

On 12/13/2017 06:52 PM, Jann Horn wrote:
> On Wed, Dec 13, 2017 at 10:31 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>>     -- Expand the documentation to discuss the hazards in
>>        enough detail to allow avoiding them.
>>
>>     -- Mention the upcoming MAP_FIXED_SAFE flag.
>>
>>     -- Enhance the alignment requirement slightly.
>>
>> CC: Michael Ellerman <mpe@ellerman.id.au>
>> CC: Jann Horn <jannh@google.com>
>> CC: Matthew Wilcox <willy@infradead.org>
>> CC: Michal Hocko <mhocko@kernel.org>
>> CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
>> CC: Cyril Hrubis <chrubis@suse.cz>
>> CC: Pavel Machek <pavel@ucw.cz>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> ---
>>  man2/mmap.2 | 32 ++++++++++++++++++++++++++++++--
>>  1 file changed, 30 insertions(+), 2 deletions(-)
>>
>> diff --git a/man2/mmap.2 b/man2/mmap.2
>> index 02d391697ce6..cb8789daec2d 100644
>> --- a/man2/mmap.2
>> +++ b/man2/mmap.2
> [...]
>> @@ -226,6 +227,33 @@ Software that aspires to be portable should use this option with care, keeping
>>  in mind that the exact layout of a process' memory map is allowed to change
>>  significantly between kernel versions, C library versions, and operating system
>>  releases.
>> +.IP
>> +Furthermore, this option is extremely hazardous (when used on its own), because
>> +it forcibly removes pre-existing mappings, making it easy for a multi-threaded
>> +process to corrupt its own address space.
> 
> I think this is worded unfortunately. It is dangerous if used
> incorrectly, and it's a good tool when used correctly.
> 

Hi Jann,

Hey, thanks for reviewing this again. I think I can accomodate all of your requests,
without contradicting other reviewers' earlier feedback...approximately. :)  I'll 
have a go at rewording this, and addressing your additional comments below, tomorrow
afternoon, so please look for an updated version later that day.

thanks,
-- 
John Hubbard
NVIDIA

> [...]
>> +Thread B need not create a mapping directly; simply making a library call
>> +that, internally, uses
>> +.I dlopen(3)
>> +to load some other shared library, will
>> +suffice. The dlopen(3) call will map the library into the process's address
>> +space. Furthermore, almost any library call may be implemented using this
>> +technique.
>> +Examples include brk(2), malloc(3), pthread_create(3), and the PAM libraries
>> +(http://www.linux-pam.org).
> 
> This is arkward. This first mentions dlopen(), which is a very niche
> case, and then just very casually mentions the much bigger
> problem that tons of library functions can allocate memory through
> malloc(), causing mmap() calls, sometimes without that even being
> a documented property of the function.
> 
>> +.IP
>> +Newer kernels
>> +(Linux 4.16 and later) have a
>> +.B MAP_FIXED_SAFE
>> +option that avoids the corruption problem; if available, MAP_FIXED_SAFE
>> +should be preferred over MAP_FIXED.
> 
> This is bad advice. MAP_FIXED is completely safe if you use it on an address
> range you've allocated, and it is used in this way by core system libraries to
> place multiple VMAs in virtually contiguous memory, for example:
> 
> ld.so (from glibc) uses it to load dynamic libraries:
> 
> $ strace -e trace=open,mmap,close /usr/bin/id 2>&1 >/dev/null | head -n20
> mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
> 0) = 0x7f35811c0000
> open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
> mmap(NULL, 161237, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f3581198000
> close(3)                                = 0
> open("/lib/x86_64-linux-gnu/libselinux.so.1", O_RDONLY|O_CLOEXEC) = 3
> mmap(NULL, 2259664, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
> 0) = 0x7f3580d78000
> mmap(0x7f3580f9c000, 8192, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x24000) = 0x7f3580f9c000
> mmap(0x7f3580f9e000, 6864, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f3580f9e000
> close(3)                                = 0
> open("/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
> mmap(NULL, 3795360, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
> 0) = 0x7f35809d9000
> mmap(0x7f3580d6e000, 24576, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x195000) = 0x7f3580d6e000
> mmap(0x7f3580d74000, 14752, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f3580d74000
> close(3)                                = 0
> [...]
> 
> As a comment in dl-map-segments.h in glibc explains:
>       /* This is a position-independent shared object.  We can let the
>          kernel map it anywhere it likes, but we must have space for all
>          the segments in their specified positions relative to the first.
>          So we map the first segment without MAP_FIXED, but with its
>          extent increased to cover all the segments.  Then we remove
>          access from excess portion, and there is known sufficient space
>          there to remap from the later segments.
> 
> 
> And AFAIK anything that allocates thread stacks uses MAP_FIXED to
> create the guard page at the bottom.
> 
> 
> MAP_FIXED is a better solution for these usecases than MAP_FIXED_SAFE,
> or whatever it ends up being called. Please remove this advice or, better,
> clarify what MAP_FIXED should be used for (creation of virtually contiguous
> VMAs) and what MAP_FIXED_SAFE should be used for (attempting to
> allocate memory at a fixed address for some reason, with a failure instead of
> the normal fallback to using a different address).
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
