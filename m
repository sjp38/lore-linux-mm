Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AA3E26B010F
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 11:48:55 -0400 (EDT)
Received: by mail-ia0-f171.google.com with SMTP id x2so925017iad.16
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 08:48:55 -0700 (PDT)
Date: Mon, 8 Apr 2013 08:48:47 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/8] cgroup: implement cgroup_from_id()
Message-ID: <20130408154847.GE3021@htj.dyndns.org>
References: <51627DA9.7020507@huawei.com>
 <51627DEB.4090104@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51627DEB.4090104@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Oops, one more thing.

On Mon, Apr 08, 2013 at 04:20:59PM +0800, Li Zefan wrote:
> -	cgrp->id = ida_simple_get(&root->cgroup_ida, 1, 0, GFP_KERNEL);
> +	cgrp->id = idr_alloc(&root->cgroup_idr, cgrp, 1, 0, GFP_KERNEL);

This will allow lookups to return half-initialized cgroup, which
shouldn't happen.  Either idr_alloc() should be moved to after
initialization of other fields are finished, or it should be called
with NULL @ptr with idr_replace() added at the end to install @cgrp.

Similarly, the removal path should guarantee that the object is
removed from idr *before* its grace period starts.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
