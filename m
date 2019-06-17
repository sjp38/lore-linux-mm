Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD205C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:38:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D53520833
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:38:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D53520833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2638E8E0002; Mon, 17 Jun 2019 10:38:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 214008E0001; Mon, 17 Jun 2019 10:38:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DD0A8E0002; Mon, 17 Jun 2019 10:38:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B51C78E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:38:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so16699886eds.14
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:38:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YTxSV97FRispvXTTsB7cZH963MigMCFvg+NXX5hAp7o=;
        b=U82V8keG/QO6REmWPriwrNTL4eV3ORv/62h74b0dof/jqe2EwPOuJRapF0SsIQ8+wB
         haeIckTQmVx8qSyPsTWyr9xYPoMLFN8CNc14lgFgsMU04m8Y3/5OpQZO+pww60a5ovfv
         8sZNPkGggTmi6p5aIckgv+xtbOaLdlv/HK6Cghs0Bq6xhvHsIuA6p57DgflgTD4uDrfr
         HqGp9volqvATo7blGfquu3GATe10UQjORZYv7YkQAnWqs+9kVLMTn+I00Ujyqc4oe43q
         9loq8n61Blqj/mO7+Dg7CxNxesLwa8c/aBtr0K+rmx4VgU176XottURYRPXr9IGnhGje
         hBPA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUKqDDHC7HwyRjRSbBqGaYmwdWlDbaJY2mffHGMB6UFff2uWt+F
	N5SRMi4ZmPg3UnHnU7DAl/IjouuYB/mT6XmjnXllzCHT52OiRJe64GtOS96Xi+9Do4mRKnCBvag
	nHE8Fr6l2IbDTc7loIrKFkCsMoX7LNgWXd8W5xDG4yDV5c0xVrrEK3ZxO2gLPs8Y=
X-Received: by 2002:a50:cb45:: with SMTP id h5mr119600558edi.12.1560782326215;
        Mon, 17 Jun 2019 07:38:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw30vnQ+CFHOt1KVxOuug8fv62lBAY8H+CxRcY9xDcpn5+g/6oss78mkH9U6aqz7Tn7YdAn
X-Received: by 2002:a50:cb45:: with SMTP id h5mr119600478edi.12.1560782325449;
        Mon, 17 Jun 2019 07:38:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560782325; cv=none;
        d=google.com; s=arc-20160816;
        b=qdgZaMNF2iYXBLF5ftJitqwacC6XhL1NdnUgY+Gw0QIRsNfV83KcydggZ/XCdDQEgQ
         uqzlDIQDsBv0tzk8Ue55GjxFbXEeJRwHDsHxxO20PJqxca5YVa8Y9xsc4Rh1vhT1WyIj
         tBZWEFClo/aXMUMOVgUxy+NehVUWF6Oz+lbQNfszFWXjUIo4Hlk7pbY3d8eDRmH7yCBD
         aAgwz3eXr7abgVovoBkMWE/DOHemYNnPAuI5/jFqUHneYeFv2FdzBHdrf2nVNqdVWRk7
         3c3q317EPh6Xs2qO2BMYtsEW78h1hx/efhrDsTSNJ/hyIJGDp6PJb5UzCZfKE8FbefYX
         dvWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YTxSV97FRispvXTTsB7cZH963MigMCFvg+NXX5hAp7o=;
        b=CL0fI0vi4u8EQY+zv0g3mNFFmiDKvyqw/HS4Tcgwim0IkSzkSCoWU+tD55ilFytYFa
         dKLE/t66evsovQjinMGUzhS9fI/CkF2gvd1OWBEdi+ZYO8sKqoxRP4mHdhrpYvhbLakJ
         DsWy4MM35cbZTtO+3NUIz/VV9giN/NYivpw2/3UEJvFchFteF3SL3lMLlzZAOgSWOS7P
         Ebl9eH2jQOgsce7WIp3W9a3sBAml/cgC8wGRF6RYU17EZDc2YcOoBNP22pcDGGmds0vx
         gEV3rbbCTssKl2brakF+SnwwZ87La5wwkI+otLc/B9oxGwSv+mAY2NY+NGjoi+yOUrPB
         I4SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m24si6467634ejo.75.2019.06.17.07.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 07:38:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8AAABAEC3;
	Mon, 17 Jun 2019 14:38:44 +0000 (UTC)
