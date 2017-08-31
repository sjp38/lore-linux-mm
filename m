Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D65146B02C3
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 13:34:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 63so1928916pgc.0
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 10:34:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c20sor210684pfk.6.2017.08.31.10.34.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Aug 2017 10:34:13 -0700 (PDT)
Date: Thu, 31 Aug 2017 10:34:10 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] mm, uprobes: fix multiple free of
 ->uprobes_state.xol_area
Message-ID: <20170831173410.GA5023@gmail.com>
References: <20170830033303.17927-1-ebiggers3@gmail.com>
 <20170830163714.GA24774@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830163714.GA24774@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Biggers <ebiggers@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

Hi Oleg,

On Wed, Aug 30, 2017 at 06:37:14PM +0200, Oleg Nesterov wrote:
> On 08/29, Eric Biggers wrote:
> >
> > --- a/kernel/events/uprobes.c
> > +++ b/kernel/events/uprobes.c
> > @@ -1262,8 +1262,6 @@ void uprobe_end_dup_mmap(void)
> >  
> >  void uprobe_dup_mmap(struct mm_struct *oldmm, struct mm_struct *newmm)
> >  {
> > -	newmm->uprobes_state.xol_area = NULL;
> > -
> >  	if (test_bit(MMF_HAS_UPROBES, &oldmm->flags)) {
> >  		set_bit(MMF_HAS_UPROBES, &newmm->flags);
> >  		/* unconditionally, dup_mmap() skips VM_DONTCOPY vmas */
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index cbbea277b3fb..b7e9e57b71ea 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -785,6 +785,13 @@ static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
> >  #endif
> >  }
> >  
> > +static void mm_init_uprobes_state(struct mm_struct *mm)
> > +{
> > +#ifdef CONFIG_UPROBES
> > +	mm->uprobes_state.xol_area = NULL;
> > +#endif
> > +}
> > +
> >  static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
> >  	struct user_namespace *user_ns)
> >  {
> > @@ -812,6 +819,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
> >  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> >  	mm->pmd_huge_pte = NULL;
> >  #endif
> > +	mm_init_uprobes_state(mm);
> 
> ACK, but I have cosmetic nit, this doesn't match other uprobe helpers.
> 
> I'd suggest to add uprobe_init_state() into kernel/events/uprobes.c and
> the dummy !CONFIG_UPROBES version into include/linux/uprobes.h.
> 
> Not that I think this will be more clean, personally I would simply add a
> ifdef(CONFIG_UPROBES) line into mm_init(), but this will be more consistent.
> 
> Oleg.
> 

I was going to do that originally, but I didn't like that it wouldn't be inlined
despite being just a single pointer assignment.  And mm_init_uprobes_state() is
at least consistent with the other mm_init_*() helpers in kernel/fork.c.  I
don't feel too strongly though, and it's true that nothing outside of uprobes.h
and uprobes.c references xol_area currently, so maybe it would be clearer to
have it there.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
