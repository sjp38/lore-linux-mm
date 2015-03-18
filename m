Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id CBF336B0070
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:37:35 -0400 (EDT)
Received: by webcq43 with SMTP id cq43so33980140web.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:37:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si29294132wjw.48.2015.03.18.07.37.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 07:37:34 -0700 (PDT)
Date: Wed, 18 Mar 2015 15:37:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150318143733.GI17241@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098C99.9040104@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55098C99.9040104@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 18-03-15 10:32:57, Rik van Riel wrote:
> On 03/18/2015 10:09 AM, Michal Hocko wrote:
> 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 968cd8e03d2e..26f62ba79f50 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1752,7 +1752,7 @@ static int page_cache_read(struct file *file, pgoff_t offset)
> >  	int ret;
> >  
> >  	do {
> > -		page = page_cache_alloc_cold(mapping);
> > +		page = __page_cache_alloc(GFP_KERNEL|__GFP_COLD);
> >  		if (!page)
> >  			return -ENOMEM;
> 
> Won't this break on highmem systems, by failing to
> allocate the page cache from highmem, where previously
> it would?

It will! This is broken. I can see inode_init_always now. We need to add
GFP_HIGHUSER_MOVABLE here.

Thanks for pointing this out!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
