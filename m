Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35A286B0257
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:57:51 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so107920404pac.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:57:51 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ra6si10160256pab.90.2015.12.14.10.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 10:57:50 -0800 (PST)
Date: Mon, 14 Dec 2015 21:57:39 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: fix possible memcg leak due to
 interrupted reclaim
Message-ID: <20151214185739.GG28521@esperanza>
References: <1449927242-9608-1-git-send-email-vdavydov@virtuozzo.com>
 <20151212164540.GA7107@cmpxchg.org>
 <20151212191855.GE28521@esperanza>
 <20151214151901.GA13289@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151214151901.GA13289@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 14, 2015 at 10:19:01AM -0500, Johannes Weiner wrote:
...
> > @@ -859,14 +859,12 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  		if (prev && reclaim->generation != iter->generation)
> >  			goto out_unlock;
> >  
> > -		do {
> > +		while (1) {
> >  			pos = READ_ONCE(iter->position);
> > -			/*
> > -			 * A racing update may change the position and
> > -			 * put the last reference, hence css_tryget(),
> > -			 * or retry to see the updated position.
> > -			 */
> > -		} while (pos && !css_tryget(&pos->css));
> > +			if (!pos || css_tryget(&pos->css))
> > +				break;
> > +			cmpxchg(&iter->position, pos, NULL);
> > +		}
> 
> This cmpxchg() looks a little strange. Once tryget fails, the iterator
> should be clear soon enough, no? If not, a comment would be good here.

If we are running on an unpreemptible UP system, busy-waiting might
block the ->css_free work, which is supposed to clear iter->position,
resulting in a dead lock. I guess it might happen on SMP if RT scheduler
is used. Will add a comment here.

> 
> > @@ -912,12 +910,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  	}
> >  
> >  	if (reclaim) {
> > -		if (cmpxchg(&iter->position, pos, memcg) == pos) {
> > -			if (memcg)
> > -				css_get(&memcg->css);
> > -			if (pos)
> > -				css_put(&pos->css);
> > -		}
> > +		cmpxchg(&iter->position, pos, memcg);
> 
> This looks correct. The next iteration or break will put the memcg,
> potentially free it, which will clear it from the iterator and then
> rcu-free the css. Anybody who sees a pointer set under the RCU lock
> can safely run css_tryget() against it. Awesome!
> 
> Care to resend this with changelog?

Will do.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
