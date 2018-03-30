Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E34C76B025E
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 16:37:26 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 137-v6so7724978itj.2
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 13:37:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w99sor3368431ioi.223.2018.03.30.13.37.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 13:37:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180330151037.30d2ac6d@gandalf.local.home>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home> <CAJWu+ooMPz_nFtULMXp6CnLvM8JFJrSnBGNgPHXKs1k97FQU5Q@mail.gmail.com>
 <20180330151037.30d2ac6d@gandalf.local.home>
From: Joel Fernandes <joelaf@google.com>
Date: Fri, 30 Mar 2018 13:37:24 -0700
Message-ID: <CAJWu+ooihz7KJG6Av2THBda2mUd=u-zsNVeB4V7XrQNSwxaHNA@mail.gmail.com>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

Hi Steve,

On Fri, Mar 30, 2018 at 12:10 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
[..]
>> > I wonder if I should have the ring buffer allocate groups of pages, to
>> > avoid this. Or try to allocate with NORETRY, one page at a time, and
>> > when that fails, allocate groups of pages with RETRY_MAYFAIL, and that
>> > may keep it from causing an OOM?
>> >
>>
>> I don't see immediately how that can prevent an OOM in other
>> applications here? If ftrace allocates lots of memory with
>> RETRY_MAYFAIL, then we would still OOM in other applications if memory
>> isn't available. Sorry if I missed something.
>
> Here's the idea.
>
> Allocate one page at a time with NORETRY. If that fails, then allocate
> larger amounts (higher order of pages) with RETRY_MAYFAIL. Then if it
> can't get all the memory it needs, it wont take up all memory in the
> system before it finds out that it can't have any more.
>
> Or perhaps the memory management system can provide a
> get_available_mem() function that ftrace could call before it tries to
> increase the ring buffer and take up all the memory of the system
> before it realizes that it can't get all the memory it wants.
>
> The main problem I have with Zhaoyang's patch is that
> get_available_mem() does not belong in the tracing code. It should be
> something that the mm subsystem provides.
>

Cool. Personally I like the getting of available memory solution and
use that, since its simpler.

MM already provides it through si_mem_available since the commit
"mm/page_alloc.c: calculate 'available' memory in a separate function"
(sha d02bd27b). Maybe we could just use that?

MemAvailable was initially added in commit "/proc/meminfo: provide
estimated available memory" (sha 34e431b0ae39)

thanks,

- Joel
