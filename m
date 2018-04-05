Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00C426B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:47:48 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id q15-v6so3995675itb.7
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:47:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u85sor4023844ioi.54.2018.04.05.12.47.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 12:47:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180405145159.GM6312@dhcp22.suse.cz>
References: <20180404115310.6c69e7b9@gandalf.local.home> <20180404120002.6561a5bc@gandalf.local.home>
 <CAJWu+orC-1JDYHDTQU+DFckGq5ZnXBCCq9wLG-gNK0Nc4-vo7w@mail.gmail.com>
 <20180404121326.6eca4fa3@gandalf.local.home> <CAJWu+op5-sr=2xWDYcd7FDBeMtrM9Zm96BgGzb4Q31UGBiU3ew@mail.gmail.com>
 <CAJWu+opM6RjK-Z1dr35XvQ5cLKaV=cLG5uMu-rLkoO=X03c+FA@mail.gmail.com> <20180405145159.GM6312@dhcp22.suse.cz>
From: Joel Fernandes <joelaf@google.com>
Date: Thu, 5 Apr 2018 12:47:45 -0700
Message-ID: <CAJWu+ooQfN-5tzdEm6=4qTZcvFK+g2GMfX59_9-xkMvwmAk1Rg@mail.gmail.com>
Subject: Re: [PATCH] ring-buffer: Add set/clear_current_oom_origin() during allocations
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 5, 2018 at 7:51 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 04-04-18 16:59:18, Joel Fernandes wrote:
>> Hi Steve,
>>
>> On Wed, Apr 4, 2018 at 9:18 AM, Joel Fernandes <joelaf@google.com> wrote:
>> > On Wed, Apr 4, 2018 at 9:13 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
>> > [..]
>> >>>
>> >>> Also, I agree with the new patch and its nice idea to do that.
>> >>
>> >> Thanks, want to give it a test too?
>>
>> With the latest tree and the below diff, I can still OOM-kill a victim
>> process doing a large buffer_size_kb write:
>>
>> I pulled your ftrace/core and added this:
>> +       /*
>>         i = si_mem_available();
>>         if (i < nr_pages)
>>                 return -ENOMEM;
>> +       */
>>
>> Here's a run in Qemu with 4-cores 1GB total memory:
>>
>> bash-4.3# ./m -m 1M &
>> [1] 1056
>> bash-4.3#
>> bash-4.3#
>> bash-4.3#
>> bash-4.3# echo 10000000 > /d/tracing/buffer_size_kb
>> [   33.213988] Out of memory: Kill process 1042 (bash) score
>> 1712050900 or sacrifice child
>> [   33.215349] Killed process 1056 (m) total-vm:9220kB,
>> anon-rss:7564kB, file-rss:4kB, shmem-rss:640kB
>
> OK, so the reason your memory hog is triggered is that your echo is
> built-in and we properly select bask as an oom_origin but then another
> clever heuristic jumps in and tries to reduce the damage by sacrificing
> a child process. And your memory hog runs as a child from the same bash
> session.

Oh, ok. Makes sense.

>
> I cannot say I would love this heuristic. In fact I would really love to
> dig it deep under the ground. But this is a harder sell than it might
> seem. Anyway is your testing scenario really representative enough to

No honestly I don't care much for this heuristic but was just helping
test it. The scenario is not something I care about, but it seems like
if I hit it then others users will too. Maybe Zhaoyang can try his use
case again with ftrace/core and si_mem_available commented?

IOW I was just helping test the new patch with the si_mem_available
check commented out.

> care? Does the buffer_size_kb updater runs in the same process as any
> large memory process?

In this Qemu run its just the cat process. At work I use trace-cmd or
atrace neither of which I believe have large memory footprints (AFAIK)

Thanks,

- Joel
