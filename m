Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5477B6B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 15:03:06 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p65so5058239wmp.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:03:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 143si21906052wme.24.2016.02.29.12.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 12:03:05 -0800 (PST)
Date: Mon, 29 Feb 2016 15:02:55 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: reset memory.low on css offline
Message-ID: <20160229200255.GA32539@cmpxchg.org>
References: <1456766193-16255-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456766193-16255-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Mon, Feb 29, 2016 at 08:16:33PM +0300, Vladimir Davydov wrote:
> When a cgroup directory is removed, the memory cgroup subsys state does
> not disappear immediately. Instead, it's left hanging around until the
> last reference to it is gone, which implies reclaiming all pages from
> its lruvec.
> 
> In the unified hierarchy, there's the memory.low knob, which can be used
> to set a best-effort protection for a memory cgroup - the reclaimer
> first scans those cgroups whose consumption is above memory.low, and
> only if it fails to reclaim enough pages, it gets to the rest.
> 
> Currently this protection is not reset when the cgroup directory is
> removed. As a result, if a dead memory cgroup has a lot of page cache
> charged to it and a high value of memory.low, it will result in higher
> pressure exerted on live cgroups, and userspace will have no ways to
> detect such consumers and reconfigure memory.low properly.
> 
> To fix this, let's reset memory.low on css offline.

We already have mem_cgroup_css_reset() for soft-offlining a css - when
the css is asked to be disabled but another subsystem still uses it.
Can we just call that function during offline as well? The css can be
around for quite a bit after the user deleted it. Eliminating *any*
user-supplied configurations and zapping it back to defaults makes
sense in general, so that we never have to worry about any remnants.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
