Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 50C0B6B0082
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:01:17 -0400 (EDT)
Date: Tue, 23 Jun 2009 21:00:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: don't rely on flags coincidence
Message-ID: <20090623130058.GB18603@localhost>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain> <Pine.LNX.4.64.0906231349250.19552@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906231349250.19552@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 23, 2009 at 08:52:49PM +0800, Hugh Dickins wrote:
> Indeed FOLL_WRITE matches FAULT_FLAG_WRITE, matches GUP_FLAGS_WRITE,
> and it's tempting to devise a set of Grand Unified Paging flags;
> but not today.  So until then, let's rely upon the compiler to spot
> the coincidence, "rather than have that subtle dependency and a
> comment for it" - as you remarked in another context yesterday.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

> ---
> 
>  mm/memory.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> --- 2.6.30-git20/mm/memory.c	2009-06-23 11:06:25.000000000 +0100
> +++ linux/mm/memory.c	2009-06-23 13:07:57.000000000 +0100
> @@ -1311,8 +1311,10 @@ int __get_user_pages(struct task_struct
>  			while (!(page = follow_page(vma, start, foll_flags))) {
>  				int ret;
>  
> -				/* FOLL_WRITE matches FAULT_FLAG_WRITE! */
> -				ret = handle_mm_fault(mm, vma, start, foll_flags & FOLL_WRITE);
> +				ret = handle_mm_fault(mm, vma, start,
> +					(foll_flags & FOLL_WRITE) ?
> +					FAULT_FLAG_WRITE : 0);
> +
>  				if (ret & VM_FAULT_ERROR) {
>  					if (ret & VM_FAULT_OOM)
>  						return i ? i : -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
