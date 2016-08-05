Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 685B0828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:34:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so93203223pab.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:34:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id tu4si20568911pac.261.2016.08.05.06.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 06:53:12 -0700 (PDT)
Date: Fri, 5 Aug 2016 15:53:08 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86/mm: disable preemption during CR3 read+write
Message-ID: <20160805135308.GT6879@twins.programming.kicks-ass.net>
References: <1470404259-26290-1-git-send-email-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470404259-26290-1-git-send-email-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

On Fri, Aug 05, 2016 at 03:37:39PM +0200, Sebastian Andrzej Siewior wrote:
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 4e5be94e079a..1ee065954e24 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -135,7 +135,14 @@ static inline void cr4_set_bits_and_update_boot(unsigned long mask)
>  
>  static inline void __native_flush_tlb(void)
>  {
> +	/*
> +	 * if current->mm == NULL then we borrow a mm which may change during a
> +	 * task switch and therefore we must not be preempted while we write CR3
> +	 * back.
> +	 */
> +	preempt_disable();
>  	native_write_cr3(native_read_cr3());
> +	preempt_enable();
>  }

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
