Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4DD6B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 03:04:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 49so17788023wrw.12
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 00:04:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j185si686473wma.84.2017.08.18.00.04.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Aug 2017 00:04:47 -0700 (PDT)
Date: Fri, 18 Aug 2017 09:04:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: +
 mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently.patch added to
 -mm tree
Message-ID: <20170818070444.GA9004@dhcp22.suse.cz>
References: <59936823.CQNWQErWJ8EAIG3q%akpm@linux-foundation.org>
 <20170816132329.GA32169@dhcp22.suse.cz>
 <20170817171240.GB5066@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170817171240.GB5066@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, hughd@google.com, kirill@shutemov.name, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu 17-08-17 19:12:40, Andrea Arcangeli wrote:
> On Wed, Aug 16, 2017 at 03:23:29PM +0200, Michal Hocko wrote:
> > Reviewed-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks for the review!
> 
> There's this further possible microoptimization that can be folded on top.
> 
> >From 76bf017f923581d15fe01249af92b0d757752a9f Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Thu, 17 Aug 2017 18:39:46 +0200
> Subject: [PATCH 1/1] mm: oom: let oom_reap_task and exit_mmap run
>  concurrently, add unlikely
> 
> Microoptimization to fold before merging.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 013170e5c8a4..ab0026a8acc4 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3003,7 +3003,7 @@ void exit_mmap(struct mm_struct *mm)
>  	unmap_vmas(&tlb, vma, 0, -1);
>  
>  	set_bit(MMF_OOM_SKIP, &mm->flags);
> -	if (tsk_is_oom_victim(current)) {
> +	if (unlikely(tsk_is_oom_victim(current))) {

I dunno. This doesn't make any difference in the generated code for
me (with gcc 6.4). If anything we might wan't to putt unlikely inside
tsk_is_oom_victim. Or even go further and use a jump label to get any
conditional paths out of way.

>  		/*
>  		 * Wait for oom_reap_task() to stop working on this
>  		 * mm. Because MMF_OOM_SKIP is already set before
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
