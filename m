Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 92EDC6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:51:07 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l68so17333028wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:51:07 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id e124si2515208wma.114.2016.03.11.04.51.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 04:51:06 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id l68so17332518wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:51:06 -0800 (PST)
Date: Fri, 11 Mar 2016 13:51:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: zap
 task_struct->memcg_oom_{gfp_mask,order}
Message-ID: <20160311125104.GM27701@dhcp22.suse.cz>
References: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
 <20160311115450.GH27701@dhcp22.suse.cz>
 <20160311123900.GM1946@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160311123900.GM1946@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 11-03-16 15:39:00, Vladimir Davydov wrote:
> On Fri, Mar 11, 2016 at 12:54:50PM +0100, Michal Hocko wrote:
> > On Fri 11-03-16 13:12:47, Vladimir Davydov wrote:
> > > These fields are used for dumping info about allocation that triggered
> > > OOM. For cgroup this information doesn't make much sense, because OOM
> > > killer is always invoked from page fault handler.
> > 
> > The oom killer is indeed invoked in a different context but why printing
> > the original mask and order doesn't make any sense? Doesn't it help to
> > see that the reclaim has failed because of GFP_NOFS?
> 
> I don't see how this can be helpful. How would you use it?

If we start seeing GFP_NOFS triggered OOMs we might be enforced to
rethink our current strategy to ignore this charge context for OOM.
 
> Wouldn't it be better to print err msg in try_charge anyway?

Wouldn't that lead to excessive amount of logged messages?

> ...
> > So it doesn't even seem to save any space in the config I am using. Does
> > it shrink the size of the structure for you?
> 
> There are several hundred bytes left in task_struct for its size to
> exceed 2 pages threshold and hence increase slab order, but it doesn't
> mean we don't need to be conservative and do our best to spare some
> space for future users that can't live w/o adding new fields.

I do agree that we should hard to make task_struct as small as possible
but now you are throwing a potentially useful information, replace it by
something that might be misleading and do not shrink the struct size.
This doesn't sound like an universal win to me. The situation would be
much more different if this was the last few bytes which gets us to a
higher order of course.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
