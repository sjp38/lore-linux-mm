Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 533356B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 09:33:49 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id uo6so420806220pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:33:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q24si40014287pfi.113.2016.01.18.06.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 06:33:48 -0800 (PST)
Date: Mon, 18 Jan 2016 15:33:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] sched/numa: Fix use-after-free bug in the
 task_numa_compare
Message-ID: <20160118143345.GQ6357@twins.programming.kicks-ass.net>
References: <1453125548-2762-1-git-send-email-gavin.guo@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453125548-2762-1-git-send-email-gavin.guo@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gavin.guo@canonical.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jay.vosburgh@canonical.com, liang.chen@canonical.com, mgorman@suse.de, mingo@redhat.com, riel@redhat.com

On Mon, Jan 18, 2016 at 09:59:08PM +0800, gavin.guo@canonical.com wrote:
> BugLink: https://bugs.launchpad.net/bugs/1527643

These do not go in patches..

>  	/*
> +	 * No need to move the exiting task or idle task.
>  	 */
>  	if ((cur->flags & PF_EXITING) || is_idle_task(cur))
>  		cur = NULL;
> +	else
> +		/*
> +		 * The task_struct must be protected here to protect the
> +		 * p->numa_faults access in the task_weight since the
> +		 * numa_faults could already be freed in the following path:
> +		 * finish_task_switch()
> +		 *     --> put_task_struct()
> +		 *         --> __put_task_struct()
> +		 *             --> task_numa_free()
> +		 */
> +		get_task_struct(cur);
> +

This is incorrect CodingStyle, please add { }.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
