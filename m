Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 99C616B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 18:40:58 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id rd3so1902526pab.41
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 15:40:58 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ym5si2641465pab.161.2014.10.23.15.40.57
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 15:40:57 -0700 (PDT)
Date: Thu, 23 Oct 2014 18:40:35 -0400 (EDT)
Message-Id: <20141023.184035.388557314666522484.davem@davemloft.net>
Subject: Re: [PATCH V2 1/2] mm: Update generic gup implementation to handle
 hugepage directory
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
References: <1413520687-31729-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aneesh.kumar@linux.vnet.ibm.com, steve.capper@linaro.org, aarcange@redhat.com, benh@kernel.crashing.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, hannes@cmpxchg.org


Hey guys, was looking over the generic GUP while working on a sparc64
issue and I noticed that you guys do speculative page gets, and after
talking with Johannes Weiner (CC:'d) about this we don't see how it
could be necessary.

If interrupts are disabled during the page table scan (which they
are), no IPI tlb flushes can arrive.  Therefore any removal from the
page tables is guarded by interrupts being re-enabled.  And as a
result, page counts of pages we see in the page tables must always
have a count > 0.

x86 does direct atomic_add() on &page->_count because of this
invariant and I would rather see the generic version do this too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
