Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 191E76B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:24:19 -0400 (EDT)
Date: Thu, 11 Apr 2013 14:24:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] mm: Soft-dirty bits for user memory changes
 tracking
Message-Id: <20130411142417.bb58d519b860d06ab84333c2@linux-foundation.org>
In-Reply-To: <51669EB8.2020102@parallels.com>
References: <51669E5F.4000801@parallels.com>
	<51669EB8.2020102@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 11 Apr 2013 15:30:00 +0400 Pavel Emelyanov <xemul@parallels.com> wrote:

> The soft-dirty is a bit on a PTE which helps to track which pages a task
> writes to. In order to do this tracking one should
> 
>   1. Clear soft-dirty bits from PTEs ("echo 4 > /proc/PID/clear_refs)
>   2. Wait some time.
>   3. Read soft-dirty bits (55'th in /proc/PID/pagemap2 entries)
> 
> To do this tracking, the writable bit is cleared from PTEs when the
> soft-dirty bit is. Thus, after this, when the task tries to modify a page
> at some virtual address the #PF occurs and the kernel sets the soft-dirty
> bit on the respective PTE.
> 
> Note, that although all the task's address space is marked as r/o after the
> soft-dirty bits clear, the #PF-s that occur after that are processed fast.
> This is so, since the pages are still mapped to physical memory, and thus
> all the kernel does is finds this fact out and puts back writable, dirty
> and soft-dirty bits on the PTE.
> 
> Another thing to note, is that when mremap moves PTEs they are marked with
> soft-dirty as well, since from the user perspective mremap modifies the
> virtual memory at mremap's new address.
> 
> ...
>
> +config MEM_SOFT_DIRTY
> +	bool "Track memory changes"
> +	depends on CHECKPOINT_RESTORE && X86

I guess we can add the CHECKPOINT_RESTORE dependency for now, but it is
a general facility and I expect others will want to get their hands on
it for unrelated things.

>From that perspective, the dependency on X86 is awful.  What's the
problem here and what do other architectures need to do to be able to
support the feature?


You have a test application, I assume.  It would be helpful if we could
get that into tools/testing/selftests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
