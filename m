Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 19CE86B00B1
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:45:45 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so9027638pbc.35
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:45:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id r3si7115041pan.130.2013.11.26.14.45.43
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 14:45:43 -0800 (PST)
Date: Tue, 26 Nov 2013 14:45:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 3/4] mm/vmalloc.c: Allow lowmem to be tracked in
 vmalloc
Message-Id: <20131126144541.6b16979b77f927f6d945ab60@linux-foundation.org>
In-Reply-To: <5285A896.3030204@codeaurora.org>
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org>
	<1384212412-21236-4-git-send-email-lauraa@codeaurora.org>
	<52850C37.1080506@sr71.net>
	<5285A896.3030204@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Dave Hansen <dave@sr71.net>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Neeti Desai <neetid@codeaurora.org>

On Thu, 14 Nov 2013 20:52:38 -0800 Laura Abbott <lauraa@codeaurora.org> wrote:

> If is_vmalloc_addr returned true 
> the spinlock/tree walk would happen anyway so essentially this is 
> getting rid of the fast path. This is typically used in the idiom
> 
> alloc(size) {
> 	if (size > some metric)
> 		vmalloc
> 	else
> 		kmalloc
> }

A better form is

	if (kmalloc(..., GFP_NOWARN) == NULL)
		vmalloc

> free (ptr) {
> 	if (is_vmalloc_addr(ptr)
> 		vfree
> 	else
> 		kfree
> }
> 
> so my hypothesis would be that any path would have to be willing to take 
> the penalty of vmalloc anyway. The actual cost would depend on the 
> vmalloc / kmalloc ratio. I haven't had a chance to get profiling data 
> yet to see the performance difference.

I've resisted adding the above helper functions simply to discourage
the use of vmalloc() - it *is* slow, and one day we might hit
vmalloc-arena fragmentation issues.

That being said, I might one day give up, because adding such helpers
would be a significant cleanup.  And once they are added, their use
will proliferate and is_vmalloc_addr() will take quite a beating.

So yes, it would be prudent to be worried about is_vmalloc_addr()
performance at the outset.

Couldn't is_vmalloc_addr() just be done with a plain old bitmap?  It
would consume 128kbytes to manage a 4G address space, and 1/8th of a meg
isn't much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
