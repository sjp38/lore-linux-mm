Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 5C8F56B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 16:47:58 -0500 (EST)
Date: Wed, 13 Feb 2013 13:47:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Limit pgd range freeing to mm->task_size
Message-Id: <20130213134756.b90f8e1b.akpm@linux-foundation.org>
In-Reply-To: <1360755569-27282-1-git-send-email-catalin.marinas@arm.com>
References: <1360755569-27282-1-git-send-email-catalin.marinas@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Russell King <linux@arm.linux.org.uk>

On Wed, 13 Feb 2013 11:39:29 +0000
Catalin Marinas <catalin.marinas@arm.com> wrote:

> ARM processors with LPAE enabled use 3 levels of page tables, with an
> entry in the top level (pgd) covering 1GB of virtual space. Because of
> the branch relocation limitations on ARM, the loadable modules are
> mapped 16MB below PAGE_OFFSET, making the corresponding 1GB pgd shared
> between kernel modules and user space.
> 
> Since free_pgtables() is called with ceiling == 0, free_pgd_range() (and
> subsequently called functions) also frees the page table
> shared between user space and kernel modules (which is normally handled
> by the ARM-specific pgd_free() function).
> 
> This patch changes the ceiling argument to mm->task_size for the
> free_pgtables() and free_pgd_range() function calls. We cannot use
> TASK_SIZE since this macro may not be a run-time constant on 64-bit
> systems supporting compat applications.

I'm trying to work out why we're using 0 in there at all, rather than
->task_size.  But that's lost in the mists of time.

As you've discovered, handling of task_size and TASK_SIZE is somewhat
inconsistent across architectures and with compat tasks.  I guess we
toss it in there and see if anything breaks...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
