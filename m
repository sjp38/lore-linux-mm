Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBE76B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 01:58:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k9so3733336pgo.15
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 22:58:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor2214898pgr.73.2018.04.22.22.58.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 22:58:21 -0700 (PDT)
Date: Mon, 23 Apr 2018 14:58:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 01/25] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
Message-ID: <20180423055809.GA114098@rodete-desktop-imager.corp.google.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-2-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523975611-15978-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Laurent,

I guess it's good timing to review. Guess LSF/MM goes so might change
a lot since then. :) Anyway, I grap a time to review.

On Tue, Apr 17, 2018 at 04:33:07PM +0200, Laurent Dufour wrote:
> This configuration variable will be used to build the code needed to
> handle speculative page fault.
> 
> By default it is turned off, and activated depending on architecture
> support, SMP and MMU.

Can we have description in here why it depends on architecture?

> 
> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  mm/Kconfig | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d5004d82a1d6..5484dca11199 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -752,3 +752,25 @@ config GUP_BENCHMARK
>  	  performance of get_user_pages_fast().
>  
>  	  See tools/testing/selftests/vm/gup_benchmark.c
> +
> +config ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
> +       def_bool n
> +
> +config SPECULATIVE_PAGE_FAULT
> +       bool "Speculative page faults"
> +       default y
> +       depends on ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
> +       depends on MMU && SMP
> +       help
> +         Try to handle user space page faults without holding the mmap_sem.
> +
> +	 This should allow better concurrency for massively threaded process
> +	 since the page fault handler will not wait for other threads memory
> +	 layout change to be done, assuming that this change is done in another
> +	 part of the process's memory space. This type of page fault is named
> +	 speculative page fault.
> +
> +	 If the speculative page fault fails because of a concurrency is
> +	 detected or because underlying PMD or PTE tables are not yet
> +	 allocating, it is failing its processing and a classic page fault
> +	 is then tried.
> -- 
> 2.7.4
> 
