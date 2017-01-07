Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20BE86B025E
	for <linux-mm@kvack.org>; Sat,  7 Jan 2017 04:27:52 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so129702260wjb.7
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 01:27:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 16si2877399wrx.43.2017.01.07.01.27.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 07 Jan 2017 01:27:51 -0800 (PST)
Date: Sat, 7 Jan 2017 10:27:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: weird allocation pattern in alloc_ila_locks
Message-ID: <20170107092746.GC5047@dhcp22.suse.cz>
References: <20170106095115.GG5556@dhcp22.suse.cz>
 <20170106100433.GH5556@dhcp22.suse.cz>
 <20170106121642.GJ5556@dhcp22.suse.cz>
 <1483740889.9712.44.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1483740889.9712.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, edumazet@google.com

On Fri 06-01-17 14:14:49, Eric Dumazet wrote:
> On Fri, 2017-01-06 at 13:16 +0100, Michal Hocko wrote:
> > I was thinking about the rhashtable which was the source of the c&p and
> > it can be simplified as well.
> > ---
> > From 555543604f5f020284ea85d928d52f6a55fde7ca Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Fri, 6 Jan 2017 13:12:31 +0100
> > Subject: [PATCH] rhashtable: simplify a strange allocation pattern
> > 
> > alloc_bucket_locks allocation pattern is quite unusual. We are
> > preferring vmalloc when CONFIG_NUMA is enabled which doesn't make much
> > sense because there is no special NUMA locality handled in that code
> > path. Let's just simplify the code and use kvmalloc helper, which is a
> > transparent way to use kmalloc with vmalloc fallback, if the caller
> > is allowed to block and use the flag otherwise.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  lib/rhashtable.c | 13 +++----------
> >  1 file changed, 3 insertions(+), 10 deletions(-)
> > 
> > diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> > index 32d0ad058380..4d3886b6ab7d 100644
> > --- a/lib/rhashtable.c
> > +++ b/lib/rhashtable.c
> > @@ -77,16 +77,9 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
> >  	size = min_t(unsigned int, size, tbl->size >> 1);
> >  
> >  	if (sizeof(spinlock_t) != 0) {
> > -		tbl->locks = NULL;
> > -#ifdef CONFIG_NUMA
> > -		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
> > -		    gfp == GFP_KERNEL)
> > -			tbl->locks = vmalloc(size * sizeof(spinlock_t));
> > -#endif
> > -		if (gfp != GFP_KERNEL)
> > -			gfp |= __GFP_NOWARN | __GFP_NORETRY;
> > -
> > -		if (!tbl->locks)
> > +		if (gfpflags_allow_blocking(gfp_))
> > +			tbl->locks = kvmalloc(size * sizeof(spinlock_t), gfp);
> > +		else
> >  			tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
> 
> 
> I believe the intent was to get NUMA spreading, a bit like what we have
> in alloc_large_system_hash() when hashdist == HASHDIST_DEFAULT

Hmm, I am not sure this works as expected then. Because it is more
likely that all pages backing the vmallocked area will come from the
local node than spread around more nodes. Or did I miss your point?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
