Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 529B26B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 06:53:23 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so1512488pab.33
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 03:53:22 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id nr10si1079100pdb.27.2014.07.23.03.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jul 2014 03:53:22 -0700 (PDT)
Date: Wed, 23 Jul 2014 14:53:12 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 0/6] memcg: release memcg_cache_id on css offline
Message-ID: <20140723105312.GC30850@esperanza>
References: <cover.1405941342.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1405941342.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 21, 2014 at 03:47:10PM +0400, Vladimir Davydov wrote:
> This patch set makes memcg release memcg_cache_id on css offline. This
> way the memcg_caches arrays size will be limited by the number of alive
> kmem-active memory cgroups, which is much better.

Hi Andrew,

While preparing the per-memcg slab shrinkers patch set, I realized that
releasing memcg_cache_id on css offline is incorrect, because after css
offline there still can be elements on per-memcg list_lrus, which are
indexed by memcg_cache_id. We could re-parent them, but this is what we
decided to avoid in order to keep things clean and simple. So it seems
there's nothing we can do except keeping memcg_cache_ids till css free.

I wonder if we could reclaim memory from per memcg arrays (per memcg
list_lrus, kmem_caches) on memory pressure. May be, we could use
flex_array to achieve that.

Anyway, could you please drop the following patches from the mmotm tree
(all this set except patch 1, which is a mere cleanup)?

  memcg-release-memcg_cache_id-on-css-offline
  memcg-keep-all-children-of-each-root-cache-on-a-list
  memcg-add-pointer-to-owner-cache-to-memcg_cache_params
  memcg-make-memcg_cache_id-static
  slab-use-mem_cgroup_id-for-per-memcg-cache-naming

Sorry about the noise.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
