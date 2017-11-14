Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F49C6B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 20:46:07 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p2so16430196pfk.13
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 17:46:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r195sor4667931pgr.100.2017.11.13.17.46.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Nov 2017 17:46:05 -0800 (PST)
Date: Tue, 14 Nov 2017 10:45:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171114014549.GA1995@bgram>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
 <20171113002833.GA18301@bbox>
 <20171113095107.24hstywywxk7nx7e@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171113095107.24hstywywxk7nx7e@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, Nov 13, 2017 at 10:51:07AM +0100, Michal Hocko wrote:
> On Mon 13-11-17 09:28:33, Minchan Kim wrote:
> [...]
> > Thanks for the patch, Michal.
> > However, it would be nice to do it tranparently without asking
> > new flags from users.
> > 
> > When I read tlb_gather_mmu's description, fullmm is supposed to
> > be used only if there is no users and full address space.
> > 
> > That means we can do it API itself like this?
> > 
> > void arch_tlb_gather_mmu(...)
> > 
> >         tlb->fullmm = !(start | (end + 1)) && atomic_read(&mm->mm_users) == 0;
> 
> I do not have a strong opinion here. The optimization is quite subtle so
> calling it explicitly sounds like a less surprising behavior to me
> longterm. Note that I haven't checked all fullmm users.

With description of tlb_gather_mmu and 4d6ddfa9242b, set fullmm to true
should guarantees there is *no users* of the mm_struct so I think
my suggestion is not about optimization but to keep the semantic
"there should be no one who can access address space when entire
address space is destroyed".

If you want to be more explicit, we should add some description
about "where can we use lazy mode". I think it should tell the
internal of some architecture for user to understand. I'm not
sure it's worth although we can do it transparently.

I'm not strong against with you approach, either.

Anyway, I think Wang Nan's patch is already broken.
http://lkml.kernel.org/r/%3C20171107095453.179940-1-wangnan0@huawei.com%3E

Because unmap_page_range(ie, zap_pte_range) can flush TLB forcefully
and free pages. However, the architecture code for TLB flush cannot
flush at all by wrong fullmm so other threads can write freed-page.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
