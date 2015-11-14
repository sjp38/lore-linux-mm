Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id E223F6B0254
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 06:29:45 -0500 (EST)
Received: by lffu14 with SMTP id u14so65417705lff.1
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 03:29:45 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id k78si18236940lfi.54.2015.11.14.03.29.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 03:29:44 -0800 (PST)
Date: Sat, 14 Nov 2015 14:29:24 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2 4/6] slab: add SLAB_ACCOUNT flag
Message-ID: <20151114112924.GF31308@esperanza>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
 <20151112161741.GN1174@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151112161741.GN1174@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 12, 2015 at 05:17:41PM +0100, Michal Hocko wrote:
> On Tue 10-11-15 21:34:05, Vladimir Davydov wrote:
> > Currently, if we want to account all objects of a particular kmem cache,
> > we have to pass __GFP_ACCOUNT to each kmem_cache_alloc call, which is
> > inconvenient. This patch introduces SLAB_ACCOUNT flag which if passed to
> > kmem_cache_create will force accounting for every allocation from this
> > cache even if __GFP_ACCOUNT is not passed.
> 
> Yes this is much better and less error prone for dedicated caches.
> 
> > This patch does not make any of the existing caches use this flag - it
> > will be done later in the series.
> > 
> > Note, a cache with SLAB_ACCOUNT cannot be merged with a cache w/o
> > SLAB_ACCOUNT, i.e. using this flag will probably reduce the number of
> > merged slabs even if kmem accounting is not used (only compiled in).
> 
> I would expect some reasoning why this is the case. Why cannot caches of
> the same memcg be merged? I remember you have mentioned something in the
> previous discussion with Tejun but it should be in the changelog as well
> IMO.

Here goes an extended version of the last paragraph, hope it makes
everything clear:

"""
Note, a cache with SLAB_ACCOUNT cannot be merged with a cache w/o
SLAB_ACCOUNT, because merged caches share the same kmem_cache struct and
hence cannot have different sets of SLAB_* flags. Thus using this flag
will probably reduce the number of merged slabs even if kmem accounting
is not used (only compiled in).
"""

Andrew, could you please update the commit message?

> 
> > Suggested-by: Tejun Heo <tj@kernel.org>
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> I am not sufficiently qualified to judge the slab implementation
> specifics but for the overal approach
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
