Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EBF606B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 10:20:43 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id y10so4572028pdj.31
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 07:20:43 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fa6si16016403pab.53.2014.09.22.07.20.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 07:20:43 -0700 (PDT)
Date: Mon, 22 Sep 2014 18:20:35 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 2/2] memcg: move memcg_update_cache_size to slab_common.c
Message-ID: <20140922142035.GE18526@esperanza>
References: <e768785511927d65bd3e6d9f65ab2a9851a3d73d.1411054735.git.vdavydov@parallels.com>
 <0689062e28e13375241dcc64df2a398c9d606c64.1411054735.git.vdavydov@parallels.com>
 <20140922140734.GF336@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140922140734.GF336@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>

On Mon, Sep 22, 2014 at 04:07:34PM +0200, Michal Hocko wrote:
> On Thu 18-09-14 19:50:20, Vladimir Davydov wrote:
> > The only reason why this function lives in memcontrol.c is that it
> > depends on memcg_caches_array_size. However, we can pass the new array
> > size immediately to it instead of new_id+1 so that it will be free of
> > any memcontrol.c dependencies.
> > 
> > So let's move this function to slab_common.c and make it static.
> 
> Why?

Jumping from memcontrol.c to slab_common.c and then back to memcontrol.c
while updating per-memcg caches looks ugly IMO. We can do the update on
the slab's side.

> besides that the patch does more code reshuffling which should be
> documented. I have got lost a bit to be honest.

It just makes it sane :-) Currently we walk over all slab caches each
time new kmemcg is created even if memcg_limited_groups_array_size
doesn't grow and we've actually nothing to do. So it moves cache id
allocation stuff to a separate function (memcg_alloc_cache_id) and
places the check there so that memcg_update_all_caches is only called
when it's really necessary.

I'm sorry if it confuses you. I thought the patch isn't big and rather
easy to understand :-/ Next time will split better.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
