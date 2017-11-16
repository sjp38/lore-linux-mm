Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4826928025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 04:19:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s18so4640942pge.19
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 01:19:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g71si597395pfd.400.2017.11.16.01.19.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 01:19:50 -0800 (PST)
Date: Thu, 16 Nov 2017 10:19:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171116091941.elzfpt72mgxofux4@dhcp22.suse.cz>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
 <20171113002833.GA18301@bbox>
 <20171115081452.bt7cpfombm4bzha4@dhcp22.suse.cz>
 <20171116004457.GA12222@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171116004457.GA12222@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Thu 16-11-17 09:44:57, Minchan Kim wrote:
> On Wed, Nov 15, 2017 at 09:14:52AM +0100, Michal Hocko wrote:
> > On Mon 13-11-17 09:28:33, Minchan Kim wrote:
> > [...]
> > > void arch_tlb_gather_mmu(...)
> > > 
> > >         tlb->fullmm = !(start | (end + 1)) && atomic_read(&mm->mm_users) == 0;
> > 
> > Sorry, I should have realized sooner but this will not work for the oom
> > reaper. It _can_ race with the final exit_mmap and run with mm_users == 0
> 
> If someone see mm_users is zero, it means there is no user to access
> address space by stale TLB. Am I missing something?

You are probably right but changing the flushing policy in the middle of
the address space tear down makes me nervous. While this might work
right now, it is kind of tricky and it has some potential to kick us
back in future. Just note how the current arm64 optimization went
unnoticed because the the oom reaper is such a rare event that nobody
has actually noticed this. And I suspect that the likelyhood of failure
is very low even when applied for anybody to notice in the real life.

So I would very much like to make the behavior really explicit for
everybody to see what is going on there.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
