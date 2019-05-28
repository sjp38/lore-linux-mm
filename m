Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DC33C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:18:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E257B2166E
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:18:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E257B2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81B5E6B0273; Tue, 28 May 2019 03:18:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D5B16B0275; Tue, 28 May 2019 03:18:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 694A76B0276; Tue, 28 May 2019 03:18:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 16DA36B0273
	for <linux-mm@kvack.org>; Tue, 28 May 2019 03:18:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x16so31697251edm.16
        for <linux-mm@kvack.org>; Tue, 28 May 2019 00:18:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zM6VOn1Oq5JKVtI7g9TedwEI6pfdj9KZgZX8yZ2hl/8=;
        b=cWCmHILc0OhAsBhcf3Pe7TmCkYIBZibuBcGKms9oy+ZYEMrZeBrgWOx9y+thaNptSQ
         Z55JtFSvF1we/dJlXSWVRJzPWUXnDhWKeNQguQokMWjJ8p9xiNNk7mByUVWvgIzLQSMD
         V9T+xSJiULtM1eXG0xp3YTxdomJ1N865Fe2m3+BQjU+d+DcaMrX9EiPrE/YDdORO+UCy
         9jeq//4TiJgi0902BrE05ty9KExF4B1FP7WmIlY3D/PLQ0PaWd4ZbfMQxyCFIoLwsLOk
         2No+f9Hj8bVNf2qPhJuwb+Tk6VuEssfpth4NMrAOMgs5BilWbzuIMizh9eOjOEygj8f7
         lu2A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWgDMgZnbiIwMjqlyaBMij+7aG8ZnuOypIgX7/yry2tAdSnVQcO
	j0SQC8YnDHJcD9Q7a9hpxQoP5yUUO682uq5rgTejFNU3z4yrh+gVhsT1He0jAbpZpc2EoEol8n2
	CdkjXQRI4VqiI4MIxg26oCY4sqh/Jy4R7PDWZpw8HMNwsxMM/ZJ4vOYSBXst87u0=
X-Received: by 2002:aa7:ca4f:: with SMTP id j15mr126417632edt.276.1559027928628;
        Tue, 28 May 2019 00:18:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvChfBHqK+oae99YDvZ10M6e5LK2GKcB9C8QvfJ9jr/7aP1tCGbNQSW4rrpfJJ6u5k9j+W
X-Received: by 2002:aa7:ca4f:: with SMTP id j15mr126417568edt.276.1559027927651;
        Tue, 28 May 2019 00:18:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559027927; cv=none;
        d=google.com; s=arc-20160816;
        b=Qx2C+Sa/lePBPfE6V6NQOWIfet0zWb8PFZYxCaRvu0JuMXYIzPnAP8NJI+2vJs+DW/
         +7q6cEnt1/lA0UoESzCOE/B15No/N/M+f0iZrTO8y9fvNuaz5UIY/00ctYvZw5MAoVvm
         /ae+fUmlvh45w3cNmcxe8TohzDXrfvOFbAZVUqGdlj/bHxIzyNMYNCkUvpqKXsuXfItQ
         rdyefAWk4ssKSeHUk62BUbjI5K12flowPb+6FCfJNEJmJRhaNZOHQ0zKKYmUM9NT2oWp
         1BwlKWp0kbDstQ6yarjK5F1Tb3lwCbsdAxILtZ9V18YEFg3Wv8UkDJm3GeVnMLhd2P//
         Z87w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zM6VOn1Oq5JKVtI7g9TedwEI6pfdj9KZgZX8yZ2hl/8=;
        b=wNpfzT5QsU+4JOb8oJJ1Edt9EBisqEJ3LqMA+ABv6z2vlSrRUkzsZSeeVJf9ZxQpy1
         v5w+AJkspU0a5/e73WJfg61VVeOJRDYmEJ3AkW3oyUUjXbHFW607qiWOTEFl57nlPxPU
         qXkcYUm2bfm2VKgvWMUW1aA9Kg0itIIU13/DmsjbnPYiYpU72dlGmtoPmP7X2Wds5fsI
         teBM8mic9YzxgEXpB4uX93CkoeBO3a+DjCWzENbo8ku7bg6L4qNGweiG+8BFzyeydRIR
         QK/OKuY1aFF3lcFQ/Z2GRrm0nudAKUG9wKweGn5F8QExlMZmjPrc4FEG/1UzHo+z7xh9
         PX/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c33si3424613edb.303.2019.05.28.00.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 00:18:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C2D67AE4D;
	Tue, 28 May 2019 07:18:46 +0000 (UTC)
