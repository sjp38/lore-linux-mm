Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 519A0C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 12:08:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7EFD2070B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 12:08:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7EFD2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53C256B000E; Wed,  5 Jun 2019 08:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4ED376B0010; Wed,  5 Jun 2019 08:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B54A6B0266; Wed,  5 Jun 2019 08:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E05856B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 08:08:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l26so5476888eda.2
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 05:08:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UU9AYCTaLBxBHVDjOgRHTSGVgBQ3OBS6KXXVrjfI6qc=;
        b=bA3X87HdFmTo+/UjMZkSBWLUCvh7uj55sV4PMH6/aR4CWGNqdws7VwSZDsCHQncrBf
         lnthWM7TN/NGMugtjdGdLpT9StQvd4Oe6VJTbo8Uw+AfYYvp+UwZPDx+x0MwZjDih+g1
         /WrUTfPAomJDajkzRTTHGv+wDFnHZ+lwouN+/DCjxz115Kkjkb3YUxscKL7hHQV6njjr
         Bz1BnXlcyGaCTbxxRtjUhi7LnN868qiR4K1UnL9XUDZiLdyFa3xsDSvtTybLYJsMvxgZ
         297TTYeHDeGTNTV/raJjcMD8auWEnvDD40eGxHkFWzEQroqnKmoMgwBpTTLepvNueZVH
         zLjw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV+pJdy6pos3pixomO8ec4PbbVrHVg0vkw5Ai7zb/n3FQDQEVmp
	9oyGUBYYyHCqHgnEXniOOmFYNeZg2y6G0Px5wuIkPMrJzJa6dBym5/sQmh8+01yvdb+O8B8kt9a
	l1Zu+vFJdqjVITiJ4pu3HW9JZjf5QFbneF1MEZhbrmfRDXjuBmSqOTGfA46RH++M=
X-Received: by 2002:a50:b797:: with SMTP id h23mr42381896ede.197.1559736520473;
        Wed, 05 Jun 2019 05:08:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOvpEYvXt7yEWBqr3DHfq7oVpsBguAFXaEBDPjtKaU7RwGX6gQluY/buErWHyfBx7Qwabq
X-Received: by 2002:a50:b797:: with SMTP id h23mr42381735ede.197.1559736518920;
        Wed, 05 Jun 2019 05:08:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559736518; cv=none;
        d=google.com; s=arc-20160816;
        b=Rl1y1sOvjqLyktFZXUK1LyNZnHL6LooVY8yE2e2xOANecS5t6NZEPms5N/aMlR0xpU
         owblvIZayDfTg/EtU3HBGx5QFFL2A+duFfxgM0U0Mu2bPs2As5VtToo8mGyo7bSTnKfb
         cAd8tY9jDG66lQnKymmUJlc0lS5PN2CXmGNSdOFbsjqR/Mr0QdaVV5MMw5we8G0EcaLl
         TXD+awO6prsmhoiWg8cEVERh7dyD17g6KwWe5IzzhFNRJDyDuxqpUzXHrfA3nWov13Z/
         /LL8bG+RkNLCgtl6X7KIH02UlNDGe4eoYzHu9+gqbY4z16DBWMLBae/9UAoj7MQKrv/v
         a0Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UU9AYCTaLBxBHVDjOgRHTSGVgBQ3OBS6KXXVrjfI6qc=;
        b=bg8SHQ2PA1Q6+B4PkSYZ7TVH+LymJEeVofXB4fbbbgLKe0aILIBP+17l1uEuTZ2JyI
         T7qsoI6O1fzltwAym/l44bmJI8yywmKZ3h85J6mL714wweSn10gHKVLUzjYtq8jdm9hz
         BBxdKdF4svItfqtPUurQnftl+6RM4MtbqqOt8oHD0SRqD1ssvgonpOy9FVCFjEADpkwl
         BBmhdnbZ34CrCNQR3spFjm85qwStncLa9yfJxwfe8qwxB7+LO7ZCKoQy6y6bcdkdC2WU
         ZH7HYHRJvbUiIQqIDGAo65M/ysNxfAHBLiNzNXsxhIWGHfkcnN+ErqgTdX3bxcCGFVOG
         JGnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r19si7286600edd.57.2019.06.05.05.08.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 05:08:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DC8D6AC8C;
	Wed,  5 Jun 2019 12:08:37 +0000 (UTC)
