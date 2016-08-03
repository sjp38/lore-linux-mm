Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4338D6B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 11:24:17 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l2so358396116qkf.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 08:24:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h186si2409915qkd.278.2016.08.03.08.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 08:24:16 -0700 (PDT)
Date: Wed, 3 Aug 2016 11:24:09 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: Move readahead limit outside of readahead, and
 advisory syscalls
Message-ID: <20160803152409.GB8962@t510>
References: <1469457565-22693-1-git-send-email-kwalker@redhat.com>
 <20160725134732.b21912c54ef1ffe820ccdbca@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160725134732.b21912c54ef1ffe820ccdbca@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kyle Walker <kwalker@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Geliang Tang <geliangtang@163.com>, Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <klamm@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Jul 25, 2016 at 01:47:32PM -0700, Andrew Morton wrote:
> On Mon, 25 Jul 2016 10:39:25 -0400 Kyle Walker <kwalker@redhat.com> wrote:
> 
> > Java workloads using the MappedByteBuffer library result in the fadvise()
> > and madvise() syscalls being used extensively. Following recent readahead
> > limiting alterations, such as 600e19af ("mm: use only per-device readahead
> > limit") and 6d2be915 ("mm/readahead.c: fix readahead failure for
> > memoryless NUMA nodes and limit readahead pages"), application performance
> > suffers in instances where small readahead is configured.
> 
> Can this suffering be quantified please?
> 
> > By moving this limit outside of the syscall codepaths, the syscalls are
> > able to advise an inordinately large amount of readahead when desired.
> > With a cap being imposed based on the half of NR_INACTIVE_FILE and
> > NR_FREE_PAGES. In essence, allowing performance tuning efforts to define a
> > small readahead limit, but then benefiting from large sequential readahead
> > values selectively.
> > 
> > ...
> >
> > --- a/mm/readahead.c
> > +++ b/mm/readahead.c
> > @@ -211,7 +211,9 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
> >  	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
> >  		return -EINVAL;
> >  
> > -	nr_to_read = min(nr_to_read, inode_to_bdi(mapping->host)->ra_pages);
> > +	nr_to_read = min(nr_to_read, (global_page_state(NR_INACTIVE_FILE) +
> > +				     (global_page_state(NR_FREE_PAGES)) / 2));
> > +
> >  	while (nr_to_read) {
> >  		int err;
> >  
> > @@ -484,6 +486,7 @@ void page_cache_sync_readahead(struct address_space *mapping,
> >  
> >  	/* be dumb */
> >  	if (filp && (filp->f_mode & FMODE_RANDOM)) {
> > +		req_size = min(req_size, inode_to_bdi(mapping->host)->ra_pages);
> >  		force_page_cache_readahead(mapping, filp, offset, req_size);
> >  		return;
> >  	}
> 
> Linus probably has opinions ;)
>

IIRC one of the issues Linus had with previous attempts was because 
they were utilizing/bringing back a node-memory state based heuristic. 

Since Kyle patch is using a global state counter for that matter,
I think that issue condition might now be sorted out.

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
