Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id C99646B0005
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 18:46:35 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id v19so3040239obq.7
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 15:46:34 -0800 (PST)
Message-ID: <513683D5.1080401@gmail.com>
Date: Wed, 06 Mar 2013 07:46:29 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 001/002] mm: limit growth of 3% hardcoded other user
 reserve
References: <20130305233811.GA1948@localhost.localdomain>
In-Reply-To: <20130305233811.GA1948@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, ric.masonn@gmail.com

On 03/06/2013 07:38 AM, Andrew Shewmaker wrote:
> Limit the growth of the memory reserved for other processes
> to the smaller of 3% or 8MB.
>
> This affects only OVERCOMMIT_NEVER.
>
> Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

Please add changelog, otherwise it's for other guys to review.

>
> ---
>
> Rebased onto v3.8-mmotm-2013-03-01-15-50
>
> No longer assumes 4kb pages.
> Code duplicated for nommu.
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 49dc7d5..4eb2b1a 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -184,9 +184,11 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>   	allowed += total_swap_pages;
>   
>   	/* Don't let a single process grow too big:
> -	   leave 3% of the size of this process for other processes */
> +	 * leave the smaller of 3% of the size of this process
> +         * or 8MB for other processes
> +         */
>   	if (mm)
> -		allowed -= mm->total_vm / 32;
> +		allowed -= min(mm->total_vm / 32, 1 << (23 - PAGE_SHIFT));
>   
>   	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
>   		return 0;
> diff --git a/mm/nommu.c b/mm/nommu.c
> index f5d57a3..a93d214 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1945,9 +1945,11 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>   	allowed += total_swap_pages;
>   
>   	/* Don't let a single process grow too big:
> -	   leave 3% of the size of this process for other processes */
> +	 * leave the smaller of 3% of the size of this process
> +         * or 8MB for other processes
> +         */
>   	if (mm)
> -		allowed -= mm->total_vm / 32;
> +		allowed -= min(mm->total_vm / 32, 1 << (23 - PAGE_SHIFT));
>   
>   	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
>   		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
