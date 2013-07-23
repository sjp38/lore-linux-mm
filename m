Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id AE0CE6B0034
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 12:18:36 -0400 (EDT)
Received: by mail-gg0-f182.google.com with SMTP id f1so2372866ggn.41
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 09:18:35 -0700 (PDT)
Date: Tue, 23 Jul 2013 12:18:25 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH resend 3/3] vmpressure: Make sure there are no events
 queued after memcg is offlined
Message-ID: <20130723161825.GC21100@mtj.dyndns.org>
References: <1374252671-11939-1-git-send-email-mhocko@suse.cz>
 <1374252671-11939-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374252671-11939-3-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 19, 2013 at 06:51:11PM +0200, Michal Hocko wrote:
> vmpressure is called synchronously from the reclaim where the
> target_memcg is guaranteed to be alive but the eventfd is signaled from
> the work queue context. This means that memcg (along with vmpressure
> structure which is embedded into it) might go away while the work item
> is pending which would result in use-after-release bug.
> 
> We have two possible ways how to fix this. Either vmpressure pins memcg
> before it schedules vmpr->work and unpin it in vmpressure_work_fn or
> explicitely flush the work item from the css_offline context (as
> suggested by Tejun).
> 
> This patch implements the later one and it introduces vmpressure_cleanup
> which flushes the vmpressure work queue item item. It hooks into
> mem_cgroup_css_offline after the memcg itself is cleaned up.
> 
> Reported-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
