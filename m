Date: Thu, 5 Aug 2004 22:27:33 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 3/4: writeout watermarks
Message-Id: <20040805222733.477b3017.akpm@osdl.org>
In-Reply-To: <41131105.8040108@yahoo.com.au>
References: <41130FB1.5020001@yahoo.com.au>
	<41130FD2.5070608@yahoo.com.au>
	<41131105.8040108@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> 3rd attempt for this patch ;)
>  I have since addressed your concerns.
> 
>  So for example, with a 10/40 async/sync ratio, if the sync
>  watermark is moved down to 20, the async mark will be moved
>  to 5, preserving the ratio.

Disagree.

> 
> [vm-tune-writeout.patch  text/x-patch (1365 bytes)]
> 
>  Slightly change the writeout watermark calculations so we keep background
>  and synchronous writeout watermarks in the same ratios after adjusting them.
>  This ensures we should always attempt to start background writeout before
>  synchronous writeout.
> 
>  Signed-off-by: Nick Piggin <nickpiggin@cyberone.com.au>
> 
> 
>  ---
> 
>   linux-2.6-npiggin/mm/page-writeback.c |    8 +++++---
>   1 files changed, 5 insertions(+), 3 deletions(-)
> 
>  diff -puN mm/page-writeback.c~vm-tune-writeout mm/page-writeback.c
>  --- linux-2.6/mm/page-writeback.c~vm-tune-writeout	2004-08-06 14:48:45.000000000 +1000
>  +++ linux-2.6-npiggin/mm/page-writeback.c	2004-08-06 14:48:45.000000000 +1000
>  @@ -153,9 +153,11 @@ get_dirty_limits(struct writeback_state 
>   	if (dirty_ratio < 5)
>   		dirty_ratio = 5;
>   
>  -	background_ratio = dirty_background_ratio;
>  -	if (background_ratio >= dirty_ratio)
>  -		background_ratio = dirty_ratio / 2;
>  +	/*
>  +	 * Keep the ratio between dirty_ratio and background_ratio roughly
>  +	 * what the sysctls are after dirty_ratio has been scaled (above).
>  +	 */
>  +	background_ratio = dirty_background_ratio * dirty_ratio/vm_dirty_ratio;
>   
>   	background = (background_ratio * total_pages) / 100;
>   	dirty = (dirty_ratio * total_pages) / 100;

Look, these are sysadmin-settable sysctls.  The admin can set them to
whatever wild and whacky values he wants - it's his computer.

The only reason the check is there at all is because background_ratio >
dirty_ratio has never been even tested, and could explode, and I don't want
to have to test and support it.  Plus if the admin is in the process of
setting both tunables there might be a transient period of time when
they're in a bad state.

That's all!  Please, just pretend the code isn't there at all.  What the
admin sets, the admin gets, end of story.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
