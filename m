Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7266B03C2
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 08:14:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k22so1353490wrk.5
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 05:14:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v63si24179769wma.79.2017.04.05.05.14.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 05:14:54 -0700 (PDT)
Date: Wed, 5 Apr 2017 14:14:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
Message-ID: <20170405121449.GO6035@dhcp22.suse.cz>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <2cfc601e-3093-143e-b93d-402f330a748a@vmware.com>
 <a28cc48d-3d6f-b4dd-10c2-a75d2e83ef14@virtuozzo.com>
 <8d313f6c-9ea8-7be0-38cd-15370e5a1d6c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8d313f6c-9ea8-7be0-38cd-15370e5a1d6c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Hellstrom <thellstrom@vmware.com>, akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, stable@vger.kernel.org

On Wed 05-04-17 13:42:19, Vlastimil Babka wrote:
> On 03/30/2017 04:48 PM, Andrey Ryabinin wrote:
[...]
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -737,7 +737,8 @@ static void free_vmap_area_noflush(struct vmap_area *va)
> >  	/* After this point, we may free va at any time */
> >  	llist_add(&va->purge_list, &vmap_purge_list);
> >  
> > -	if (unlikely(nr_lazy > lazy_max_pages()))
> > +	if (unlikely(nr_lazy > lazy_max_pages()) &&
> > +	    !mutex_is_locked(&vmap_purge_lock))
> 
> So, isn't this racy? (and do we care?)

yes, it is racy and no we do not care AFAICS. If the lock is held then
somebody is already doing the work on our behalf. If we are unlucky
and that work has been already consumed (read another lazy_max_pages
have been freed) then we would still try to lazy free it during the
allocation. This would be something for the changelog of course.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
