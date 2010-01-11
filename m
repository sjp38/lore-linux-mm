Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9B6CA6B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 18:29:48 -0500 (EST)
Date: Mon, 11 Jan 2010 23:29:37 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH -mmotm-2010-01-06-14-34] Fix fault count of task in GUP
In-Reply-To: <20100111114224.bbf0fc62.minchan.kim@barrios-desktop>
Message-ID: <alpine.LSU.2.00.1001112320490.7893@sister.anvils>
References: <20100111114224.bbf0fc62.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010, Minchan Kim wrote:
> 
> get_user_pages calls handle_mm_fault to pin the arguemented
> task's page. handle_mm_fault cause major or minor fault and
> get_user_pages counts it into task which is passed by argument.
> 
> But the fault happens in current task's context.
> So we have to count it not argumented task's context but current
> task's one.

Have to?

current simulates a fault into tsk's address space.
It is not a fault into current's address space.

I can see that this could be argued either way, or even
that such a "fault" should not be counted at all; but I do not
see a reason to change the way we have been counting it for years.

Sorry, but NAK (to this and to the v2) -
unless you have a stronger argument.

Hugh

> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> CC: Nick Piggin <npiggin@suse.de>
> CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>  mm/memory.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 521abf6..2513581 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1486,9 +1486,9 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  					BUG();
>  				}
>  				if (ret & VM_FAULT_MAJOR)
> -					tsk->maj_flt++;
> +					current->maj_flt++;
>  				else
> -					tsk->min_flt++;
> +					current->min_flt++;
>  
>  				/*
>  				 * The VM_FAULT_WRITE bit tells us that
> -- 
> 1.5.6.3
> 
> 
> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
