Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF766B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 03:31:20 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id p10so5804394pdj.27
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 00:31:19 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sk4si19043961pab.163.2014.09.23.00.31.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 00:31:18 -0700 (PDT)
Date: Tue, 23 Sep 2014 11:31:11 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/2] memcg: move memcg_{alloc,free}_cache_params to
 slab_common.c
Message-ID: <20140923073111.GC3588@esperanza>
References: <e768785511927d65bd3e6d9f65ab2a9851a3d73d.1411054735.git.vdavydov@parallels.com>
 <20140922200825.GA5373@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140922200825.GA5373@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>

On Mon, Sep 22, 2014 at 04:08:25PM -0400, Johannes Weiner wrote:
> On Thu, Sep 18, 2014 at 07:50:19PM +0400, Vladimir Davydov wrote:
> > The only reason why they live in memcontrol.c is that we get/put css
> > reference to the owner memory cgroup in them. However, we can do that in
> > memcg_{un,}register_cache.
> > 
> > So let's move them to slab_common.c and make them static.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: Christoph Lameter <cl@linux.com>
> 
> Cool, so you get rid of the back-and-forth between memcg and slab, and
> thereby also shrink the public memcg interface.

It should be mentioned that we still call memcg_update_array_size()
(defined at memcontrol.c) from memcg_update_all_caches()
(slab_common.c), because we must hold the slab_mutex while updating
memcg_limited_groups_array_size. However, I'm going to remove this
requirement and get rid of memcg_update_array_size() too. This is what
"[PATCH -mm 10/14] memcg: add rwsem to sync against memcg_caches arrays
relocation", which is a part of my "Per memcg slab shrinkers" patch set,
does.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
