Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8DE06B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 10:13:21 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m98so143821585iod.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:13:21 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id t3si2169376ioe.59.2017.01.16.07.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 07:13:21 -0800 (PST)
Date: Mon, 16 Jan 2017 16:13:19 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Message-ID: <20170116151319.GE3144@twins.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-8-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481260331-360-8-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Fri, Dec 09, 2016 at 02:12:03PM +0900, Byungchul Park wrote:
> +	/*
> +	 * We assign class_idx here redundantly even though following
> +	 * memcpy will cover it, in order to ensure a rcu reader can
> +	 * access the class_idx atomically without lock.
> +	 *
> +	 * Here we assume setting a word-sized variable is atomic.

which one, where?

> +	 */
> +	xlock->hlock.class_idx = hlock->class_idx;
> +	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
> +	WRITE_ONCE(xlock->gen_id, gen_id);
> +	memcpy(&xlock->hlock, hlock, sizeof(struct held_lock));
> +	INIT_LIST_HEAD(&xlock->xlock_entry);
> +	list_add_tail_rcu(&xlock->xlock_entry, &xlocks_head);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
