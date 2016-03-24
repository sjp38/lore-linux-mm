Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E7F826B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 17:17:16 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id tt10so31560098pab.3
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 14:17:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n62si14550376pfi.139.2016.03.24.14.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Mar 2016 14:17:16 -0700 (PDT)
Date: Thu, 24 Mar 2016 14:17:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,writeback: Don't use memory reserves for
 wb_start_writeback
Message-Id: <20160324141714.aa9ccff6d5df5d2974eb86f8@linux-foundation.org>
In-Reply-To: <201603242303.CEJ65666.VOOFJLFQOMtFSH@I-love.SAKURA.ne.jp>
References: <201603242303.CEJ65666.VOOFJLFQOMtFSH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

On Thu, 24 Mar 2016 23:03:16 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:

> Andrew, can you take this patch?

Tejun.

> ----------------------------------------
> >From 5d43acbc5849a63494a732e39374692822145923 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 13 Mar 2016 23:03:05 +0900
> Subject: [PATCH] mm,writeback: Don't use memory reserves for
>  wb_start_writeback
> 
> When writeback operation cannot make forward progress because memory
> allocation requests needed for doing I/O cannot be satisfied (e.g.
> under OOM-livelock situation), we can observe flood of order-0 page
> allocation failure messages caused by complete depletion of memory
> reserves.
> 
> This is caused by unconditionally allocating "struct wb_writeback_work"
> objects using GFP_ATOMIC from PF_MEMALLOC context.
> 
> __alloc_pages_nodemask() {
>   __alloc_pages_slowpath() {
>     __alloc_pages_direct_reclaim() {
>       __perform_reclaim() {
>         current->flags |= PF_MEMALLOC;
>         try_to_free_pages() {
>           do_try_to_free_pages() {
>             wakeup_flusher_threads() {
>               wb_start_writeback() {
>                 kzalloc(sizeof(*work), GFP_ATOMIC) {
>                   /* ALLOC_NO_WATERMARKS via PF_MEMALLOC */
>                 }
>               }
>             }
>           }
>         }
>         current->flags &= ~PF_MEMALLOC;
>       }
>     }
>   }
> }
> 
> Since I/O is stalling, allocating writeback requests forever shall deplete
> memory reserves. Fortunately, since wb_start_writeback() can fall back to
> wb_wakeup() when allocating "struct wb_writeback_work" failed, we don't
> need to allow wb_start_writeback() to use memory reserves.
> 
> ...
>
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -929,7 +929,8 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  	 * This is WB_SYNC_NONE writeback, so if allocation fails just
>  	 * wakeup the thread for old dirty data writeback
>  	 */
> -	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> +	work = kzalloc(sizeof(*work),
> +		       GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
>  	if (!work) {
>  		trace_writeback_nowork(wb);
>  		wb_wakeup(wb);

Oh geeze.  fs/fs-writeback.c has grown waaay too many GFP_ATOMICs :(

How does this actually all work?  afaict if we fail this
wb_writeback_work allocation, wb_workfn->wb_do_writeback will later say
"hey, there are no work items!" and will do nothing at all.  Or does
wb_workfn() fall into write-1024-pages-anyway mode and if so, how did
it know how to do that?

If we had (say) a mempool of wb_writeback_work's (at least for for
wb_start_writeback), would that help anything?  Or would writeback
simply fail shortly afterwards for other reasons?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
