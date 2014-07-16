Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id BB1436B00B0
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 10:58:17 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so1452104wiv.3
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 07:58:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hc6si24301586wjc.68.2014.07.16.07.58.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jul 2014 07:58:08 -0700 (PDT)
Date: Wed, 16 Jul 2014 10:57:36 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140716145736.GA9794@nhori.redhat.com>
References: <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715155537.GA19454@nhori.bos.redhat.com>
 <20140715160735.GB29269@dhcp22.suse.cz>
 <20140715173439.GU29639@cmpxchg.org>
 <20140715184358.GA31550@nhori.bos.redhat.com>
 <20140715190454.GW29639@cmpxchg.org>
 <20140715204953.GA21016@nhori.bos.redhat.com>
 <20140715214843.GX29639@cmpxchg.org>
 <20140716133050.GA4644@nhori.redhat.com>
 <20140716141447.GY29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716141447.GY29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 16, 2014 at 10:14:47AM -0400, Johannes Weiner wrote:
...
> > >  	free_hot_cold_page(page, false);
> > >  }
> > >  
> > > @@ -75,7 +75,10 @@ static void __put_compound_page(struct page *page)
> > >  {
> > >  	compound_page_dtor *dtor;
> > >  
> > > -	__page_cache_release(page);
> > > +	if (!PageHuge(page)) {
> > > +		__page_cache_release(page);
> > > +		mem_cgroup_uncharge_page(page);
> 
> I reverted all these mm/swap.c changes again as well.  Instead,
> mem_cgroup_uncharge() now does a preliminary check if the page is
> charged before it touches page->lru.
> 
> That should be much more robust: now the vetting whether a page is
> valid for memcg happens at charge time only, all other operations
> check first if a page is charged before doing anything else to it.
> 
> These two places should be the only ones that need fixing then:

This change also passed my testing, so the problem should be fixed.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
