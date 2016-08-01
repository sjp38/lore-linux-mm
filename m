Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4403C6B0260
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 13:40:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p129so86627441wmp.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 10:40:00 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id m71si16971871wmh.129.2016.08.01.10.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 10:39:59 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id o80so255114911wme.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 10:39:59 -0700 (PDT)
Date: Mon, 1 Aug 2016 19:39:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: put soft limit reclaim out of way if the excess
 tree is empty
Message-ID: <20160801173956.GA31957@dhcp22.suse.cz>
References: <1470045621-14335-1-git-send-email-mhocko@kernel.org>
 <20160801135757.GB19395@esperanza>
 <20160801141227.GI13544@dhcp22.suse.cz>
 <20160801150343.GA7603@cmpxchg.org>
 <20160801152454.GK13544@dhcp22.suse.cz>
 <20160801171717.GB8724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160801171717.GB8724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 01-08-16 13:17:17, Johannes Weiner wrote:
> On Mon, Aug 01, 2016 at 05:24:54PM +0200, Michal Hocko wrote:
> > @@ -2564,7 +2559,13 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
> >  		return 0;
> >  
> >  	mctz = soft_limit_tree_node(pgdat->node_id);
> > -	if (soft_limit_tree_empty(mctz))
> > +
> > +	/*
> > +	 * Do not even bother to check the largest node if the node
> 
>                                                                root

Fixed

> 
> > +	 * is empty. Do it lockless to prevent lock bouncing. Races
> > +	 * are acceptable as soft limit is best effort anyway.
> > +	 */
> > +	if (RB_EMPTY_ROOT(&mctz->rb_root))
> >  		return 0;
> 
> Other than that, looks good. Please retain my
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
