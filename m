Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3826B0038
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:11:43 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id fb4so3653454wid.1
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:11:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v10si9425264wix.33.2014.09.22.13.11.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 13:11:42 -0700 (PDT)
Date: Mon, 22 Sep 2014 16:11:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] memcg: move memcg_update_cache_size to slab_common.c
Message-ID: <20140922201137.GB5373@cmpxchg.org>
References: <e768785511927d65bd3e6d9f65ab2a9851a3d73d.1411054735.git.vdavydov@parallels.com>
 <0689062e28e13375241dcc64df2a398c9d606c64.1411054735.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0689062e28e13375241dcc64df2a398c9d606c64.1411054735.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>

On Thu, Sep 18, 2014 at 07:50:20PM +0400, Vladimir Davydov wrote:
> The only reason why this function lives in memcontrol.c is that it
> depends on memcg_caches_array_size. However, we can pass the new array
> size immediately to it instead of new_id+1 so that it will be free of
> any memcontrol.c dependencies.
> 
> So let's move this function to slab_common.c and make it static.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Christoph Lameter <cl@linux.com>

Looks good.  One nit below, but not a show stopper.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> @@ -646,11 +646,13 @@ int memcg_limited_groups_array_size;
>  struct static_key memcg_kmem_enabled_key;
>  EXPORT_SYMBOL(memcg_kmem_enabled_key);
>  
> +static void memcg_free_cache_id(int id);

Any chance you could re-order this code to avoid the forward decl?
memcg_alloc_cache_id() and memcg_free_cache_id() are new functions
anyway, might as well put the definition above the callsites.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
