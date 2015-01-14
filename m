Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id E07FE6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 11:17:50 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id 10so8778715lbg.1
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:17:50 -0800 (PST)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id v5si48777499wje.41.2015.01.14.08.17.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 08:17:49 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id l15so29310395wiw.2
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:17:49 -0800 (PST)
Date: Wed, 14 Jan 2015 17:17:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for
 memory
Message-ID: <20150114161747.GH4706@dhcp22.suse.cz>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
 <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

I have overlooked the `none' setting...

On Thu 08-01-15 23:15:04, Johannes Weiner wrote:
[...]
> +static int memory_low_show(struct seq_file *m, void *v)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> +	unsigned long low = ACCESS_ONCE(memcg->low);
> +
> +	if (low == 0)
> +		seq_printf(m, "none\n");
> +	else
> +		seq_printf(m, "%llu\n", (u64)low * PAGE_SIZE);
> +
> +	return 0;
> +}

This is really confusing. What if somebody wants to protect a group
from being reclaimed? One possible and natural way would by copying
memory.max value but then `none' means something else completely.

Besides that why to call 0, which has a clear meaning, any other name?

Now that I think about the naming `none' doesn't sound that great for
max resp. high either. If for nothing else then for the above copy
example (who knows what shows up later). Sure, a huge number is bad
as well for reasons you have mentioned in other email. `resource_max'
sounds like a better fit to me. But I am lame at naming.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
