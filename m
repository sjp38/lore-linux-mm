Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DB65A6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 13:26:45 -0400 (EDT)
Subject: Re: [PATCH] fix/improve generic page table walker
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090311144951.58c6ab60@skybase>
References: <20090311144951.58c6ab60@skybase>
Content-Type: text/plain
Date: Wed, 11 Mar 2009 12:24:23 -0500
Message-Id: <1236792263.3205.45.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-03-11 at 14:49 +0100, Martin Schwidefsky wrote:
> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> On s390 the /proc/pid/pagemap interface is currently broken. This is
> caused by the unconditional loop over all pgd/pud entries as specified
> by the address range passed to walk_page_range. The tricky bit here
> is that the pgd++ in the outer loop may only be done if the page table
> really has 4 levels. For the pud++ in the second loop the page table needs
> to have at least 3 levels. With the dynamic page tables on s390 we can have
> page tables with 2, 3 or 4 levels. Which means that the pgd and/or the
> pud pointer can get out-of-bounds causing all kinds of mayhem.

Not sure why this should be a problem without delving into the S390
code. After all, x86 has 2, 3, or 4 levels as well (at compile time) in
a way that's transparent to the walker.

> The proposed solution is to fast-forward over the hole between the start
> address and the first vma and the hole between the last vma and the end
> address. The pgd/pud/pmd/pte loops are used only for the address range
> between the first and last vma. This guarantees that the page table
> pointers stay in range for s390. For the other architectures this is
> a small optimization.

I've gone to lengths to keep VMAs out of the equation, so I can't say
I'm excited about this solution.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
