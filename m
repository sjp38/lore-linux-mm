Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id C1B846B0085
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 11:29:18 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q108so4630826qgd.5
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 08:29:18 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id z19si13718407qaq.59.2014.06.06.08.29.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 08:29:18 -0700 (PDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so4810562qgd.29
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 08:29:17 -0700 (PDT)
Date: Fri, 6 Jun 2014 11:29:14 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit
 reclaim
Message-ID: <20140606152914.GA14001@htj.dyndns.org>
References: <20140606144421.GE26253@dhcp22.suse.cz>
 <1402066010-25901-1-git-send-email-mhocko@suse.cz>
 <1402066010-25901-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402066010-25901-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello, Michal.

On Fri, Jun 06, 2014 at 04:46:50PM +0200, Michal Hocko wrote:
> +choice
> +	prompt "Memory Resource Controller reclaim protection"
> +	depends on MEMCG
> +	help

Why is this necessary?

- This doesn't affect boot.

- memcg requires runtime config *anyway*.

- The config is inherited from the parent, so the default flipping
  isn't exactly difficult.

Please drop the kconfig option.

> +static int mem_cgroup_write_reclaim_strategy(struct cgroup_subsys_state *css, struct cftype *cft,
> +			    char *buffer)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	int ret = 0;
> +
> +	if (!strncmp(buffer, "low_limit_guarantee",
> +				sizeof("low_limit_guarantee"))) {
> +		memcg->hard_low_limit = true;
> +	} else if (!strncmp(buffer, "low_limit_best_effort",
> +				sizeof("low_limit_best_effort"))) {
> +		memcg->hard_low_limit = false;
> +	} else
> +		ret = -EINVAL;
> +
> +	return ret;
> +}

So, ummm, this raises a big red flag for me.  You're now implementing
two behaviors in a mostly symmetric manner to soft/hard limits but
choosing a completely different scheme in how they're configured
without any rationale.

* Are you sure soft and hard guarantees aren't useful when used in
  combination?  If so, why would that be the case?

* We have pressure monitoring interface which can be used for soft
  limit pressure monitoring.  How should breaching soft guarantee be
  factored into that?  There doesn't seem to be any way of notifying
  that at the moment?  Wouldn't we want that to be integrated into the
  same mechanism?

What scares me the most is that you don't even seem to have noticed
the asymmetry and are proposing userland-facing interface without
actually thinking things through.  This is exactly how we've been
getting into trouble.

For now, for everything.

 Nacked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
