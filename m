Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFFD6B028A
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 14:38:22 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id l8so50667685iti.6
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 11:38:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id y7si5459201pae.141.2016.11.10.11.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 11:38:21 -0800 (PST)
Date: Thu, 10 Nov 2016 20:38:22 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH/RFC] z3fold: use per-page read/write lock
Message-ID: <20161110193822.GK3175@twins.programming.kicks-ass.net>
References: <20161105144946.3b4be0ee799ae61a82e1d918@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161105144946.3b4be0ee799ae61a82e1d918@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Sat, Nov 05, 2016 at 02:49:46PM +0100, Vitaly Wool wrote:
> +/* Read-lock a z3fold page */
> +static void z3fold_page_rlock(struct z3fold_header *zhdr)
> +{
> +	while (!atomic_add_unless(&zhdr->page_lock, 1, Z3FOLD_PAGE_WRITE_FLAG))
> +		cpu_relax();
> +	smp_mb();
> +}
> +
> +/* Read-unlock a z3fold page */
> +static void z3fold_page_runlock(struct z3fold_header *zhdr)
> +{
> +	atomic_dec(&zhdr->page_lock);
> +	smp_mb();
> +}
> +
> +/* Write-lock a z3fold page */
> +static void z3fold_page_wlock(struct z3fold_header *zhdr)
> +{
> +	while (atomic_cmpxchg(&zhdr->page_lock, 0, Z3FOLD_PAGE_WRITE_FLAG) != 0)
> +		cpu_relax();
> +	smp_mb();
> +}
> +
> +/* Write-unlock a z3fold page */
> +static void z3fold_page_wunlock(struct z3fold_header *zhdr)
> +{
> +	atomic_sub(Z3FOLD_PAGE_WRITE_FLAG, &zhdr->page_lock);
> +	smp_mb();
> +}

This is trivially broken. What Andi said, don't roll your own locks.


The unlocks want: smp_mb__before_atomic() _before_ the atomic for
'obvious' reasons.

Also, this lock has serious starvation issues and is reader biased.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
