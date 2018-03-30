Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 937856B002B
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 15:10:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e19so7473349pga.1
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 12:10:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l30-v6si8960011plg.541.2018.03.30.12.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 12:10:40 -0700 (PDT)
Date: Fri, 30 Mar 2018 15:10:37 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180330151037.30d2ac6d@gandalf.local.home>
In-Reply-To: <CAJWu+ooMPz_nFtULMXp6CnLvM8JFJrSnBGNgPHXKs1k97FQU5Q@mail.gmail.com>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<CAJWu+ooMPz_nFtULMXp6CnLvM8JFJrSnBGNgPHXKs1k97FQU5Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Fri, 30 Mar 2018 09:37:58 -0700
Joel Fernandes <joelaf@google.com> wrote:

> > That said, it appears you are having issues that were caused by the
> > change by commit 848618857d2 ("tracing/ring_buffer: Try harder to
> > allocate"), where we replaced NORETRY with RETRY_MAYFAIL. The point of
> > NORETRY was to keep allocations of the tracing ring-buffer from causing
> > OOMs. But the RETRY was too strong in that case, because there were  
> 
> Yes this was discussed with -mm folks. Basically the problem we were
> seeing is devices with tonnes of free memory (but free as in free but
> used by page cache)  were not being used so it was unnecessarily
> failing to allocate ring buffer on the system with otherwise lots of
> memory.

Right.

> 
> IIRC, the OOM that my patch was trying to avoid, was being triggered
> in the path/context of the write to buffer_size_kb itself (when not
> doing the NORETRY),  not by other processes.

Yes, that is correct.

> 
> > Perhaps this is because the ring buffer allocates one page at a time,
> > and by doing so, it can get every last available page, and if anything
> > in the mean time does an allocation without MAYFAIL, it will cause an
> > OOM. For example, when I stressed this I triggered this:
> >
> >  pool invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
> >  pool cpuset=/ mems_allowed=0
> >  CPU: 7 PID: 1040 Comm: pool Not tainted 4.16.0-rc4-test+ #663
> >  Hardware name: Hewlett-Packard HP Compaq Pro 6300 SFF/339A, BIOS K01 v03.03 07/14/2016
> >  Call Trace:
> >   dump_stack+0x8e/0xce
> >   dump_header.isra.30+0x6e/0x28f
> >   ? _raw_spin_unlock_irqrestore+0x30/0x60
> >   oom_kill_process+0x218/0x400
> >   ? has_capability_noaudit+0x17/0x20
> >   out_of_memory+0xe3/0x5c0
> >   __alloc_pages_slowpath+0xa8e/0xe50
> >   __alloc_pages_nodemask+0x206/0x220
> >   alloc_pages_current+0x6a/0xe0
> >   __page_cache_alloc+0x6a/0xa0
> >   filemap_fault+0x208/0x5f0
> >   ? __might_sleep+0x4a/0x80
> >   ext4_filemap_fault+0x31/0x44
> >   __do_fault+0x20/0xd0
> >   __handle_mm_fault+0xc08/0x1160
> >   handle_mm_fault+0x76/0x110
> >   __do_page_fault+0x299/0x580
> >   do_page_fault+0x2d/0x110
> >   ? page_fault+0x2f/0x50
> >   page_fault+0x45/0x50  
> 
> But this OOM is not in the path of the buffer_size_kb write, right? So
> then what does it have to do with buffer_size_kb write failure?

Yep. I'll explain below.

> 
> I guess the original issue reported is that the buffer_size_kb write
> causes *other* applications to fail allocation. So in that case,
> capping the amount that ftrace writes makes sense. Basically my point
> is I don't see how the patch you mentioned introduces the problem here
> - in the sense the patch just makes ftrace allocate from memory it
> couldn't before and to try harder.

The issue is that ftrace allocates its ring buffer one page at a time.
Thus, when a RETRY_MAYFAIL succeeds, that memory is allocated. Since it
does it one page at a time, even if ftrace does not get all the memory
it needs at the end, it will take all memory from the system before it
finds that out. Then, if something else (like the above splat) tries to
allocate anything, it will fail and trigger an OOM.

> 
> >
> > I wonder if I should have the ring buffer allocate groups of pages, to
> > avoid this. Or try to allocate with NORETRY, one page at a time, and
> > when that fails, allocate groups of pages with RETRY_MAYFAIL, and that
> > may keep it from causing an OOM?
> >  
> 
> I don't see immediately how that can prevent an OOM in other
> applications here? If ftrace allocates lots of memory with
> RETRY_MAYFAIL, then we would still OOM in other applications if memory
> isn't available. Sorry if I missed something.

Here's the idea.

Allocate one page at a time with NORETRY. If that fails, then allocate
larger amounts (higher order of pages) with RETRY_MAYFAIL. Then if it
can't get all the memory it needs, it wont take up all memory in the
system before it finds out that it can't have any more.

Or perhaps the memory management system can provide a
get_available_mem() function that ftrace could call before it tries to
increase the ring buffer and take up all the memory of the system
before it realizes that it can't get all the memory it wants.

The main problem I have with Zhaoyang's patch is that
get_available_mem() does not belong in the tracing code. It should be
something that the mm subsystem provides.

-- Steve
