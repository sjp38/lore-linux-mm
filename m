Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E764D6B026E
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 04:29:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b189so838616wmd.9
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 01:29:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10si303025edf.238.2017.11.03.01.29.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 01:29:01 -0700 (PDT)
Date: Fri, 3 Nov 2017 09:29:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use in_atomic() in print_vma_addr()
Message-ID: <20171103082900.463jh6474vf63lvt@dhcp22.suse.cz>
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
 <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
 <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 03-11-17 01:44:44, Yang Shi wrote:
> 
> 
> On 11/2/17 12:57 AM, Michal Hocko wrote:
> > On Thu 02-11-17 05:38:33, Yang Shi wrote:
> > > commit 3e51f3c4004c9b01f66da03214a3e206f5ed627b
> > > ("sched/preempt: Remove PREEMPT_ACTIVE unmasking off in_atomic()") makes
> > > in_atomic() just check the preempt count, so it is not necessary to use
> > > preempt_count() in print_vma_addr() any more. Replace preempt_count() to
> > > in_atomic() which is a generic API for checking atomic context.
> > 
> > But why? Is there some general work to get rid of the direct preempt_count
> > usage outside of the generic API?
> 
> I may not articulate it in the commit log, I would say "in_atomic" is
> *preferred* API for checking atomic context instead of preempt_count() which
> should be used for retrieving the preemption count value.
> 
> I would say there is not such general elimination work undergoing right now,
> but if we go through the kernel code, almost everywhere "in_atomic" is used
> for such use case already, except two places:
> 
> - print_vma_addr()
> - debug_smp_processor_id()
> 
> Both came from Ingo long time ago before commit
> 3e51f3c4004c9b01f66da03214a3e206f5ed627b ("sched/preempt: Remove
> PREEMPT_ACTIVE unmasking off in_atomic()"). But, after this commit was
> merged, I don't see why *not* use in_atomic() to follow the convention.

OK.

Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks,
> Yang
> 
> > 
> > > Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> > > ---
> > >   mm/memory.c | 2 +-
> > >   1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index a728bed..19b684e 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -4460,7 +4460,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
> > >   	 * Do not print if we are in atomic
> > >   	 * contexts (in exception stacks, etc.):
> > >   	 */
> > > -	if (preempt_count())
> > > +	if (in_atomic())
> > >   		return;
> > >   	down_read(&mm->mmap_sem);
> > > -- 
> > > 1.8.3.1
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
