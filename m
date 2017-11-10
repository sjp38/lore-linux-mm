Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4672728028E
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 07:26:40 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b6so7531440pff.18
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:26:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si8918633plb.719.2017.11.10.04.26.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Nov 2017 04:26:39 -0800 (PST)
Date: Fri, 10 Nov 2017 13:26:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Fri 10-11-17 11:15:29, Michal Hocko wrote:
> On Fri 10-11-17 09:19:33, Minchan Kim wrote:
> > On Tue, Nov 07, 2017 at 09:54:53AM +0000, Wang Nan wrote:
> > > tlb_gather_mmu(&tlb, mm, 0, -1) means gathering the whole virtual memory
> > > space. In this case, tlb->fullmm is true. Some archs like arm64 doesn't
> > > flush TLB when tlb->fullmm is true:
> > > 
> > >   commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
> > > 
> > > Which makes leaking of tlb entries.
> > 
> > That means soft-dirty which has used tlb_gather_mmu with fullmm could be
> > broken via losing write-protection bit once it supports arm64 in future?
> > 
> > If so, it would be better to use TASK_SIZE rather than -1 in tlb_gather_mmu.
> > Of course, it's a off-topic.
> 
> I wouldn't play tricks like that. And maybe the API itself could be more
> explicit. E.g. add a lazy parameter which would allow arch specific code
> to not flush if it is sure that nobody can actually stumble over missed
> flush. E.g. the following?

This one has a changelog and even compiles on my crosscompile test
---
