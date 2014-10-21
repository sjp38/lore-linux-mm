Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 461DF6B0069
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 15:00:27 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id hi2so11865070wib.1
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 12:00:26 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id u8si13873863wiy.64.2014.10.21.12.00.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 12:00:24 -0700 (PDT)
Date: Tue, 21 Oct 2014 21:00:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 5/6] mm: Provide speculative fault infrastructure
Message-ID: <20141021190019.GJ3219@twins.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.490529442@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141020222841.490529442@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 20, 2014 at 11:56:38PM +0200, Peter Zijlstra wrote:
>  static bool pte_map_lock(struct fault_env *fe)
>  {
> +	bool ret = false;
> +
> +	if (!(fe->flags & FAULT_FLAG_SPECULATIVE)) {
> +		fe->pte = pte_offset_map_lock(fe->mm, fe->pmd, fe->address, &fe->ptl);
> +		return true;
> +	}
> +
> +	/*
> +	 * The first vma_is_dead() guarantees the page-tables are still valid,
> +	 * having IRQs disabled ensures they stay around, hence the second
> +	 * vma_is_dead() to make sure they are still valid once we've got the
> +	 * lock. After that a concurrent zap_pte_range() will block on the PTL
> +	 * and thus we're safe.
> +	 */
> +	local_irq_disable();
> +	if (vma_is_dead(fe->vma, fe->sequence))
> +		goto out;
> +
>  	fe->pte = pte_offset_map_lock(fe->mm, fe->pmd, fe->address, &fe->ptl);

Yeah, so this deadlocks just fine, I found we still do TLB flushes while
holding the PTL. Bugger that, the alternative is either force everybody
to do RCU freed page-tables or put back the ugly code :/

A well..

> +
> +	if (vma_is_dead(fe->vma, fe->sequence)) {
> +		pte_unmap_unlock(fe->pte, fe->ptl);
> +		goto out;
> +	}
> +
> +	ret = true;
> +out:
> +	local_irq_enable();
> +	return ret;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
