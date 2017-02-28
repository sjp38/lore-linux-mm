Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7AB6B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:15:55 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id f84so22754842ioj.6
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:15:55 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id w197si3040134iod.1.2017.02.28.10.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 10:15:54 -0800 (PST)
Date: Tue, 28 Feb 2017 19:15:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228181547.GM5680@worktop>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> +	/*
> +	 * Each work of workqueue might run in a different context,
> +	 * thanks to concurrency support of workqueue. So we have to
> +	 * distinguish each work to avoid false positive.
> +	 *
> +	 * TODO: We can also add dependencies between two acquisitions
> +	 * of different work_id, if they don't cause a sleep so make
> +	 * the worker stalled.
> +	 */
> +	unsigned int		work_id;

> +/*
> + * Crossrelease needs to distinguish each work of workqueues.
> + * Caller is supposed to be a worker.
> + */
> +void crossrelease_work_start(void)
> +{
> +	if (current->xhlocks)
> +		current->work_id++;
> +}

So what you're trying to do with that 'work_id' thing is basically wipe
the entire history when we're at the bottom of a context.

Which is a useful operation, but should arguably also be done on the
return to userspace path. Any historical lock from before the current
syscall is irrelevant.

(And we should not be returning to userspace with locks held anyway --
lockdep already has a check for that).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
