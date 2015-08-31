Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 168876B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 09:24:19 -0400 (EDT)
Received: by wibq14 with SMTP id q14so145794wib.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 06:24:18 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id gc2si20957802wib.91.2015.08.31.06.24.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 06:24:17 -0700 (PDT)
Received: by wicfv10 with SMTP id fv10so70020941wic.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 06:24:16 -0700 (PDT)
Date: Mon, 31 Aug 2015 15:24:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831132414.GG29723@dhcp22.suse.cz>
References: <cover.1440960578.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1440960578.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 30-08-15 22:02:16, Vladimir Davydov wrote:
> Hi,
> 
> Tejun reported that sometimes memcg/memory.high threshold seems to be
> silently ignored if kmem accounting is enabled:
> 
>   http://www.spinics.net/lists/linux-mm/msg93613.html
> 
> It turned out that both SLAB and SLUB try to allocate without __GFP_WAIT
> first. As a result, if there is enough free pages, memcg reclaim will
> not get invoked on kmem allocations, which will lead to uncontrollable
> growth of memory usage no matter what memory.high is set to.

Right but isn't that what the caller explicitly asked for? Why should we
ignore that for kmem accounting? It seems like a fix at a wrong layer to
me. Either we should start failing GFP_NOWAIT charges when we are above
high wmark or deploy an additional catchup mechanism as suggested by
Tejun. I like the later more because it allows to better handle GFP_NOFS
requests as well and there are many sources of these from kmem paths.
 
> This patch set attempts to fix this issue. For more details please see
> comments to individual patches.
> 
> Thanks,
> 
> Vladimir Davydov (2):
>   mm/slab: skip memcg reclaim only if in atomic context
>   mm/slub: do not bypass memcg reclaim for high-order page allocation
> 
>  mm/slab.c | 32 +++++++++++---------------------
>  mm/slub.c | 24 +++++++++++-------------
>  2 files changed, 22 insertions(+), 34 deletions(-)
> 
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
