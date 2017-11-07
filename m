Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 859516B0033
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 19:54:29 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id i19so1409549ote.7
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 16:54:29 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a35si7401otb.173.2017.11.06.16.54.28
        for <linux-mm@kvack.org>;
        Mon, 06 Nov 2017 16:54:28 -0800 (PST)
Date: Tue, 7 Nov 2017 00:54:32 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH] mm, oom_reaper: gather each vma to prevent leaking
 TLB entry
Message-ID: <20171107005432.GB12761@arm.com>
References: <20171106033651.172368-1-wangnan0@huawei.com>
 <CAA_GA1dZebSLTEX2W85svWW6O_9RqXDnD7oFW+tMqg+HX5XbPA@mail.gmail.com>
 <20171106085251.jwrpgne4dnl4gopy@dhcp22.suse.cz>
 <20171106122726.jwe2ecymlu7qclkk@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106122726.jwe2ecymlu7qclkk@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Bob Liu <lliubbo@gmail.com>, Wang Nan <wangnan0@huawei.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, Nov 06, 2017 at 01:27:26PM +0100, Michal Hocko wrote:
> On Mon 06-11-17 09:52:51, Michal Hocko wrote:
> > On Mon 06-11-17 15:04:40, Bob Liu wrote:
> > > On Mon, Nov 6, 2017 at 11:36 AM, Wang Nan <wangnan0@huawei.com> wrote:
> > > > tlb_gather_mmu(&tlb, mm, 0, -1) means gathering all virtual memory space.
> > > > In this case, tlb->fullmm is true. Some archs like arm64 doesn't flush
> > > > TLB when tlb->fullmm is true:
> > > >
> > > >   commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
> > > >
> > > 
> > > CC'ed Will Deacon.
> > > 
> > > > Which makes leaking of tlb entries. For example, when oom_reaper
> > > > selects a task and reaps its virtual memory space, another thread
> > > > in this task group may still running on another core and access
> > > > these already freed memory through tlb entries.
> > 
> > No threads should be running in userspace by the time the reaper gets to
> > unmap their address space. So the only potential case is they are
> > accessing the user memory from the kernel when we should fault and we
> > have MMF_UNSTABLE to cause a SIGBUS.
> 
> I hope we have clarified that the tasks are not running in userspace at
> the time of reaping. I am still wondering whether this is real from the
> kernel space via copy_{from,to}_user. Is it possible we won't fault?
> I am not sure I understand what "Given that the ASID allocator will
> never re-allocate a dirty ASID" means exactly. Will, could you clarify
> please?

Sure. Basically, we tag each address space with an ASID (PCID on x86) which
is resident in the TLB. This means we can elide TLB invalidation when
pulling down a full mm because we won't ever assign that ASID to another mm
without doing TLB invalidation elsewhere (which actually just nukes the
whole TLB).

I think that means that we could potentially not fault on a kernel uaccess,
because we could hit in the TLB. Perhaps a fix would be to set the force
variable in tlb_finish_mmu if MMF_UNSTABLE is set on the mm?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
