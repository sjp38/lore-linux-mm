Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 166C56B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 18:10:52 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 105so3767166oth.22
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 15:10:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v185sor1867137oia.45.2017.12.14.15.10.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 15:10:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b4fb7b3a-e53e-bf87-53c5-186751a14f4e@nvidia.com>
References: <20171213092550.2774-1-mhocko@kernel.org> <20171213093110.3550-1-mhocko@kernel.org>
 <20171213093110.3550-2-mhocko@kernel.org> <CAG48ez0JZ3PVW3vgSXDmDijS+a_5bSX9qNuyggnsB6JTSkKngA@mail.gmail.com>
 <b4fb7b3a-e53e-bf87-53c5-186751a14f4e@nvidia.com>
From: Jann Horn <jannh@google.com>
Date: Fri, 15 Dec 2017 00:10:29 +0100
Message-ID: <CAG48ez0z124816RCtXxtZzYfF+uw4uAnnB2JgN_afwYV32bs4w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mmap.2: MAP_FIXED updated documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Michal Hocko <mhocko@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyril Hrubis <chrubis@suse.cz>, Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@suse.com>

On Fri, Dec 15, 2017 at 12:06 AM, John Hubbard <jhubbard@nvidia.com> wrote:
> On 12/13/2017 06:52 PM, Jann Horn wrote:
>> On Wed, Dec 13, 2017 at 10:31 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>> From: John Hubbard <jhubbard@nvidia.com>
> [...]
>>> +.IP
>>> +Furthermore, this option is extremely hazardous (when used on its own), because
>>> +it forcibly removes pre-existing mappings, making it easy for a multi-threaded
>>> +process to corrupt its own address space.
>>
>> I think this is worded unfortunately. It is dangerous if used
>> incorrectly, and it's a good tool when used correctly.
>>
>> [...]
>>> +Thread B need not create a mapping directly; simply making a library call
>>> +that, internally, uses
>>> +.I dlopen(3)
>>> +to load some other shared library, will
>>> +suffice. The dlopen(3) call will map the library into the process's address
>>> +space. Furthermore, almost any library call may be implemented using this
>>> +technique.
>>> +Examples include brk(2), malloc(3), pthread_create(3), and the PAM libraries
>>> +(http://www.linux-pam.org).
>>
>> This is arkward. This first mentions dlopen(), which is a very niche
>> case, and then just very casually mentions the much bigger
>> problem that tons of library functions can allocate memory through
>> malloc(), causing mmap() calls, sometimes without that even being
>> a documented property of the function.
>>
>
> Hi Jann,
>
> Here is some proposed new wording, to address your two comments above. What do
> you think of this:
>
> NOTE:  this  option  can  be hazardous (when used on its own), because it
> forcibly removes pre-existing mappings,  making  it  easy  for  a  multi-
> threaded  process to corrupt its own address space. For example, thread A
> looks through /proc/<pid>/maps and locates an  available  address  range,
> while  thread  B simultaneously acquires part or all of that same address
> range. Thread A then calls mmap(MAP_FIXED), effectively  overwriting  the
> mapping that thread B created.
>
> Thread B need not create a mapping directly; simply making a library call
> whose implementation calls malloc(3), mmap(), or dlopen(3) will  suffice,
> because those calls all create new mappings.

Thanks! That sounds better to me.

>>> +.IP
>>> +Newer kernels
>>> +(Linux 4.16 and later) have a
>>> +.B MAP_FIXED_SAFE
>>> +option that avoids the corruption problem; if available, MAP_FIXED_SAFE
>>> +should be preferred over MAP_FIXED.
>>
>> This is bad advice. MAP_FIXED is completely safe if you use it on an address
>> range you've allocated, and it is used in this way by core system libraries to
>> place multiple VMAs in virtually contiguous memory, for example:
> [...]
>> MAP_FIXED is a better solution for these usecases than MAP_FIXED_SAFE,
>> or whatever it ends up being called. Please remove this advice or, better,
>> clarify what MAP_FIXED should be used for (creation of virtually contiguous
>> VMAs) and what MAP_FIXED_SAFE should be used for (attempting to
>> allocate memory at a fixed address for some reason, with a failure instead of
>> the normal fallback to using a different address).
>>
>
> Rather than risk another back-and-forth with Michal (who doesn't want any advice
> on how to use this safely, in the man page), I've simply removed this advice
> entirely.

Makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