Date: Tue, 28 May 2019 09:18:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Chris Down <chris@chrisdown.name>,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] mm, memcg: introduce memory.events.local
Message-ID: <20190528071845.GN1658@dhcp22.suse.cz>
References: <20190527174643.209172-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527174643.209172-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 10:46:43, Shakeel Butt wrote:
> The memory controller in cgroup v2 exposes memory.events file for each
> memcg which shows the number of times events like low, high, max, oom
> and oom_kill have happened for the whole tree rooted at that memcg.
> Users can also poll or register notification to monitor the changes in
> that file. Any event at any level of the tree rooted at memcg will
> notify all the listeners along the path till root_mem_cgroup. There are
> existing users which depend on this behavior.
> 
> However there are users which are only interested in the events
> happening at a specific level of the memcg tree and not in the events in
> the underlying tree rooted at that memcg. One such use-case is a
> centralized resource monitor which can dynamically adjust the limits of
> the jobs running on a system. The jobs can create their sub-hierarchy
> for their own sub-tasks. The centralized monitor is only interested in
> the events at the top level memcgs of the jobs as it can then act and
> adjust the limits of the jobs. Using the current memory.events for such
> centralized monitor is very inconvenient. The monitor will keep
> receiving events which it is not interested and to find if the received
> event is interesting, it has to read memory.event files of the next
> level and compare it with the top level one. So, let's introduce
> memory.events.local to the memcg which shows and notify for the events
> at the memcg level.
> 
> Now, does memory.stat and memory.pressure need their local versions.
> IMHO no due to the no internal process contraint of the cgroup v2. The
> memory.stat file of the top level memcg of a job shows the stats and
> vmevents of the whole tree. The local stats or vmevents of the top level
> memcg will only change if there is a process running in that memcg but
> v2 does not allow that. Similarly for memory.pressure there will not be
> any process in the internal nodes and thus no chance of local pressure.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Roman Gushchin <guro@fb.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

