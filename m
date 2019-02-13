Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 921AFC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:47:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B147222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:47:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B147222BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2D948E0002; Wed, 13 Feb 2019 07:47:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDE488E0001; Wed, 13 Feb 2019 07:47:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA5A98E0002; Wed, 13 Feb 2019 07:47:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9EA8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:47:32 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x47so951826eda.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:47:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9+AhT7wxPK8BbWrX+EiXeGWN925xjs9wsoAKs4x9tow=;
        b=aCGEQu6eQ3NLPuKOwGHO5/vyqhtPpL3SUq/sRvTitHHsuOSQY0IMmKJ1yMajU6g0v8
         VLooDPS628657832ZgULYb0/H6ughe98U+E4YXzHt/hH7Dp8b+gswiObtyKwoOpvLYzh
         /m0BLt0GEawFvbVSpokX/36XlZFHZiarM1JslJyin9ECBSmV1c976eeAzILM218qbEAR
         m3tRjGEJPmmaVFlxXHAbvXM7vXiHpUJgAElHdl4WE3YZMM/QKuUMImNm6BRk7ePRx+mB
         QFx/ScyiO8dC+a3W9+3zD4+zYeg1pSkryqPDZuB2qaXJyEmIJXQ47y+W/XQBynjJ2xUZ
         5IrQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaugDsrzvZbKp/v50PXQYqUeqxfp7iD5bVoKQyeCUYWjB7rH5Om
	+09gPPcHhnbbSJvDH0N7Zw3rDVZHSkrqGlZJ+vghQHg6xzxM890aAQkLVgqleIRUxSgPXz5dhcI
	myOJdhKckIRx775zuuXjsC9nn2+qtJ8LMRQUJqVYIZFVPTbarLS9cVgqiy+ZARu8=
X-Received: by 2002:a50:e3cb:: with SMTP id c11mr293907edm.80.1550062051749;
        Wed, 13 Feb 2019 04:47:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYyzANCKBM38HtPUxT3dv37NZHInWC3Jk0mTDFeQ63whgMmYEb+nGbWObo57XRbwrcUmlL/
X-Received: by 2002:a50:e3cb:: with SMTP id c11mr293833edm.80.1550062050487;
        Wed, 13 Feb 2019 04:47:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550062050; cv=none;
        d=google.com; s=arc-20160816;
        b=ZOG1I9ko10aa0y4uS51gztyU4dRS7mAGDLU1zNBEAu9hpm4o/addcQ4ZcwuWpF4C3F
         6FRd4wqMo3q2cR3+eWAfYwvHFG+OodWGedziTYNtRUNX9UEZL0WkZoS/Z/EF37GoWOCg
         neQTEKmVom+rja3PowhMkiWeQ1d8wT02k1SCIPPINa+i9AIj2M1+2CrwwCkFvmt7UAW1
         vmlDL/Sr1Y17bAbYbJYAyFyDDLDb0hECZBCbZjLHLsqxPUJO997RtN3Uul7KXE3g/uop
         4tX1Tpq4tyGsZXZ/3Wjwm1+6eSxG16IIHXI8LCD0hmUGmvNPaXTKDetPR55fFiJrk9tS
         Tn2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9+AhT7wxPK8BbWrX+EiXeGWN925xjs9wsoAKs4x9tow=;
        b=BSZTKdJ/zAJZct+6OpKeeAjr7MCPBftBFqdX5GPRMyLaJO3HiG2ozMERHRv81VbhiN
         PPvdVhCLlG1ELmWwwNGbUCRXHyGm5DpvlBHJExmHL+ieVfG3U+cJLc4FIVtXRB4kGsob
         q1HW44zp4LES6YUPCRJa9lAf0wq9Ceu4r4WI+bZmhOOmNtGKar5eFX3JbwaBxc+qWkTY
         aALG9XuyVGeNh3q0mCA626KSTVWVJ5kOapdLY8ttL0ZaemOCW//XJvuolGOzHvTJFgvd
         fYS5VNHariwXAlURtvw7gwxjLj6Gqe1iCjc9Zhopml6NZ3OLGVaTD7ZLWYMQyFpK0lMg
         6YHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si4292492eda.338.2019.02.13.04.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 04:47:30 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 03C52AF6F;
	Wed, 13 Feb 2019 12:47:29 +0000 (UTC)
