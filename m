Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE5EE8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 16:58:42 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id ay11so4995744plb.20
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:58:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor41526895pgv.82.2018.12.21.13.58.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 13:58:41 -0800 (PST)
Date: Fri, 21 Dec 2018 13:58:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
In-Reply-To: <1545337437-673-1-git-send-email-hofrat@osadl.org>
Message-ID: <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chintan Pandya <cpandya@codeaurora.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 20 Dec 2018, Nicholas Mc Guire wrote:

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 871e41c..1c118d7 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
>  
>  	/* Import existing vmlist entries. */
>  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
>  		va->flags = VM_VM_AREA;
>  		va->va_start = (unsigned long)tmp->addr;
>  		va->va_end = va->va_start + tmp->size;

Hi Nicholas,

You're right that this looks wrong because there's no guarantee that va is 
actually non-NULL.  __GFP_NOFAIL won't help in init, unfortunately, since 
we're not giving the page allocator a chance to reclaim so this would 
likely just end up looping forever instead of crashing with a NULL pointer 
dereference, which would actually be the better result.

You could do

	BUG_ON(!va);

to make it obvious why we crashed, however.  It makes it obvious that the 
crash is intentional rather than some error in the kernel code.
