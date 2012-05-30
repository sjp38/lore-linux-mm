Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C171F6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 09:53:28 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so4272130vbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 06:53:27 -0700 (PDT)
Date: Wed, 30 May 2012 15:53:21 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v3 16/28] memcg: kmem controller charge/uncharge
 infrastructure
Message-ID: <20120530135319.GG25094@somewhere.redhat.com>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com>
 <1337951028-3427-17-git-send-email-glommer@parallels.com>
 <20120530130416.GD25094@somewhere.redhat.com>
 <4FC61B4E.2060206@parallels.com>
 <20120530133736.GF25094@somewhere.redhat.com>
 <4FC622B5.9080600@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC622B5.9080600@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, May 30, 2012 at 05:37:57PM +0400, Glauber Costa wrote:
> On 05/30/2012 05:37 PM, Frederic Weisbecker wrote:
> >Right. __mem_cgroup_get_kmem_cache() fetches the memcg of the owner
> >and calls memcg_create_cache_enqueue() which does css_tryget(&memcg->css).
> >After this tryget I think you're fine. And in-between you're safe against
> >css_set removal due to rcu_read_lock().
> >
> >I'm less clear with __mem_cgroup_new_kmem_page() though...
> 
> That one does not get memcg->css but it does call mem_cgroup_get(),
> that does prevent against the memcg structure being freed, which I
> believe to be good enough.

What if the owner calls cgroup_exit() between mem_cgroup_from_task()
and mem_cgroup_get()? The css_set which contains the memcg gets freed.
Also the reference on the memcg doesn't even prevent the css_set to
be removed, does it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
