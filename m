Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 819626B02FD
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:30:55 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h70so43969202ioi.14
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:30:55 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q136si915841ioe.257.2017.08.11.06.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 06:30:54 -0700 (PDT)
Date: Fri, 11 Aug 2017 15:30:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 6/7] mm: fix MADV_[FREE|DONTNEED] TLB flush miss
 problem
Message-ID: <20170811133020.zozuuhbw72lzolj5@hirez.programming.kicks-ass.net>
References: <20170802000818.4760-1-namit@vmware.com>
 <20170802000818.4760-7-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802000818.4760-7-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org

On Tue, Aug 01, 2017 at 05:08:17PM -0700, Nadav Amit wrote:
>  void tlb_finish_mmu(struct mmu_gather *tlb,
>  		unsigned long start, unsigned long end)
>  {
> -	arch_tlb_finish_mmu(tlb, start, end);
> +	/*
> +	 * If there are parallel threads are doing PTE changes on same range
> +	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> +	 * flush by batching, a thread has stable TLB entry can fail to flush
> +	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> +	 * forcefully if we detect parallel PTE batching threads.
> +	 */
> +	bool force = mm_tlb_flush_nested(tlb->mm);
> +
> +	arch_tlb_finish_mmu(tlb, start, end, force);
>  }

I don't understand the comment nor the ordering. What guarantees we see
the increment if we need to?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
