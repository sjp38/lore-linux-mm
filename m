Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 472CA6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 19:59:21 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 204-v6so821689itu.6
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 16:59:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z3-v6sor1780334ite.82.2018.04.04.16.59.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 16:59:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJWu+op5-sr=2xWDYcd7FDBeMtrM9Zm96BgGzb4Q31UGBiU3ew@mail.gmail.com>
References: <20180404115310.6c69e7b9@gandalf.local.home> <20180404120002.6561a5bc@gandalf.local.home>
 <CAJWu+orC-1JDYHDTQU+DFckGq5ZnXBCCq9wLG-gNK0Nc4-vo7w@mail.gmail.com>
 <20180404121326.6eca4fa3@gandalf.local.home> <CAJWu+op5-sr=2xWDYcd7FDBeMtrM9Zm96BgGzb4Q31UGBiU3ew@mail.gmail.com>
From: Joel Fernandes <joelaf@google.com>
Date: Wed, 4 Apr 2018 16:59:18 -0700
Message-ID: <CAJWu+opM6RjK-Z1dr35XvQ5cLKaV=cLG5uMu-rLkoO=X03c+FA@mail.gmail.com>
Subject: Re: [PATCH] ring-buffer: Add set/clear_current_oom_origin() during allocations
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

Hi Steve,

On Wed, Apr 4, 2018 at 9:18 AM, Joel Fernandes <joelaf@google.com> wrote:
> On Wed, Apr 4, 2018 at 9:13 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> [..]
>>>
>>> Also, I agree with the new patch and its nice idea to do that.
>>
>> Thanks, want to give it a test too?

With the latest tree and the below diff, I can still OOM-kill a victim
process doing a large buffer_size_kb write:

I pulled your ftrace/core and added this:
+       /*
        i = si_mem_available();
        if (i < nr_pages)
                return -ENOMEM;
+       */

Here's a run in Qemu with 4-cores 1GB total memory:

bash-4.3# ./m -m 1M &
[1] 1056
bash-4.3#
bash-4.3#
bash-4.3#
bash-4.3# echo 10000000 > /d/tracing/buffer_size_kb
[   33.213988] Out of memory: Kill process 1042 (bash) score
1712050900 or sacrifice child
[   33.215349] Killed process 1056 (m) total-vm:9220kB,
anon-rss:7564kB, file-rss:4kB, shmem-rss:640kB
bash: echo: write error: Cannot allocate memory
[1]+  Killed                  ./m -m 1M
bash-4.3#
--

As you can see, OOM killer triggers and kills "m" which is my busy
memory allocator (it allocates and frees lots of memory and does that
in a loop)

Here's the m program, sorry if it looks too ugly:
https://pastebin.com/raw/aG6Qw37Z

Happy to try anything else, BTW when the si_mem_available check
enabled, this doesn't happen and the buffer_size_kb write fails
normally without hurting anything else.

- Joel
