Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id B54276B00DC
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 15:25:49 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id un15so1312333pbc.20
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 12:25:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qm15si2070165pab.185.2014.06.12.12.25.48
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 12:25:48 -0700 (PDT)
Date: Thu, 12 Jun 2014 12:25:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Move __vma_address() to internal.h to be inlined in
 huge_memory.c
Message-Id: <20140612122546.cfdebdb22bb22c0f767e30b5@linux-foundation.org>
In-Reply-To: <1402600540-52031-1-git-send-email-Waiman.Long@hp.com>
References: <1402600540-52031-1-git-send-email-Waiman.Long@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <Waiman.Long@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On Thu, 12 Jun 2014 15:15:40 -0400 Waiman Long <Waiman.Long@hp.com> wrote:

> The vma_address() function which is used to compute the virtual address
> within a VMA is used only by 2 files in the mm subsystem - rmap.c and
> huge_memory.c. This function is defined in rmap.c and is inlined by
> its callers there, but it is also declared as an external function.
> 
> However, the __split_huge_page() function which calls vma_address()
> in huge_memory.c is calling it as a real function call. This is not
> as efficient as an inlined function. This patch moves the underlying
> inlined __vma_address() function to internal.h to be shared by both
> the rmap.c and huge_memory.c file.

This increases huge_memory.o's text+data_bss by 311 bytes, which makes
me suspect that it is a bad change due to its increase of kernel cache
footprint.

Perhaps we should be noinlining __vma_address()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
