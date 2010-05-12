Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0756E6B01EF
	for <linux-mm@kvack.org>; Wed, 12 May 2010 18:18:43 -0400 (EDT)
Message-ID: <4BEB2923.8030200@redhat.com>
Date: Wed, 12 May 2010 18:18:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] always lock the root (oldest) anon_vma
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512134029.36c286c4@annuminas.surriel.com> <alpine.LFD.2.00.1005121441350.3711@i5.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1005121441350.3711@i5.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 05/12/2010 05:55 PM, Linus Torvalds wrote:

> Wouldn't it be sufficient to do
>
> 	if (atomic_dec_and_test(&anon_vma->ksm_refcount)) {
> 		anon_vma_lock(anon_vma);
>
> instead? The "atomic_dec_and_lock()" semantics are _much_ stricter than a
> regular "decrement and test and then lock", and that strictness means that
> it's way more complicated and expensive. So if you don't need the
> semantics, you shouldn't use them.

I suspect the atomic_dec_and_lock in the KVM code is being used
to prevent the following race:

1) KSM code reduces the refcount to 0

2)                               munmap on other CPU frees the anon_vma

3) KSM code takes the anon_vma lock,
    which now lives in freed memory

Am I totally confused by this and can we use a nicer approach?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
