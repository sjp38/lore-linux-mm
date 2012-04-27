Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 05A7A6B0105
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 16:32:04 -0400 (EDT)
Received: by dadq36 with SMTP id q36so1549469dad.8
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 13:32:04 -0700 (PDT)
Date: Fri, 27 Apr 2012 13:31:59 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH 7/9 v2] cgroup: avoid attaching task to a cgroup
 under rmdir()
Message-ID: <20120427203159.GL26595@google.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
 <4F9A366E.9020307@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F9A366E.9020307@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

On Fri, Apr 27, 2012 at 03:02:22PM +0900, KAMEZAWA Hiroyuki wrote:
> attach_task() is done under cgroup_mutex() but ->pre_destroy() callback
> in rmdir() isn't called under cgroup_mutex().
> 
> It's better to avoid attaching a task to a cgroup which
> is under pre_destroy(). Considering memcg, the attached task may
> increase resource usage after memcg's pre_destroy() confirms that
> memcg is empty. This is not good.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hmm... once memcg's pre_destroy() can't fail, I think what we should
do is marking a cgroup DEAD before calling pre_destroy() and the
existing cgroup_is_removed() check should be enough.  Patches upto
this point already make ->pre_destroy() not fail, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