Date: Wed, 5 Jun 2019 14:08:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: memcontrol: dump memory.stat during cgroup OOM
Message-ID: <20190605120837.GE15685@dhcp22.suse.cz>
References: <20190604210509.9744-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604210509.9744-1-hannes@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 04-06-19 17:05:09, Johannes Weiner wrote:
> The current cgroup OOM memory info dump doesn't include all the memory
> we are tracking, nor does it give insight into what the VM tried to do
> leading up to the OOM. All that useful info is in memory.stat.

I agree that other memcg counters can provide a useful insight for the OOM
situation.

> Furthermore, the recursive printing for every child cgroup can
> generate absurd amounts of data on the console for larger cgroup
> trees, and it's not like we provide a per-cgroup breakdown during
> global OOM kills.

The idea was that this information might help to identify which subgroup
is the major contributor to the OOM at a higher level. I have to confess
that I have never really used that information myself though.

> When an OOM kill is triggered, print one set of recursive memory.stat
> items at the level whose limit triggered the OOM condition.
> 
> Example output:
> 
[...]
> memory: usage 1024kB, limit 1024kB, failcnt 75131
> swap: usage 0kB, limit 9007199254740988kB, failcnt 0
> Memory cgroup stats for /foo:
> anon 0
> file 0
> kernel_stack 36864
> slab 274432
> sock 0
> shmem 0
> file_mapped 0
> file_dirty 0
> file_writeback 0
> anon_thp 0
> inactive_anon 126976
> active_anon 0
> inactive_file 0
> active_file 0
> unevictable 0
> slab_reclaimable 0
> slab_unreclaimable 274432
> pgfault 59466
> pgmajfault 1617
> workingset_refault 2145
> workingset_activate 0
> workingset_nodereclaim 0
> pgrefill 98952
> pgscan 200060
> pgsteal 59340
> pgactivate 40095
> pgdeactivate 96787
> pglazyfree 0
> pglazyfreed 0
> thp_fault_alloc 0
> thp_collapse_alloc 0

I am not entirely happy with that many lines in the oom report though. I
do see that you are trying to reduce code duplication which is fine but
would it be possible to squeeze all of these counters on a single line?
The same way we do for the global OOM report?

> Tasks state (memory values in pages):
> [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> [    200]     0   200     1121      884    53248       29             0 bash
> [    209]     0   209      905      246    45056       19             0 stress
> [    210]     0   210    66442       56   499712    56349             0 stress
> oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),oom_memcg=/foo,task_memcg=/foo,task=stress,pid=210,uid=0
> Memory cgroup out of memory: Killed process 210 (stress) total-vm:265768kB, anon-rss:0kB, file-rss:224kB, shmem-rss:0kB
> oom_reaper: reaped process 210 (stress), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 289 ++++++++++++++++++++++++++----------------------
>  1 file changed, 157 insertions(+), 132 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6de8ca735ee2..0907a96ceddf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -66,6 +66,7 @@
>  #include <linux/lockdep.h>
>  #include <linux/file.h>
>  #include <linux/tracehook.h>
> +#include <linux/seq_buf.h>
>  #include "internal.h"
>  #include <net/sock.h>
>  #include <net/ip.h>
> @@ -1365,27 +1366,114 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
>  	return false;
>  }
>  
> -static const unsigned int memcg1_stats[] = {
> -	MEMCG_CACHE,
> -	MEMCG_RSS,
> -	MEMCG_RSS_HUGE,
> -	NR_SHMEM,
> -	NR_FILE_MAPPED,
> -	NR_FILE_DIRTY,
> -	NR_WRITEBACK,
> -	MEMCG_SWAP,
> -};
> +static char *memory_stat_format(struct mem_cgroup *memcg)
> +{
> +	struct seq_buf s;
> +	int i;
>  
> -static const char *const memcg1_stat_names[] = {
> -	"cache",
> -	"rss",
> -	"rss_huge",
> -	"shmem",
> -	"mapped_file",
> -	"dirty",
> -	"writeback",
> -	"swap",
> -};
> +	seq_buf_init(&s, kvmalloc(PAGE_SIZE, GFP_KERNEL), PAGE_SIZE);

What is the reason to use kvmalloc here? It doesn't make much sense to
me to use it for the page size allocation TBH.

Other than that this looks sane to me.
-- 
Michal Hocko
SUSE Labs

