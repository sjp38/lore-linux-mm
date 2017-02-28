Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE4A6B03AA
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 08:10:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n89so13983114pfa.7
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:10:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u5si1744246pgb.137.2017.02.28.05.10.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 05:10:20 -0800 (PST)
Date: Tue, 28 Feb 2017 14:10:12 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228131012.GI5680@worktop>
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

> +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> +
> +#define idx(t)			((t)->xhlock_idx)
> +#define idx_prev(i)		((i) ? (i) - 1 : MAX_XHLOCKS_NR - 1)
> +#define idx_next(i)		(((i) + 1) % MAX_XHLOCKS_NR)

Note that:

#define idx_prev(i)		(((i) - 1) % MAX_XHLOCKS_NR)
#define idx_next(i)		(((i) + 1) % MAX_XHLOCKS_NR)

is more symmetric and easier to understand.

> +
> +/* For easy access to xhlock */
> +#define xhlock(t, i)		((t)->xhlocks + (i))
> +#define xhlock_prev(t, l)	xhlock(t, idx_prev((l) - (t)->xhlocks))
> +#define xhlock_curr(t)		xhlock(t, idx(t))

So these result in an xhlock pointer

> +#define xhlock_incr(t)		({idx(t) = idx_next(idx(t));})

This does not; which is confusing seeing how they share the same
namespace; also incr is weird.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
