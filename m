Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 454576B026D
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 05:40:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k7so12332473pga.8
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 02:40:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si12018807pfh.332.2017.11.06.02.40.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 02:40:11 -0800 (PST)
Date: Mon, 6 Nov 2017 11:40:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom_reaper: gather each vma to prevent leaking
 TLB entry
Message-ID: <20171106104008.yqjqsfolsnaotarr@dhcp22.suse.cz>
References: <20171106033651.172368-1-wangnan0@huawei.com>
 <CAA_GA1dZebSLTEX2W85svWW6O_9RqXDnD7oFW+tMqg+HX5XbPA@mail.gmail.com>
 <20171106085251.jwrpgne4dnl4gopy@dhcp22.suse.cz>
 <0cf84560-c64a-0737-e654-162928872d5b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0cf84560-c64a-0737-e654-162928872d5b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wangnan (F)" <wangnan0@huawei.com>
Cc: Bob Liu <lliubbo@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, will.deacon@arm.com

On Mon 06-11-17 17:59:54, Wangnan (F) wrote:
> 
> 
> On 2017/11/6 16:52, Michal Hocko wrote:
> > On Mon 06-11-17 15:04:40, Bob Liu wrote:
> > > On Mon, Nov 6, 2017 at 11:36 AM, Wang Nan <wangnan0@huawei.com> wrote:
> > > > tlb_gather_mmu(&tlb, mm, 0, -1) means gathering all virtual memory space.
> > > > In this case, tlb->fullmm is true. Some archs like arm64 doesn't flush
> > > > TLB when tlb->fullmm is true:
> > > > 
> > > >    commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
> > > > 
> > > CC'ed Will Deacon.
> > > 
> > > > Which makes leaking of tlb entries. For example, when oom_reaper
> > > > selects a task and reaps its virtual memory space, another thread
> > > > in this task group may still running on another core and access
> > > > these already freed memory through tlb entries.
> > No threads should be running in userspace by the time the reaper gets to
> > unmap their address space. So the only potential case is they are
> > accessing the user memory from the kernel when we should fault and we
> > have MMF_UNSTABLE to cause a SIGBUS. So is the race you are describing
> > real?
> > 
> > > > This patch gather each vma instead of gathering full vm space,
> > > > tlb->fullmm is not true. The behavior of oom reaper become similar
> > > > to munmapping before do_exit, which should be safe for all archs.
> > I do not have any objections to do per vma tlb flushing because it would
> > free gathered pages sooner but I am not sure I see any real problem
> > here. Have you seen any real issues or this is more of a review driven
> > fix?
> 
> We saw the problem when we try to reuse oom reaper's code in
> another situation. In our situation, we allow reaping a task
> before all other tasks in its task group finish their exiting
> procedure.
> 
> I'd like to know what ensures "No threads should be running in
> userspace by the time the reaper"?

All tasks are killed by the time. So they should be taken out to the
kernel.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