As there seems to be a larger agreement that the default behavior of
memory.events is going to be hierarchical then this addition makes a lot
of sense.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Changelog since v2:
> - Added documentation.
> 
> Changelog since v1:
> - refactor memory_events_show to share between events and events.local
> 
>  Documentation/admin-guide/cgroup-v2.rst | 10 ++++++++
>  include/linux/memcontrol.h              |  7 ++++-
>  mm/memcontrol.c                         | 34 +++++++++++++++++--------
>  3 files changed, 40 insertions(+), 11 deletions(-)
> 
> diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
> index 19c4e78666ff..0e961fc90cd9 100644
> --- a/Documentation/admin-guide/cgroup-v2.rst
> +++ b/Documentation/admin-guide/cgroup-v2.rst
> @@ -1119,6 +1119,11 @@ PAGE_SIZE multiple when read back.
>  	otherwise, a value change in this file generates a file
>  	modified event.
>  
> +	Note that all fields in this file are hierarchical and the
> +	file modified event can be generated due to an event down the
> +	hierarchy. For for the local events at the cgroup level see
> +	memory.events.local.
> +
>  	  low
>  		The number of times the cgroup is reclaimed due to
>  		high memory pressure even though its usage is under
> @@ -1158,6 +1163,11 @@ PAGE_SIZE multiple when read back.
>  		The number of processes belonging to this cgroup
>  		killed by any kind of OOM killer.
>  
> +  memory.events.local
> +	Similar to memory.events but the fields in the file are local
> +	to the cgroup i.e. not hierarchical. The file modified event
> +	generated on this file reflects only the local events.
> +
>    memory.stat
>  	A read-only flat-keyed file which exists on non-root cgroups.
>  
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 36bdfe8e5965..de77405eec46 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -239,8 +239,9 @@ struct mem_cgroup {
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
>  
> -	/* memory.events */
> +	/* memory.events and memory.events.local */
>  	struct cgroup_file events_file;
> +	struct cgroup_file events_local_file;
>  
>  	/* handle for "memory.swap.events" */
>  	struct cgroup_file swap_events_file;
> @@ -286,6 +287,7 @@ struct mem_cgroup {
>  	atomic_long_t		vmevents_local[NR_VM_EVENT_ITEMS];
>  
>  	atomic_long_t		memory_events[MEMCG_NR_MEMORY_EVENTS];
> +	atomic_long_t		memory_events_local[MEMCG_NR_MEMORY_EVENTS];
>  
>  	unsigned long		socket_pressure;
>  
> @@ -761,6 +763,9 @@ static inline void count_memcg_event_mm(struct mm_struct *mm,
>  static inline void memcg_memory_event(struct mem_cgroup *memcg,
>  				      enum memcg_memory_event event)
>  {
> +	atomic_long_inc(&memcg->memory_events_local[event]);
> +	cgroup_file_notify(&memcg->events_local_file);
> +
>  	do {
>  		atomic_long_inc(&memcg->memory_events[event]);
>  		cgroup_file_notify(&memcg->events_file);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2713b45ec3f0..a57dfcc4c4a4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5630,21 +5630,29 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
>  	return nbytes;
>  }
>  
> +static void __memory_events_show(struct seq_file *m, atomic_long_t *events)
> +{
> +	seq_printf(m, "low %lu\n", atomic_long_read(&events[MEMCG_LOW]));
> +	seq_printf(m, "high %lu\n", atomic_long_read(&events[MEMCG_HIGH]));
> +	seq_printf(m, "max %lu\n", atomic_long_read(&events[MEMCG_MAX]));
> +	seq_printf(m, "oom %lu\n", atomic_long_read(&events[MEMCG_OOM]));
> +	seq_printf(m, "oom_kill %lu\n",
> +		   atomic_long_read(&events[MEMCG_OOM_KILL]));
> +}
> +
>  static int memory_events_show(struct seq_file *m, void *v)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
>  
> -	seq_printf(m, "low %lu\n",
> -		   atomic_long_read(&memcg->memory_events[MEMCG_LOW]));
> -	seq_printf(m, "high %lu\n",
> -		   atomic_long_read(&memcg->memory_events[MEMCG_HIGH]));
> -	seq_printf(m, "max %lu\n",
> -		   atomic_long_read(&memcg->memory_events[MEMCG_MAX]));
> -	seq_printf(m, "oom %lu\n",
> -		   atomic_long_read(&memcg->memory_events[MEMCG_OOM]));
> -	seq_printf(m, "oom_kill %lu\n",
> -		   atomic_long_read(&memcg->memory_events[MEMCG_OOM_KILL]));
> +	__memory_events_show(m, memcg->memory_events);
> +	return 0;
> +}
> +
> +static int memory_events_local_show(struct seq_file *m, void *v)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
>  
> +	__memory_events_show(m, memcg->memory_events_local);
>  	return 0;
>  }
>  
> @@ -5806,6 +5814,12 @@ static struct cftype memory_files[] = {
>  		.file_offset = offsetof(struct mem_cgroup, events_file),
>  		.seq_show = memory_events_show,
>  	},
> +	{
> +		.name = "events.local",
> +		.flags = CFTYPE_NOT_ON_ROOT,
> +		.file_offset = offsetof(struct mem_cgroup, events_local_file),
> +		.seq_show = memory_events_local_show,
> +	},
>  	{
>  		.name = "stat",
>  		.flags = CFTYPE_NOT_ON_ROOT,
> -- 
> 2.22.0.rc1.257.g3120a18244-goog

-- 
Michal Hocko
SUSE Labs

