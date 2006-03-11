Message-ID: <44125812.1090408@yahoo.com.au>
Date: Sat, 11 Mar 2006 15:54:42 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] nommu: reverse mappings for nommu to solve get_user_pages
 problem
References: <20060311032606.GK26501@wotan.suse.de>
In-Reply-To: <20060311032606.GK26501@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: gerg@uclinux.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

>  int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  	unsigned long start, int len, int write, int force,
>  	struct page **pages, struct vm_area_struct **vmas)
>  {
>  	int i;
> -	static struct vm_area_struct dummy_vma;
> +	struct page *__page;
> +	static struct vm_area_struct *__vma;
> +	unsigned long addr = start;
>  
>  	for (i = 0; i < len; i++) {
> +		__vma = find_vma(mm, addr);
> +		if (!__vma)
> +			goto out_failed;
> +
> +		__page = virt_to_page(addr);
> +		if (!__page)
> +			goto out_failed;
> +
> +		BUG_ON(page_vma(__page) != __vma);
> +

Actually this check is leftover from a previous version. I think it
needs to be removed.

>  		if (pages) {
> -			pages[i] = virt_to_page(start);
> -			if (pages[i])
> -				page_cache_get(pages[i]);
> +			if (!__page->mapping) {
> +				printk(KERN_INFO "get_user_pages on unaligned"
> +						"anonymous page unsupported\n");				dump_stack();
> +				goto out_failed;
> +			}
> +

And this could trigger for file-backed pages that have been truncated meanwhile
I think. It wouldn't be a problem for a simple test-run, but does need to be
reworked slightly in order to be correct. Sub-page anonymous mappings cause a
lot of headaches :)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
