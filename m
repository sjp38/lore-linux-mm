Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id C68E06B0003
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 03:51:53 -0500 (EST)
Received: by mail-lf0-f47.google.com with SMTP id y184so85828004lfc.1
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 00:51:53 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 203si12947047lfi.64.2015.12.19.00.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Dec 2015 00:51:52 -0800 (PST)
Date: Sat, 19 Dec 2015 11:51:38 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2] mm: memcontrol: fix possible memcg leak due to
 interrupted reclaim
Message-ID: <20151219085137.GV28521@esperanza>
References: <1450182697-11049-1-git-send-email-vdavydov@virtuozzo.com>
 <20151217150217.a02c264ce9b5335b02bae888@linux-foundation.org>
 <20151218153202.GS28521@esperanza>
 <20151218160041.GA4201@cmpxchg.org>
 <20151218162405.GU28521@esperanza>
 <20151218144004.6ec6189817b64e04d9405001@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151218144004.6ec6189817b64e04d9405001@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, stable@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 18, 2015 at 02:40:04PM -0800, Andrew Morton wrote:
> On Fri, 18 Dec 2015 19:24:05 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> 
> > 
> > OK, got it, thanks. Here goes the incremental patch (it should also fix
> > the warning regarding unused cmpxchg returned value):
> > ---
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index fc25dc211eaf..908c075e04eb 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -864,7 +864,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  			 * might block it. So we clear iter->position right
> >  			 * away.
> >  			 */
> > -			cmpxchg(&iter->position, pos, NULL);
> > +			(void)cmpxchg(&iter->position, pos, NULL);
> 
> No, this doesn't actually squish the __must_check warning.

The warning was caused not by a __must_check annotation - using it for
cmpxchg would be just wrong - it was caused by type conversion done in
expansion of cmpxchg macro:

   arch/m68k/include/asm/cmpxchg.h:121:3: warning: value computed is not used [-Wunused-value]
     ((__typeof__(*(ptr)))__cmpxchg((ptr), (unsigned long)(o),     \
      ^

(see http://www.spinics.net/lists/linux-mm/msg99133.html)

Type conversion to (void) helps suppressing this warning, and it seems
this is what is done commonly (e.g. see kernel/rcu/tree_plugin.h)

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
