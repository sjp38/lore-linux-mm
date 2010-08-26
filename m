Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 840F66B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 02:41:34 -0400 (EDT)
Date: Wed, 25 Aug 2010 23:41:49 -0700 (PDT)
Message-Id: <20100825.234149.189710316.davem@davemloft.net>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: hughd@google.com
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, riel@redhat.com, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hughd@google.com>
Date: Wed, 25 Aug 2010 23:12:54 -0700 (PDT)

> After several hours, kbuild tests hang with anon_vma_prepare() spinning on
> a newly allocated anon_vma's lock - on a box with CONFIG_TREE_PREEMPT_RCU=y
> (which makes this very much more likely, but it could happen without).
> 
> The ever-subtle page_lock_anon_vma() now needs a further twist: since
> anon_vma_prepare() and anon_vma_fork() are liable to change the ->root
> of a reused anon_vma structure at any moment, page_lock_anon_vma()
> needs to check page_mapped() again before succeeding, otherwise
> page_unlock_anon_vma() might address a different root->lock.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Interesting, is the condition which allows this to trigger specific
to this merge window or was it always possible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
