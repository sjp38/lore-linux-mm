Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4DB6C6B0087
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:52:14 -0400 (EDT)
Message-ID: <4CC86587.6010506@redhat.com>
Date: Wed, 27 Oct 2010 13:46:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFT][PATCH] mm: Fix race in kunmap_atomic()
References: <20101027125154.GA23679@infradead.org> <1288191261.15336.1953.camel@twins>
In-Reply-To: <1288191261.15336.1953.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 10/27/2010 10:54 AM, Peter Zijlstra wrote:

> Christoph reported a nice splat which illustrated a race in the new
> stack based kmap_atomic implementation.
>
> The problem is that we pop our stack slot before we're completely done
> resetting its state -- in particular clearing the PTE (sometimes that's
> CONFIG_DEBUG_HIGHMEM). If an interrupt happens before we actually clear
> the PTE used for the last slot, that interrupt can reuse the slot in a
> dirty state, which triggers a BUG in kmap_atomic().
>
> Fix this by introducing kmap_atomic_idx() which reports the current slot
> index without actually releasing it and use that to find the PTE and
> delay the _pop() until after we're completely done.
>
> Reported-by: Christoph Hellwig<hch@infradead.org>
> Signed-off-by: Peter Zijlstra<a.p.zijlstra@chello.nl>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
