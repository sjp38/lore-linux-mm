Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f45.google.com (mail-qe0-f45.google.com [209.85.128.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEC26B0038
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 20:38:59 -0500 (EST)
Received: by mail-qe0-f45.google.com with SMTP id 6so3622228qea.32
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 17:38:59 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id b6si10242347qak.70.2013.12.09.17.38.56
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 17:38:57 -0800 (PST)
Date: Tue, 10 Dec 2013 12:38:41 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v13 09/16] fs: consolidate {nr,free}_cached_objects args
 in shrink_control
Message-ID: <20131210013841.GY31386@dastard>
References: <cover.1386571280.git.vdavydov@parallels.com>
 <43660b83b58531ccf4d45f626283484441441943.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43660b83b58531ccf4d45f626283484441441943.1386571280.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Al Viro <viro@zeniv.linux.org.uk>

On Mon, Dec 09, 2013 at 12:05:50PM +0400, Vladimir Davydov wrote:
> We are going to make the FS shrinker memcg-aware. To achieve that, we
> will have to pass the memcg to scan to the nr_cached_objects and
> free_cached_objects VFS methods, which currently take only the NUMA node
> to scan. Since the shrink_control structure already holds the node, and
> the memcg to scan will be added to it as we introduce memcg-aware
> vmscan, let us consolidate the methods' arguments in this structure to
> keep things clean.
> 
> Thanks to David Chinner for the tip.

Ok, you dealt with this as a separate patch...

> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Glauber Costa <glommer@openvz.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  fs/super.c         |    8 +++-----
>  fs/xfs/xfs_super.c |    6 +++---
>  include/linux/fs.h |    6 ++++--
>  3 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index a039dba..8f9a81b 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -76,7 +76,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>  		return SHRINK_STOP;
>  
>  	if (sb->s_op->nr_cached_objects)
> -		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
> +		fs_objects = sb->s_op->nr_cached_objects(sb, sc);
>  
>  	inodes = list_lru_count(&sb->s_inode_lru, sc);
>  	dentries = list_lru_count(&sb->s_dentry_lru, sc);
> @@ -96,8 +96,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>  	if (fs_objects) {
>  		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
>  								total_objects);
> -		freed += sb->s_op->free_cached_objects(sb, fs_objects,
> -						       sc->nid);
> +		freed += sb->s_op->free_cached_objects(sb, sc, fs_objects);
>  	}

Again, pass the number to scan in sc->nr_to_scan, please.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
