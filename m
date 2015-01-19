Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4BED36B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:30:06 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id w8so24026054qac.3
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:30:06 -0800 (PST)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com. [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id c69si14935049qga.84.2015.01.19.06.30.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 06:30:05 -0800 (PST)
Received: by mail-qa0-f49.google.com with SMTP id v8so23961796qal.8
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:30:04 -0800 (PST)
Date: Mon, 19 Jan 2015 09:30:01 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -mm v2 3/7] cgroup: release css->id after css_free
Message-ID: <20150119143001.GH8140@htj.dyndns.org>
References: <cover.1421664712.git.vdavydov@parallels.com>
 <4d7447a920522c1085ff96c08b2be71e0eb5d896.1421664712.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d7447a920522c1085ff96c08b2be71e0eb5d896.1421664712.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 19, 2015 at 02:23:21PM +0300, Vladimir Davydov wrote:
> Currently, we release css->id in css_release_work_fn, right before
> calling css_free callback, so that when css_free is called, the id may
> have already been reused for a new cgroup.
> 
> I am going to use css->id to create unique names for per memcg kmem
> caches. Since kmem caches are destroyed only on css_free, I need css->id
> to be freed after css_free was called to avoid name clashes. This patch
> therefore moves css->id removal to css_free_work_fn. To prevent
> css_from_id from returning a pointer to a stale css, it makes
> css_release_work_fn replace the css ptr at css_idr:css->id with NULL.

I think it'd be better if you create a separate id for this purpose.
The requirement is pretty unusual and likely contradictory with other
usages.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
