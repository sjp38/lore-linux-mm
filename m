From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [patch]mm: make madvise(MADV_WILLNEED) support swap file prefetch
Date: Tue, 8 Jan 2013 10:16:07 +0800
Message-ID: <42018.4174938642$1357611409@news.gmane.org>
References: <20130107081237.GB21779@kernel.org>
 <20130107120630.82ba51ad.akpm@linux-foundation.org>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1TsOkA-0005i6-0f
	for glkm-linux-mm-2@m.gmane.org; Tue, 08 Jan 2013 03:16:46 +0100
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id DDBB56B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 21:16:26 -0500 (EST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 8 Jan 2013 07:45:27 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 85026394004E
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 07:46:21 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r082GHF843647162
	for <linux-mm@kvack.org>; Tue, 8 Jan 2013 07:46:19 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r082GIx2018119
	for <linux-mm@kvack.org>; Tue, 8 Jan 2013 13:16:19 +1100
Content-Disposition: inline
In-Reply-To: <20130107120630.82ba51ad.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com

On Mon, Jan 07, 2013 at 12:06:30PM -0800, Andrew Morton wrote:
>On Mon, 7 Jan 2013 16:12:37 +0800
>Shaohua Li <shli@kernel.org> wrote:
>
>> 
>> Make madvise(MADV_WILLNEED) support swap file prefetch. If memory is swapout,
>> this syscall can do swapin prefetch. It has no impact if the memory isn't
>> swapout.
>
>Seems sensible.

Hi Andrew and Shaohua,

What's the performance in the scenario of serious memory pressure? Since
in this case pages in swap are highly fragmented and cache hit is most
impossible. If WILLNEED path should add a check to skip readahead in
this case since swapin only leads to unnecessary memory allocation. 

Regards,
Wanpeng Li 

>
>> @@ -140,6 +219,18 @@ static long madvise_willneed(struct vm_a
>>  {
>>  	struct file *file = vma->vm_file;
>>  
>> +#ifdef CONFIG_SWAP
>
>It's odd that you put the ifdef in there, but then didn't test it!
>
>
>From: Andrew Morton <akpm@linux-foundation.org>
>Subject: mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix
>
>fix CONFIG_SWAP=n build
>
>Cc: Shaohua Li <shli@fusionio.com>
>Cc: Hugh Dickins <hughd@google.com>
>Cc: Rik van Riel <riel@redhat.com>
>Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>---
>
> mm/madvise.c |    2 ++
> 1 file changed, 2 insertions(+)
>
>diff -puN mm/madvise.c~mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix mm/madvise.c
>--- a/mm/madvise.c~mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix
>+++ a/mm/madvise.c
>@@ -134,6 +134,7 @@ out:
> 	return error;
> }
>
>+#ifdef CONFIG_SWAP
> static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
> 	unsigned long end, struct mm_walk *walk)
> {
>@@ -209,6 +210,7 @@ static void force_shm_swapin_readahead(s
>
> 	lru_add_drain();	/* Push any new pages onto the LRU now */
> }
>+#endif		/* CONFIG_SWAP */
>
> /*
>  * Schedule all required I/O operations.  Do not wait for completion.
>_
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
