Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03B856B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:16:31 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j18so8994044pgv.18
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 10:16:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s78sor4519551pfa.45.2018.04.24.10.16.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 10:16:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180424170239.GP17484@dhcp22.suse.cz>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
 <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
 <20180422125141.GF17484@dhcp22.suse.cz> <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com>
 <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com>
 <20180424132057.GE17484@dhcp22.suse.cz> <850575801.19606468.1524588530119.JavaMail.zimbra@redhat.com>
 <20180424170239.GP17484@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 24 Apr 2018 19:16:00 +0200
Message-ID: <CACT4Y+Y8uoLfrecOMqbW3g9vUNUH_1wmgWT+ZTbmL+b2fijazQ@mail.gmail.com>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chunyu Hu <chuhu@redhat.com>, Chunyu Hu <chuhu.ncepu@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Apr 24, 2018 at 7:02 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 24-04-18 12:48:50, Chunyu Hu wrote:
>>
>>
>> ----- Original Message -----
>> > From: "Michal Hocko" <mhocko@kernel.org>
>> > To: "Chunyu Hu" <chuhu.ncepu@gmail.com>
>> > Cc: "Dmitry Vyukov" <dvyukov@google.com>, "Catalin Marinas" <catalin.marinas@arm.com>, "Chunyu Hu"
>> > <chuhu@redhat.com>, "LKML" <linux-kernel@vger.kernel.org>, "Linux-MM" <linux-mm@kvack.org>
>> > Sent: Tuesday, April 24, 2018 9:20:57 PM
>> > Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
>> >
>> > On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
>> > [...]
>> > > So if there is a new flag, it would be the 25th bits.
>> >
>> > No new flags please. Can you simply store a simple bool into fail_page_alloc
>> > and have save/restore api for that?
>>
>> Hi Michal,
>>
>> I still don't get your point. The original NOFAIL added in kmemleak was
>> for skipping fault injection in page/slab  allocation for kmemleak object,
>> since kmemleak will disable itself until next reboot, whenever it hit an
>> allocation failure, in that case, it will lose effect to check kmemleak
>> in errer path rose by fault injection. But NOFAULT's effect is more than
>> skipping fault injection, it's also for hard allocation. So a dedicated flag
>> for skipping fault injection in specified slab/page allocation was mentioned.
>
> I am not familiar with the kmemleak all that much, but fiddling with the
> gfp_mask is a wrong way to achieve kmemleak specific action. I might be

I would say this is more like slab fault injection-specific action. It
can be used in other debugging facilities. Slab fault injection is a
part of slab. Slab behavior is generally controlled with gfp_mask.

> easilly wrong but I do not see any code that would restore the original
> gfp_mask down the kmem_cache_alloc path.
>
>> d9570ee3bd1d ("kmemleak: allow to coexist with fault injection")
>>
>> Do you mean something like below, with the save/store api? But looks like
>> to make it possible to skip a specified allocation, not global disabling,
>> a bool is not enough, and a gfp_flag is also needed. Maybe I missed something?
>
> Yes, this is essentially what I meant. It is still a global thing which
> is not all that great and if it matters then you can make it per
> task_struct. That really depends on the code flow here.

If we go this route, it definitely needs to be per task and also needs
to work with interrupts: switch on interrupts and not corrupt on
interrupts. A gfp flag is free of these problems.
