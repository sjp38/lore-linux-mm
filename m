Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2548383200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 15:07:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j5so75626410pfb.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 12:07:14 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id 1si4199617pgt.65.2017.03.08.12.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 12:07:13 -0800 (PST)
Date: Wed, 8 Mar 2017 15:07:08 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC][PATCH 4/4] ftrace: Allow for function tracing to record
 init functions on boot up
Message-ID: <20170308150708.3df9bf15@gandalf.local.home>
In-Reply-To: <20170307212943.573855971@goodmis.org>
References: <20170307212833.964734229@goodmis.org>
	<20170307212943.573855971@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Todd Brandt <todd.e.brandt@linux.intel.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>


Dear mm folks,

Are you OK with this change? I need a hook to when the init sections
are being freed along with the address that are being freed. As each
arch frees their own init sections I need a single location to place my
hook. The archs all call free_reserved_area(). As this isn't a critical
section (ie. one that needs to be really fast), calling into ftrace
with the freed address should not be an issue. The ftrace code uses a
binary search within the blocks of locations so it is rather fast
itself.

Thoughts? Acks? :-)

-- Steve


> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2c6d5f64feca..95ac03de4cda 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -64,6 +64,7 @@
>  #include <linux/page_owner.h>
>  #include <linux/kthread.h>
>  #include <linux/memcontrol.h>
> +#include <linux/ftrace.h>
>  
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -6441,6 +6442,9 @@ unsigned long free_reserved_area(void *start, void *end, int poison, char *s)
>  	void *pos;
>  	unsigned long pages = 0;
>  
> +	/* This may be .init text, inform ftrace to remove it */
> +	ftrace_free_mem(start, end);
> +
>  	start = (void *)PAGE_ALIGN((unsigned long)start);
>  	end = (void *)((unsigned long)end & PAGE_MASK);
>  	for (pos = start; pos < end; pos += PAGE_SIZE, pages++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
