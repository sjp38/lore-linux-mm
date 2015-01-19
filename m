Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 438AF6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 10:19:14 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so39355295pab.12
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:19:13 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id cp3si16653429pdb.184.2015.01.19.07.19.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jan 2015 07:19:12 -0800 (PST)
Date: Mon, 19 Jan 2015 18:18:54 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 3/7] cgroup: release css->id after css_free
Message-ID: <20150119151854.GA28598@esperanza>
References: <cover.1421664712.git.vdavydov@parallels.com>
 <4d7447a920522c1085ff96c08b2be71e0eb5d896.1421664712.git.vdavydov@parallels.com>
 <20150119143001.GH8140@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150119143001.GH8140@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Tejun,

On Mon, Jan 19, 2015 at 09:30:01AM -0500, Tejun Heo wrote:
> On Mon, Jan 19, 2015 at 02:23:21PM +0300, Vladimir Davydov wrote:
> > Currently, we release css->id in css_release_work_fn, right before
> > calling css_free callback, so that when css_free is called, the id may
> > have already been reused for a new cgroup.
> > 
> > I am going to use css->id to create unique names for per memcg kmem
> > caches. Since kmem caches are destroyed only on css_free, I need css->id
> > to be freed after css_free was called to avoid name clashes. This patch
> > therefore moves css->id removal to css_free_work_fn. To prevent
> > css_from_id from returning a pointer to a stale css, it makes
> > css_release_work_fn replace the css ptr at css_idr:css->id with NULL.
> 
> I think it'd be better if you create a separate id for this purpose.
> The requirement is pretty unusual and likely contradictory with other
> usages.

Could you please elaborate this? I mean, what problems do you think can
arise if we release css->id a little bit (one grace period) later?

Of course, I can introduce yet another id per memcg, but I think we have
css->id to avoid code duplication in controllers.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
