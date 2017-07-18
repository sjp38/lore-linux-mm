Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F06126B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 21:26:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u17so6842815pfa.6
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:26:46 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f8si568863plm.346.2017.07.17.18.26.45
        for <linux-mm@kvack.org>;
        Mon, 17 Jul 2017 18:26:45 -0700 (PDT)
Date: Tue, 18 Jul 2017 10:25:55 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170718012554.GL20323@X58A-UD3R>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop>
 <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R>
 <20170713081442.GA439@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170713081442.GA439@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Jul 13, 2017 at 10:14:42AM +0200, Peter Zijlstra wrote:
> +static void __crossrelease_end(unsigned int *stamp)
> +{

[snip]

> +
> +	/*
> +	 * If we rewind past the tail; all of history is lost.
> +	 */
> +	if ((current->xhlock_idx_max - *stamp) < MAX_XHLOCKS_NR)
> +		return;
> +
> +	/*
> +	 * Invalidate the entire history..
> +	 */
> +	for (i = 0; i < MAX_XHLOCKS_NR; i++)
> +		invalidate_xhlock(&xhlock(i));
> +
> +	current->xhlock_idx = 0;
> +	current->xhlock_idx_hard = 0;
> +	current->xhlock_idx_soft = 0;
> +	current->xhlock_idx_hist = 0;
> +	current->xhlock_idx_max = 0;

I don't understand why you introduced this code, yet. Do we need this?

The other of your suggestion looks very good though..

> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
