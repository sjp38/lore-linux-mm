Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 928996B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 12:05:39 -0500 (EST)
Message-ID: <496CC9D8.6040909@google.com>
Date: Tue, 13 Jan 2009 09:05:28 -0800
From: Mike Waychison <mikew@google.com>
MIME-Version: 1.0
Subject: Re: mmotm 2009-01-12-16-53 uploaded
References: <200901130053.n0D0rhev023334@imap1.linux-foundation.org> <20090113181317.48e910af.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090113181317.48e910af.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghan@google.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 12 Jan 2009 16:53:43 -0800
> akpm@linux-foundation.org wrote:
> 
>> The mm-of-the-moment snapshot 2009-01-12-16-53 has been uploaded to
>>
>>    http://userweb.kernel.org/~akpm/mmotm/
>>
>> and will soon be available at
>>
>>    git://git.zen-sources.org/zen/mmotm.git
>>
> 
> After rtc compile fix, the kernel boots.
> 
> But with CONFIG_DEBUG_VM, I saw BUG_ON() at 
> 
> fork() -> ...
> 	-> copy_page_range() ...
> 		-> copy_one_pte()
> 			->page_dup_rmap()
> 				-> __page_check_anon_rmap().
> 
> BUG_ON(page->index != linear_page_index(vma, address)); 
> fires. (from above, the page is ANON.)
> 
> It seems page->index == 0x7FFFFFFE here and the page seems to be
> the highest address of stack.
> 
> This is caused by
>  fs-execc-fix-value-of-vma-vm_pgoff-for-the-stack-vma-of-32-bit-processes.patch 
> 
> 
> This is a fix.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> pgoff is *not* vma->vm_start >> PAGE_SHIFT.
> And no adjustment is necessary (when it maps the same start
> before/after adjust vma.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> Index: mmotm-2.6.29-Jan12/fs/exec.c
> ===================================================================
> --- mmotm-2.6.29-Jan12.orig/fs/exec.c
> +++ mmotm-2.6.29-Jan12/fs/exec.c
> @@ -509,7 +509,7 @@ static int shift_arg_pages(struct vm_are
>  	unsigned long length = old_end - old_start;
>  	unsigned long new_start = old_start - shift;
>  	unsigned long new_end = old_end - shift;
> -	unsigned long new_pgoff = new_start >> PAGE_SHIFT;
> +	unsigned long new_pgoff = vma->vm_pgoff;
>  	struct mmu_gather *tlb;
>  
>  	BUG_ON(new_start > new_end);
> 

This patch is just reverting the behaviour back to having a 64bit pgoff. 
  Best just reverting the patch for the time being.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
