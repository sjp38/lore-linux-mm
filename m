Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 475BA6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:26:30 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so1798316wiv.4
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:26:29 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id t11si4139302wib.5.2014.06.18.13.26.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:26:28 -0700 (PDT)
Date: Wed, 18 Jun 2014 16:26:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 03/12] mm: huge_memory: use GFP_TRANSHUGE when charging
 huge pages
Message-ID: <20140618202617.GE7331@cmpxchg.org>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <1402948472-8175-4-git-send-email-hannes@cmpxchg.org>
 <20140617142317.GD19886@dhcp22.suse.cz>
 <20140617153814.GB7331@cmpxchg.org>
 <20140617162747.GB9572@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140617162747.GB9572@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 17, 2014 at 06:27:47PM +0200, Michal Hocko wrote:
> On Tue 17-06-14 11:38:14, Johannes Weiner wrote:
> > On Tue, Jun 17, 2014 at 04:23:17PM +0200, Michal Hocko wrote:
> [...]
> > > @@ -2647,7 +2645,7 @@ retry:
> > >  	if (fatal_signal_pending(current))
> > >  		goto bypass;
> > >  
> > > -	if (!oom)
> > > +	if (!oom_gfp_allowed(gfp_mask))
> > >  		goto nomem;
> > 
> > We don't actually need that check: if __GFP_NORETRY is set, we goto
> > nomem directly after reclaim fails and don't even reach here.
> 
> I meant it for further robustness. If we ever change oom_gfp_allowed in
> future and have new and unexpected users then we should back off.  Or
> maybe WARN_ON(!oom_gfp_allowed(gfp_mask)) would be more appropriate to
> catch those and fix the charging code or the charger?

There is a slight deviation from the page allocator in that we could
potentially invoke OOM on NOFS charges, but I'm not sure whether NOFS
flags are wrong to enter the memcg charge code, per se, so the WARN_ON
would appear like a fairly random restriction to have...

> > From eda800d2aa2376d347d6d4f7660e3450bd4c5dbb Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Tue, 17 Jun 2014 11:10:59 -0400
> > Subject: [patch] mm: memcontrol: remove explicit OOM parameter in charge path
> > 
> > For the page allocator, __GFP_NORETRY implies that no OOM should be
> > triggered, whereas memcg has an explicit parameter to disable OOM.
> > 
> > The only callsites that want OOM disabled are THP charges and charge
> > moving.  THP already uses __GFP_NORETRY and charge moving can use it
> > as well - one full reclaim cycle should be plenty.  Switch it over,
> > then remove the OOM parameter.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
