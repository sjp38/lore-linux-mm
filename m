Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 253376B00B8
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 17:03:41 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p03M3ZMM001023
	for <linux-mm@kvack.org>; Mon, 3 Jan 2011 14:03:38 -0800
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by kpbe13.cbf.corp.google.com with ESMTP id p03M3YL6022302
	for <linux-mm@kvack.org>; Mon, 3 Jan 2011 14:03:34 -0800
Received: by pwj10 with SMTP id 10so1781695pwj.16
        for <linux-mm@kvack.org>; Mon, 03 Jan 2011 14:03:34 -0800 (PST)
Date: Mon, 3 Jan 2011 14:03:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] writeback: avoid unnecessary determine_dirtyable_memory
 call
In-Reply-To: <1294072249-2916-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <alpine.DEB.2.00.1101031400550.10636@chino.kir.corp.google.com>
References: <1294072249-2916-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, 4 Jan 2011, Minchan Kim wrote:

> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index fc93802..c340536 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -390,9 +390,12 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>  {
>  	unsigned long background;
>  	unsigned long dirty;
> -	unsigned long available_memory = determine_dirtyable_memory();
> +	unsigned long available_memory;

You need unsigned long uninitialized_var(available_memory) to avoid the 
warning.

>  	struct task_struct *tsk;
>  
> +	if (!vm_dirty_bytes || !dirty_background_bytes)
> +		available_memory = determine_dirtyable_memory();
> +
>  	if (vm_dirty_bytes)
>  		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
>  	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