Date: Mon, 17 Jun 2019 16:38:42 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-api@vger.kernel.org
Subject: Re: [PATCH] mm, memcg: Report number of memcg caches in slabinfo
Message-ID: <20190617143842.GC1492@dhcp22.suse.cz>
References: <20190617142149.5245-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617142149.5245-1-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc linux-api]

On Mon 17-06-19 10:21:49, Waiman Long wrote:
> There are concerns about memory leaks from extensive use of memory
> cgroups as each memory cgroup creates its own set of kmem caches. There
> is a possiblity that the memcg kmem caches may remain even after the
> memory cgroup removal.
> 
> Therefore, it will be useful to show how many memcg caches are present
> for each of the kmem caches.

How is a user going to use that information?  Btw. Don't we have an
interface to display the number of (dead) cgroups?

Keeping the rest of the email for the reference.

> As slabinfo reporting code has to iterate
> through all the memcg caches to get the final numbers anyway, there is
> no additional cost in reporting the number of memcg caches available.
> 
> The slabinfo version is bumped up to 2.2 as a new "<num_caches>" column
> is added at the end.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  mm/slab_common.c | 24 ++++++++++++++++--------
>  1 file changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 58251ba63e4a..c7aa47a99b2b 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1308,13 +1308,13 @@ static void print_slabinfo_header(struct seq_file *m)
>  	 * without _too_ many complaints.
>  	 */
>  #ifdef CONFIG_DEBUG_SLAB
> -	seq_puts(m, "slabinfo - version: 2.1 (statistics)\n");
> +	seq_puts(m, "slabinfo - version: 2.2 (statistics)\n");
>  #else
> -	seq_puts(m, "slabinfo - version: 2.1\n");
> +	seq_puts(m, "slabinfo - version: 2.2\n");
>  #endif
>  	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
>  	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
> -	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
> +	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail> <num_caches>");
>  #ifdef CONFIG_DEBUG_SLAB
>  	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> <error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
>  	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
> @@ -1338,14 +1338,18 @@ void slab_stop(struct seq_file *m, void *p)
>  	mutex_unlock(&slab_mutex);
>  }
>  
> -static void
> +/*
> + * Return number of memcg caches.
> + */
> +static unsigned int
>  memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
>  {
>  	struct kmem_cache *c;
>  	struct slabinfo sinfo;
> +	unsigned int cnt = 0;
>  
>  	if (!is_root_cache(s))
> -		return;
> +		return 0;
>  
>  	for_each_memcg_cache(c, s) {
>  		memset(&sinfo, 0, sizeof(sinfo));
> @@ -1356,17 +1360,20 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
>  		info->shared_avail += sinfo.shared_avail;
>  		info->active_objs += sinfo.active_objs;
>  		info->num_objs += sinfo.num_objs;
> +		cnt++;
>  	}
> +	return cnt;
>  }
>  
>  static void cache_show(struct kmem_cache *s, struct seq_file *m)
>  {
>  	struct slabinfo sinfo;
> +	unsigned int nr_memcg_caches;
>  
>  	memset(&sinfo, 0, sizeof(sinfo));
>  	get_slabinfo(s, &sinfo);
>  
> -	memcg_accumulate_slabinfo(s, &sinfo);
> +	nr_memcg_caches = memcg_accumulate_slabinfo(s, &sinfo);
>  
>  	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
>  		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
> @@ -1374,8 +1381,9 @@ static void cache_show(struct kmem_cache *s, struct seq_file *m)
>  
>  	seq_printf(m, " : tunables %4u %4u %4u",
>  		   sinfo.limit, sinfo.batchcount, sinfo.shared);
> -	seq_printf(m, " : slabdata %6lu %6lu %6lu",
> -		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
> +	seq_printf(m, " : slabdata %6lu %6lu %6lu %3u",
> +		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail,
> +		   nr_memcg_caches);
>  	slabinfo_show_stats(m, s);
>  	seq_putc(m, '\n');
>  }
> -- 
> 2.18.1

-- 
Michal Hocko
SUSE Labs

