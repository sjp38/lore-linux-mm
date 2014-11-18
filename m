Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id AB6316B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 19:02:15 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id l13so95059iga.15
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 16:02:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id em5si56956487icb.55.2014.11.17.16.02.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Nov 2014 16:02:14 -0800 (PST)
Date: Mon, 17 Nov 2014 16:02:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
Message-Id: <20141117160212.b86d031e1870601240b0131d@linux-foundation.org>
In-Reply-To: <20141114163053.GA6547@cosmos.ssec.wisc.edu>
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu>
	<502D42E5.7090403@redhat.com>
	<20120818000312.GA4262@evergreen.ssec.wisc.edu>
	<502F100A.1080401@redhat.com>
	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
	<20120822032057.GA30871@google.com>
	<50345232.4090002@redhat.com>
	<20130603195003.GA31275@evergreen.ssec.wisc.edu>
	<20141114163053.GA6547@cosmos.ssec.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

On Fri, 14 Nov 2014 10:30:53 -0600 Daniel Forrest <dan.forrest@ssec.wisc.edu> wrote:

> There have been a couple of inquiries about the status of this patch
> over the last few months, so I am going to try pushing it out.
> 
> Andrea Arcangeli has commented:
> 
> > Agreed. The only thing I don't like about this patch is the hardcoding
> > of number 5: could we make it a variable to tweak with sysfs/sysctl so
> > if some weird workload arises we have a tuning tweak? It'd cost one
> > cacheline during fork, so it doesn't look excessive overhead.
> 
> Adding this is beyond my experience level, so if it is required then
> someone else will have to make it so.
> 
> Rik van Riel has commented:
> 
> > I believe we should just merge that patch.
> > 
> > I have not seen any better ideas come by.
> > 
> > The comment should probably be fixed to reflect the
> > chain length of 5 though :)
> 
> So here is Michel's patch again with "(length > 1)" modified to
> "(length > 5)" and fixed comments.
> 
> I have been running with this patch (with the threshold set to 5) for
> over two years now and it does indeed solve the problem.
> 
> ---
> 
> anon_vma_clone() is modified to return the length of the existing
> same_vma anon vma chain, and we create a new anon_vma in the child
> if it is more than five forks after the anon_vma was created, as we
> don't want the same_vma chain to grow arbitrarily large.

hoo boy, what's going on here.

- Under what circumstances are we seeing this slab windup?

- What are the consequences?  Can it OOM the machine?

- Why is this occurring?  There aren't an infinite number of vmas, so
  there shouldn't be an infinite number of anon_vmas or
  anon_vma_chains.

- IOW, what has to be done to fix this properly?

- What are the runtime consequences of limiting the length of the chain?

> ...
>
> @@ -331,10 +334,17 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
>  	 * First, attach the new VMA to the parent VMA's anon_vmas,
>  	 * so rmap can find non-COWed pages in child processes.
>  	 */
> -	if (anon_vma_clone(vma, pvma))
> +	length = anon_vma_clone(vma, pvma);
> +	if (length < 0)
>  		return -ENOMEM;

This should propagate the anon_vma_clone() return val instead of
assuming ENOMEM.  But that won't fix anything...

> +	else if (length > 5)
> +		return 0;
>  
> -	/* Then add our own anon_vma. */
> +	/*
> +	 * Then add our own anon_vma. We do this only for five forks after
> +	 * the anon_vma was created, as we don't want the same_vma chain to
> +	 * grow arbitrarily large.
> +	 */
>  	anon_vma = anon_vma_alloc();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