Date: Wed, 13 Feb 2019 13:47:29 +0100
From: Michal Hocko <mhocko@kernel.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, tj@kernel.org, hannes@cmpxchg.org,
	guro@fb.com, dennis@kernel.org, chris@chrisdown.name,
	cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
Message-ID: <20190213124729.GI4525@dhcp22.suse.cz>
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212224542.ZW63a%akpm@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 14:45:42, Andrew Morton wrote:
[...]
> From: Chris Down <chris@chrisdown.name>
> Subject: mm, memcg: consider subtrees in memory.events
> 
> memory.stat and other files already consider subtrees in their output, and
> we should too in order to not present an inconsistent interface.
> 
> The current situation is fairly confusing, because people interacting with
> cgroups expect hierarchical behaviour in the vein of memory.stat,
> cgroup.events, and other files.  For example, this causes confusion when
> debugging reclaim events under low, as currently these always read "0" at
> non-leaf memcg nodes, which frequently causes people to misdiagnose breach
> behaviour.  The same confusion applies to other counters in this file when
> debugging issues.
> 
> Aggregation is done at write time instead of at read-time since these
> counters aren't hot (unlike memory.stat which is per-page, so it does it
> at read time), and it makes sense to bundle this with the file
> notifications.
> 
> After this patch, events are propagated up the hierarchy:
> 
>     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
>     low 0
>     high 0
>     max 0
>     oom 0
>     oom_kill 0
>     [root@ktst ~]# systemd-run -p MemoryMax=1 true
>     Running as unit: run-r251162a189fb4562b9dabfdc9b0422f5.service
>     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
>     low 0
>     high 0
>     max 7
>     oom 1
>     oom_kill 1
> 
> As this is a change in behaviour, this can be reverted to the old
> behaviour by mounting with the `memory_localevents' flag set.  However, we
> use the new behaviour by default as there's a lack of evidence that there
> are any current users of memory.events that would find this change
> undesirable.
> 
> Link: http://lkml.kernel.org/r/20190208224419.GA24772@chrisdown.name
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Dennis Zhou <dennis@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

FTR: As I've already said here [1] I can live with this change as long
as there is a larger consensus among cgroup v2 users. So let's give this
some more time before merging to see whether there is such a consensus.

[1] http://lkml.kernel.org/r/20190201102515.GK11599@dhcp22.suse.cz

> ---
> 
>  Documentation/admin-guide/cgroup-v2.rst |    9 +++++++++
>  include/linux/cgroup-defs.h             |    5 +++++
>  include/linux/memcontrol.h              |   10 ++++++++--
>  kernel/cgroup/cgroup.c                  |   16 ++++++++++++++--
>  4 files changed, 36 insertions(+), 4 deletions(-)
> 
> --- a/Documentation/admin-guide/cgroup-v2.rst~mm-consider-subtrees-in-memoryevents
> +++ a/Documentation/admin-guide/cgroup-v2.rst
> @@ -177,6 +177,15 @@ cgroup v2 currently supports the followi
>  	ignored on non-init namespace mounts.  Please refer to the
>  	Delegation section for details.
>  
> +  memory_localevents
> +
> +        Only populate memory.events with data for the current cgroup,
> +        and not any subtrees. This is legacy behaviour, the default
> +        behaviour without this option is to include subtree counts.
> +        This option is system wide and can only be set on mount or
> +        modified through remount from the init namespace. The mount
> +        option is ignored on non-init namespace mounts.
> +
>  
>  Organizing Processes and Threads
>  --------------------------------
> --- a/include/linux/cgroup-defs.h~mm-consider-subtrees-in-memoryevents
> +++ a/include/linux/cgroup-defs.h
> @@ -83,6 +83,11 @@ enum {
>  	 * Enable cpuset controller in v1 cgroup to use v2 behavior.
>  	 */
>  	CGRP_ROOT_CPUSET_V2_MODE = (1 << 4),
> +
> +	/*
> +	 * Enable legacy local memory.events.
> +	 */
> +	CGRP_ROOT_MEMORY_LOCAL_EVENTS = (1 << 5),
>  };
>  
>  /* cftype->flags */
> --- a/include/linux/memcontrol.h~mm-consider-subtrees-in-memoryevents
> +++ a/include/linux/memcontrol.h
> @@ -789,8 +789,14 @@ static inline void count_memcg_event_mm(
>  static inline void memcg_memory_event(struct mem_cgroup *memcg,
>  				      enum memcg_memory_event event)
>  {
> -	atomic_long_inc(&memcg->memory_events[event]);
> -	cgroup_file_notify(&memcg->events_file);
> +	do {
> +		atomic_long_inc(&memcg->memory_events[event]);
> +		cgroup_file_notify(&memcg->events_file);
> +
> +		if (cgrp_dfl_root.flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
> +			break;
> +	} while ((memcg = parent_mem_cgroup(memcg)) &&
> +		 !mem_cgroup_is_root(memcg));
>  }
>  
>  static inline void memcg_memory_event_mm(struct mm_struct *mm,
> --- a/kernel/cgroup/cgroup.c~mm-consider-subtrees-in-memoryevents
> +++ a/kernel/cgroup/cgroup.c
> @@ -1775,11 +1775,13 @@ int cgroup_show_path(struct seq_file *sf
>  
>  enum cgroup2_param {
>  	Opt_nsdelegate,
> +	Opt_memory_localevents,
>  	nr__cgroup2_params
>  };
>  
>  static const struct fs_parameter_spec cgroup2_param_specs[] = {
> -	fsparam_flag  ("nsdelegate",		Opt_nsdelegate),
> +	fsparam_flag("nsdelegate",		Opt_nsdelegate),
> +	fsparam_flag("memory_localevents",	Opt_memory_localevents),
>  	{}
>  };
>  
> @@ -1802,6 +1804,9 @@ static int cgroup2_parse_param(struct fs
>  	case Opt_nsdelegate:
>  		ctx->flags |= CGRP_ROOT_NS_DELEGATE;
>  		return 0;
> +	case Opt_memory_localevents:
> +		ctx->flags |= CGRP_ROOT_MEMORY_LOCAL_EVENTS;
> +		return 0;
>  	}
>  	return -EINVAL;
>  }
> @@ -1813,6 +1818,11 @@ static void apply_cgroup_root_flags(unsi
>  			cgrp_dfl_root.flags |= CGRP_ROOT_NS_DELEGATE;
>  		else
>  			cgrp_dfl_root.flags &= ~CGRP_ROOT_NS_DELEGATE;
> +
> +		if (root_flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
> +			cgrp_dfl_root.flags |= CGRP_ROOT_MEMORY_LOCAL_EVENTS;
> +		else
> +			cgrp_dfl_root.flags &= ~CGRP_ROOT_MEMORY_LOCAL_EVENTS;
>  	}
>  }
>  
> @@ -1820,6 +1830,8 @@ static int cgroup_show_options(struct se
>  {
>  	if (cgrp_dfl_root.flags & CGRP_ROOT_NS_DELEGATE)
>  		seq_puts(seq, ",nsdelegate");
> +	if (cgrp_dfl_root.flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
> +		seq_puts(seq, ",memory_localevents");
>  	return 0;
>  }
>  
> @@ -6207,7 +6219,7 @@ static struct kobj_attribute cgroup_dele
>  static ssize_t features_show(struct kobject *kobj, struct kobj_attribute *attr,
>  			     char *buf)
>  {
> -	return snprintf(buf, PAGE_SIZE, "nsdelegate\n");
> +	return snprintf(buf, PAGE_SIZE, "nsdelegate\nmemory_localevents\n");
>  }
>  static struct kobj_attribute cgroup_features_attr = __ATTR_RO(features);
>  
> _
> 
> Patches currently in -mm which might be from chris@chrisdown.name are
> 
> mm-create-mem_cgroup_from_seq.patch
> mm-extract-memcg-maxable-seq_file-logic-to-seq_show_memcg_tunable.patch
> mm-proportional-memorylowmin-reclaim.patch
> mm-proportional-memorylowmin-reclaim-fix.patch
> mm-memcontrol-expose-thp-events-on-a-per-memcg-basis.patch
> mm-memcontrol-expose-thp-events-on-a-per-memcg-basis-fix-2.patch
> mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
> mm-rename-ambiguously-named-memorystat-counters-and-functions.patch
> mm-consider-subtrees-in-memoryevents.patch

-- 
Michal Hocko
SUSE Labs

