Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4983A6B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:18:02 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q83-v6so9682982oif.2
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:18:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 19-v6sor5837341oir.110.2018.04.16.13.18.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 13:18:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416195726.GT17484@dhcp22.suse.cz>
References: <9c714917-fc29-4d12-b5e8-cff28761a2c1@gmail.com>
 <20180413064917.GC17484@dhcp22.suse.cz> <CAG48ez2w+3FDh9LM3+P2EHowicjM2Xw6giR6uq=26JfWHYsTAQ@mail.gmail.com>
 <20180413160435.GA17484@dhcp22.suse.cz> <CAG48ez3-xtmAt2EpRFR8GNKKPcsDsyg7XdwQ=D5w3Ym6w4Krjw@mail.gmail.com>
 <CAG48ez1PdzMs8hkatbzSLBWYucjTc75o8ovSmeC66+e9mLvSfA@mail.gmail.com>
 <20180416100736.GG17484@dhcp22.suse.cz> <CAG48ez3DwRXMtiinUWKnan6hAppLYLdx-w+VzXG6ubioZUacQg@mail.gmail.com>
 <20180416191805.GS17484@dhcp22.suse.cz> <CAG48ez1nf96nHj8a+aZy22RwqYTUZBGrsGFcz=ZhZBUWzaEZ9w@mail.gmail.com>
 <20180416195726.GT17484@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Mon, 16 Apr 2018 22:17:40 +0200
Message-ID: <CAG48ez1bV_zZP3Y2ioDndP+H8mLCcxOtU1vCbWe7Q8myEGfXQQ@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, linux-man <linux-man@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Apr 16, 2018 at 9:57 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 16-04-18 21:30:09, Jann Horn wrote:
>> On Mon, Apr 16, 2018 at 9:18 PM, Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>> > Yes, reasonably well written application will not have this problem.
>> > That, however, requires an external synchronization and that's why
>> > called it error prone and racy. I guess that was the main motivation for
>> > that part of the man page.
>>
>> What requires external synchronization? I still don't understand at
>> all what you're talking about.
>>
>> The following code:
>>
>> void *try_to_alloc_addr(void *hint, size_t len) {
>>   char *x = mmap(hint, len, ...);
>>   if (x == MAP_FAILED) return NULL;
>>   if (x == hint) return x;
>
> Any other thread can modify the address space at this moment.

But not parts of the address space that were returned by this mmap() call.

> Just
> consider that another thread would does mmap(x, MAP_FIXED) (or any other
> address overlapping [x, x+len] range)

If the other thread does that without previously having created a
mapping covering the area in question, that would be a bug in the
other thread. MAP_FIXED on an unmapped address is almost always a bug
(excluding single-threaded cases with no library code, and even then
it's quite weird) - for example, any malloc() call could also cause
libc to start using the memory range you're trying to map with
MAP_FIXED.

> becaus it is seemingly safe as x
> != hint.

I don't understand this part. Are you talking about a hypothetical
scenario in which a programmer attempts to segment the virtual memory
space into areas that are exclusively used by threads without creating
memory mappings for those areas?

> This will succeed and ...
>>   munmap(x, len);
> ... now you are munmaping somebody's else memory range
>
>>   return NULL;
>
> Do code _is_ buggy but it is not obvious at all.
>
>> }
>>
>> has no need for any form of external synchronization.
>
> If the above mmap/munmap section was protected by a lock and _all_ other
> mmaps (direct or indirect) would use the same lock then you are safe
> against that.
