Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 057106B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 11:24:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b85so11474232pfj.22
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 08:24:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e33si4205182pld.533.2017.11.06.08.24.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 08:24:24 -0800 (PST)
Date: Mon, 6 Nov 2017 17:24:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: do not rely on preempt_count in print_vma_addr
Message-ID: <20171106162420.lrt2n524fwn6u4ev@dhcp22.suse.cz>
References: <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
 <20171103110245.7049460a05cc18c7e8a9feb2@linux-foundation.org>
 <1509739786.2473.33.camel@wdc.com>
 <20171105081946.yr2pvalbegxygcky@dhcp22.suse.cz>
 <20171106100558.GD3165@worktop.lehotels.local>
 <20171106104354.2jlgd2m4j4gxx4qo@dhcp22.suse.cz>
 <20171106120025.GH3165@worktop.lehotels.local>
 <20171106121222.nnzrr4cb7s7y5h74@dhcp22.suse.cz>
 <20171106134031.g6dbelg55mrbyc6i@dhcp22.suse.cz>
 <8665ccad-fa48-b835-c2e0-e50a4f05f319@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8665ccad-fa48-b835-c2e0-e50a4f05f319@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Bart Van Assche <Bart.VanAssche@wdc.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "joe@perches.com" <joe@perches.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@redhat.com" <mingo@redhat.com>

On Tue 07-11-17 00:16:58, Yang Shi wrote:
> 
> 
> On 11/6/17 5:40 AM, Michal Hocko wrote:
> > On Mon 06-11-17 13:12:22, Michal Hocko wrote:
> > > On Mon 06-11-17 13:00:25, Peter Zijlstra wrote:
> > > > On Mon, Nov 06, 2017 at 11:43:54AM +0100, Michal Hocko wrote:
> > > > > > Yes the comment is very much accurate.
> > > > > 
> > > > > Which suggests that print_vma_addr might be problematic, right?
> > > > > Shouldn't we do trylock on mmap_sem instead?
> > > > 
> > > > Yes that's complete rubbish. trylock will get spurious failures to print
> > > > when the lock is contended.
> > > 
> > > Yes, but I guess that it is acceptable to to not print the state under
> > > that condition.
> > 
> > So what do you think about this? I think this is more robust than
> > playing tricks with the explicit preempt count checks and less tedious
> > than checking to make it conditional on the context. This is on top of
> > Linus tree and if accepted it should replace the patch discussed here.
> > ---
> >  From 0de6d57cbc54ee2686d1f1e4ffcc4ed490ded8aa Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Mon, 6 Nov 2017 14:31:20 +0100
> > Subject: [PATCH] mm: do not rely on preempt_count in print_vma_addr
> > 
> > The preempt count check on print_vma_addr has been added by e8bff74afbdb
> > ("x86: fix "BUG: sleeping function called from invalid context" in
> > print_vma_addr()") and it relied on the elevated preempt count from
> > preempt_conditional_sti because preempt_count check doesn't work on
> > non preemptive kernels by default. The code has evolved though and
> > d99e1bd175f4 ("x86/entry/traps: Refactor preemption and interrupt flag
> > handling") has replaced preempt_conditional_sti by an explicit
> > preempt_disable which is noop on !PREEMPT so the check in print_vma_addr
> > is broken.
> > 
> > Fix the issue by using trylock on mmap_sem rather than chacking the
> 
> s/chacking/checking

ups, fixed

> > preempt count. The allocation we are relying on has to be GFP_NOWAIT
> > as well. There is a chance that we won't dump the vma state if the lock
> > is contended or the memory short but this is acceptable outcome and much
> > less fragile than the not working preemption check or tricks around it.
> > 
> > Fixes: d99e1bd175f4 ("x86/entry/traps: Refactor preemption and interrupt flag handling")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Yang Shi <yang.s@alibaba-inc.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
