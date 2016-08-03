Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64D6C6B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 07:46:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id i199so439508294ioi.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 04:46:48 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50120.outbound.protection.outlook.com. [40.107.5.120])
        by mx.google.com with ESMTPS id p125si4257487oih.232.2016.08.03.04.46.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Aug 2016 04:46:47 -0700 (PDT)
Date: Wed, 3 Aug 2016 14:46:40 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160803114639.GI13263@esperanza>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <20160802160025.GB28900@dhcp22.suse.cz>
 <20160803095049.GG13263@esperanza>
 <20160803110941.GA19196@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160803110941.GA19196@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 03, 2016 at 01:09:42PM +0200, Michal Hocko wrote:
> On Wed 03-08-16 12:50:49, Vladimir Davydov wrote:
> > On Tue, Aug 02, 2016 at 06:00:26PM +0200, Michal Hocko wrote:
> > > On Tue 02-08-16 18:00:48, Vladimir Davydov wrote:
> > ...
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index 3be791afd372..4ae12effe347 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -4036,6 +4036,24 @@ static void mem_cgroup_id_get(struct mem_cgroup *memcg)
> > > >  	atomic_inc(&memcg->id.ref);
> > > >  }
> > > >  
> > > > +static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> > > > +{
> > > > +	while (!atomic_inc_not_zero(&memcg->id.ref)) {
> > > > +		/*
> > > > +		 * The root cgroup cannot be destroyed, so it's refcount must
> > > > +		 * always be >= 1.
> > > > +		 */
> > > > +		if (memcg == root_mem_cgroup) {
> > > > +			VM_BUG_ON(1);
> > > > +			break;
> > > > +		}
> > > 
> > > why not simply VM_BUG_ON(memcg == root_mem_cgroup)?
> > 
> > Because with DEBUG_VM disabled we could wind up looping forever here if
> > the refcount of the root_mem_cgroup got screwed up. On production
> > kernels, it's better to break the loop and carry on closing eyes on
> > diverging counters rather than getting a lockup.
> 
> Wouldn't this just paper over a real bug? Anyway I will not insist but
> making the code more complex just to pretend we can handle a situation
> gracefully doesn't sound right to me.

But we can handle this IMO. AFAICS diverging id refcount will typically
result in leaking swap charges, which aren't even a real resource. At
worst, we can leak an offline mem_cgroup, which is also not critical
enough to crash the production system.

I see your concern of papering over a bug though. What about adding a
warning there?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1c0aa59fd333..8c8e68becee9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4044,7 +4044,7 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
 		 * The root cgroup cannot be destroyed, so it's refcount must
 		 * always be >= 1.
 		 */
-		if (memcg == root_mem_cgroup) {
+		if (WARN_ON_ONCE(memcg == root_mem_cgroup)) {
 			VM_BUG_ON(1);
 			break;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
