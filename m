Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAC276B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 08:21:52 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d186so6220997iog.10
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 05:21:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p143sor2304910ioe.132.2018.04.04.05.21.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 05:21:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180404062039.GC6312@dhcp22.suse.cz>
References: <20180403110612.GM5501@dhcp22.suse.cz> <20180403075158.0c0a2795@gandalf.local.home>
 <20180403121614.GV5501@dhcp22.suse.cz> <20180403082348.28cd3c1c@gandalf.local.home>
 <20180403123514.GX5501@dhcp22.suse.cz> <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz> <20180403101753.3391a639@gandalf.local.home>
 <20180403161119.GE5501@dhcp22.suse.cz> <20180403185627.6bf9ea9b@gandalf.local.home>
 <20180404062039.GC6312@dhcp22.suse.cz>
From: Joel Fernandes <joelaf@google.com>
Date: Wed, 4 Apr 2018 05:21:49 -0700
Message-ID: <CAJWu+oo8LE6ZzPaz0KgT4C5a3vYJS2SkohHMObj3pWN9BZMN=A@mail.gmail.com>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Apr 3, 2018 at 11:20 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 03-04-18 18:56:27, Steven Rostedt wrote:
> [...]
>> From your earlier email:
>>
>> > Except that it doesn't work. si_mem_available is not really suitable for
>> > any allocation estimations. Its only purpose is to provide a very rough
>> > estimation for userspace. Any other use is basically abuse. The
>> > situation can change really quickly. Really it is really hard to be
>> > clever here with the volatility the memory allocations can cause.
>>
>> Now can you please explain to me why si_mem_available is not suitable
>> for my purpose.
>
> Several problems. It is overly optimistic especially when we are close
> to OOM. The available pagecache or slab reclaimable objects might be pinned
> long enough that your allocation based on that estimation will just make
> the situation worse and result in OOM. More importantly though, your
> allocations are GFP_KERNEL, right, that means that such an allocation
> will not reach to ZONE_MOVABLE or ZONE_HIGMEM (32b systems) while the
> pagecache will. So you will get an overestimate of how much you can
> allocate.

Yes, but right now it is assumed that there is all the memory in the
world to allocate. Clearly an overestimate is better than that. Right
now ftrace will just allocate memory until it actually fails to
allocate, at which point it may have caused other processes to be
likely to OOM. As Steve pointed out, it doesn't need to be accurate
but does solve the problem here.. (or some other similar method seems
to be needed to solve it).

>
> Really si_mem_available is for proc/meminfo and a rough estimate of the
> free memory because users tend to be confused by seeing MemFree too low
> and complaining that the system has eaten all their memory. I have some

By why is a rough estimate not good in this case, that's what I don't get.

> skepticism about how useful it is in practice apart from showing it in
> top or alike tools. The memory is simply not usable immediately or
> without an overall and visible effect on the whole system.

Sure there can be false positives but it does reduce the problem for
the most part I feel. May be we can use this as an interim solution
(better than leaving the issue hanging)? Or you could propose a
solution of how to get an estimate and prevent other tasks from
experiencing memory pressure for no reason.

Another thing we could do is check how much total memory there is on
the system and cap by that (which will prevent impossibly large
allocations) but that still doesn't address the problem completely.

thanks,

- Joel
