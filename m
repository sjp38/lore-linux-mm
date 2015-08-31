Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id C7EA96B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 10:30:25 -0400 (EDT)
Received: by labnh1 with SMTP id nh1so47343567lab.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 07:30:25 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id qb5si13300679lbb.28.2015.08.31.07.30.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 07:30:24 -0700 (PDT)
Date: Mon, 31 Aug 2015 17:30:08 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831143007.GA13814@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831134335.GB2271@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150831134335.GB2271@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 31, 2015 at 09:43:35AM -0400, Tejun Heo wrote:
> On Mon, Aug 31, 2015 at 03:24:15PM +0200, Michal Hocko wrote:
> > Right but isn't that what the caller explicitly asked for? Why should we
> > ignore that for kmem accounting? It seems like a fix at a wrong layer to
> > me. Either we should start failing GFP_NOWAIT charges when we are above
> > high wmark or deploy an additional catchup mechanism as suggested by
> > Tejun. I like the later more because it allows to better handle GFP_NOFS
> > requests as well and there are many sources of these from kmem paths.
> 
> Yeah, this is beginning to look like we're trying to solve the problem
> at the wrong layer.  slab/slub or whatever else should be able to use
> GFP_NOWAIT in whatever frequency they want for speculative
> allocations.

slab/slub can issue alloc_pages() any time with any flags they want and
it won't be accounted to memcg, because kmem is accounted at slab/slub
layer, not in buddy.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
