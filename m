Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 739BE6B006E
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 17:35:02 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so9791601pad.15
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 14:35:02 -0800 (PST)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id qn8si26190931pab.101.2014.11.30.14.35.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 30 Nov 2014 14:35:01 -0800 (PST)
Received: by mail-pd0-f181.google.com with SMTP id v10so4252131pde.26
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 14:35:00 -0800 (PST)
Date: Sun, 30 Nov 2014 14:34:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 13/16] ksm: Replace smp_read_barrier_depends() with
 lockless_dereference()
In-Reply-To: <1415906662-4576-14-git-send-email-bobby.prani@gmail.com>
Message-ID: <alpine.LSU.2.11.1411301412100.1824@eggly.anvils>
References: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com> <1415906662-4576-14-git-send-email-bobby.prani@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pranith Kumar <bobby.prani@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Joerg Roedel <jroedel@suse.de>, NeilBrown <neilb@suse.de>, Sasha Levin <sasha.levin@oracle.com>, Paul McQuade <paulmcquad@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, paulmck@linux.vnet.ibm.com

On Thu, 13 Nov 2014, Pranith Kumar wrote:

> Recently lockless_dereference() was added which can be used in place of
> hard-coding smp_read_barrier_depends(). The following PATCH makes the change.
> 
> Signed-off-by: Pranith Kumar <bobby.prani@gmail.com>

Sorry, I don't think your patch is buggy, but I do think it
makes this tricky piece of code harder to follow, not easier.

It is certainly not a standard use of lockless_dereference() (kpfn
is not a pointer), and it both hides and moves where the barrier is.
And then at the end of the function, there's still explicit barriers
and ACCESS_ONCE comparison with kpfn, which this makes more obscure.

Unless you are actually fixing a bug (I don't pretend to have
tested this on Alpha, and I can get barriers wrong as we all do),
or smp_read_barrier_depends() is about to be withdrawn from use,
I'd rather say NAK to this patch.

Hugh

> ---
>  mm/ksm.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index d247efa..a67de79 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -542,15 +542,14 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>  	expected_mapping = (void *)stable_node +
>  				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
>  again:
> -	kpfn = ACCESS_ONCE(stable_node->kpfn);
> -	page = pfn_to_page(kpfn);
> -
>  	/*
>  	 * page is computed from kpfn, so on most architectures reading
>  	 * page->mapping is naturally ordered after reading node->kpfn,
>  	 * but on Alpha we need to be more careful.
>  	 */
> -	smp_read_barrier_depends();
> +	kpfn = lockless_dereference(stable_node->kpfn);
> +	page = pfn_to_page(kpfn);
> +
>  	if (ACCESS_ONCE(page->mapping) != expected_mapping)
>  		goto stale;
>  
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
