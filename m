Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 879DB6B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 23:39:51 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id vb8so3412466obc.2
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 20:39:51 -0800 (PST)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id ti9si9369000obc.36.2014.02.27.20.39.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Feb 2014 20:39:50 -0800 (PST)
Message-ID: <1393562387.2899.22.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v4] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 27 Feb 2014 20:39:47 -0800
In-Reply-To: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2014-02-27 at 13:48 -0800, Davidlohr Bueso wrote:
> From: Davidlohr Bueso <davidlohr@hp.com>
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 8740213..95c2bd9 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -768,16 +768,23 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
>   */
>  static void delete_vma_from_mm(struct vm_area_struct *vma)
>  {
> +	int i;
>  	struct address_space *mapping;
>  	struct mm_struct *mm = vma->vm_mm;
> +	struct task_struct *curr = current;
>  
>  	kenter("%p", vma);
>  
>  	protect_vma(vma, 0);
>  
>  	mm->map_count--;
> -	if (mm->mmap_cache == vma)
> -		mm->mmap_cache = NULL;
> +	for (i = 0; i < VMACACHE_SIZE; i++) {
> +		/* if the vma is cached, invalidate the entire cache */
> +		if (curr->vmacache[i] == vma) {
> +			vmacache_invalidate(mm);

*sigh* this should be curr->mm. 

Andrew, if there is no more feedback, do you want me to send another
patch for this or prefer fixing yourself for -mm? Assuming you'll take
it, of course.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
