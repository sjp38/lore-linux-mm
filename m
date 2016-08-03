Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBC7C6B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 10:31:27 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u142so435205001oia.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 07:31:27 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0113.outbound.protection.outlook.com. [104.47.2.113])
        by mx.google.com with ESMTPS id 94si4338388oti.15.2016.08.03.07.31.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Aug 2016 07:31:26 -0700 (PDT)
Date: Wed, 3 Aug 2016 17:31:17 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160803143117.GK13263@esperanza>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <20160802160025.GB28900@dhcp22.suse.cz>
 <20160803095049.GG13263@esperanza>
 <20160803110941.GA19196@dhcp22.suse.cz>
 <20160803114639.GI13263@esperanza>
 <20160803141203.GA12838@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160803141203.GA12838@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 03, 2016 at 10:12:03AM -0400, Johannes Weiner wrote:
> On Wed, Aug 03, 2016 at 02:46:40PM +0300, Vladimir Davydov wrote:
...
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 1c0aa59fd333..8c8e68becee9 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4044,7 +4044,7 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
> >  		 * The root cgroup cannot be destroyed, so it's refcount must
> >  		 * always be >= 1.
> >  		 */
> > -		if (memcg == root_mem_cgroup) {
> > +		if (WARN_ON_ONCE(memcg == root_mem_cgroup)) {
> >  			VM_BUG_ON(1);
> >  			break;
> >  		}
> 
> The WARN_ON_ONCE() makes sense to me. But if we warn on all configs
> anyway, the VM_BUG_ON() doesn't provide any additional value. Anybody
> who is testing new code and enables DEBUG_VM should notice a warning
> without requiring the kernel to blow up in their face; it also allows
> them to check other state that is not necessarily available in BUG().

Personally, I prefer to crash the kernel as early as possible when
debugging to get vmcore for further investigation. Judging by
mem_cgroup_update_lru_size(), I'm not alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
