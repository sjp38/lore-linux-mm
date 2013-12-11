Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 268696B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:09:09 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id z12so6282747wgg.27
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 03:09:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fx5si8371475wjb.84.2013.12.11.03.09.08
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 03:09:09 -0800 (PST)
Subject: Re: [PATCH v13 12/16] fs: mark list_lru based shrinkers memcg aware
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20131210041747.GA31386@dastard>
References: <cover.1386571280.git.vdavydov@parallels.com>
	 <9e1005848996c3df5ceca9e8262edcf8211a893d.1386571280.git.vdavydov@parallels.com>
	 <20131210041747.GA31386@dastard>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 11 Dec 2013 11:08:05 +0000
Message-ID: <1386760085.2706.20.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Al Viro <viro@zeniv.linux.org.uk>

Hi,

On Tue, 2013-12-10 at 15:17 +1100, Dave Chinner wrote:
> On Mon, Dec 09, 2013 at 12:05:53PM +0400, Vladimir Davydov wrote:
> > Since now list_lru automatically distributes objects among per-memcg
> > lists and list_lru_{count,walk} employ information passed in the
> > shrink_control argument to scan appropriate list, all shrinkers that
> > keep objects in the list_lru structure can already work as memcg-aware.
> > Let us mark them so.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> > Cc: Glauber Costa <glommer@openvz.org>
> > Cc: Dave Chinner <dchinner@redhat.com>
> > Cc: Al Viro <viro@zeniv.linux.org.uk>
> > ---
> >  fs/gfs2/quota.c  |    2 +-
> >  fs/super.c       |    2 +-
> >  fs/xfs/xfs_buf.c |    2 +-
> >  fs/xfs/xfs_qm.c  |    2 +-
> >  4 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
> > index f0435da..6cf6114 100644
> > --- a/fs/gfs2/quota.c
> > +++ b/fs/gfs2/quota.c
> > @@ -150,7 +150,7 @@ struct shrinker gfs2_qd_shrinker = {
> >  	.count_objects = gfs2_qd_shrink_count,
> >  	.scan_objects = gfs2_qd_shrink_scan,
> >  	.seeks = DEFAULT_SEEKS,
> > -	.flags = SHRINKER_NUMA_AWARE,
> > +	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
> >  };
> 
> I'll leave it for Steve to have the final say, but this cache tracks
> objects that have contexts that span multiple memcgs (i.e. global
> scope) and so is not a candidate for memcg based shrinking.
> 
> e.g. a single user can have processes running in multiple concurrent
> memcgs, and so the user quota dquot needs to be accessed from all
> those memcg contexts. Same for group quota objects - they can span
> multiple memcgs that different users have instantiated, simply
> because they all belong to the same group and hence are subject to
> the group quota accounting.
> 
> And for XFS, there's also project quotas, which means you can have
> files that are unique to both users and groups, but shared the same
> project quota and hence span memcgs that way....
> 

Well that seems to make sense to me. I'm not that familiar with memcg
and my main interest was to use the provided lru code, unless there was
a good reason why we should roll our own, and also to take advantage of
the NUMA friendliness of the new code. Although my main target in GFS2
was the glock lru, I've not got that far yet as it is a rather more
complicated thing to do, compared with the quota code,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
