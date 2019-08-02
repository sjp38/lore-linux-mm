Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E057C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 03:33:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 079402080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 03:33:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 079402080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5213E6B0003; Thu,  1 Aug 2019 23:33:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F8B66B0005; Thu,  1 Aug 2019 23:33:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40F086B027E; Thu,  1 Aug 2019 23:33:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA9C6B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 23:33:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q14so47261761pff.8
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 20:33:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:list-id:archived-at
         :list-archive:list-post:content-transfer-encoding;
        bh=xp3vv7qwhwCsSMT/IjsALKzRpIEeI7C7k39cd2Men+o=;
        b=Eeaaii3ILcxMpQvNy157Ade/QiIYuJ9avIcEWNYwXgYMXwptyH14q8cAsMcw2JAPTq
         9MLQ4PpYcN+ggcs1oJr7jQXBeDvkBQZuDHafzag+ZC/YnB0w5E6D1UmFi9RqnVJzoHUF
         Az0zvjzH65gEqtwVmu7RsR/J0sW5Cf1kaoxmTS+dQQ0kLN34EuIQM62sQMmrRhvXHlSM
         s02KWtYITVoBcWz0Gzj/NA6EpYx8O1/Ssrq8UJFN6SlhOOQktuLuRFmt9j1etEX1QxU+
         Esg0hwSNsV701tEy3y2SNbky1rc0zhrpj/1GGFe4ZxWycX4NOAgcdphefN6XjJiF9nsI
         44RQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVxzc8YKHxV6s7TYvk6uhxNDw68sZ7Y6QdhvpGZskSmpfeNY9L/
	WdBmzwcpK7E3n7sed0UqKAK2IxWDglwV+JVlXRoQzF52mTWRIbaaw5+Cg+XRKizo0Feyu2A+u+P
	+KRzvlRBeMJmAPKBOkPA7vNVTJv4n4tnr72aKEsq7I0Tr6p4+bO7iYq3wXugVVDXXKw==
X-Received: by 2002:a63:2364:: with SMTP id u36mr118226121pgm.449.1564716827558;
        Thu, 01 Aug 2019 20:33:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSZI/uAlJzcHPYSR/KggOyVj/MEJ6Bs3kdmCfZfrVcMvkYh4aiU0zvoy8QXUVZdznPztDB
X-Received: by 2002:a63:2364:: with SMTP id u36mr118226060pgm.449.1564716826401;
        Thu, 01 Aug 2019 20:33:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564716826; cv=none;
        d=google.com; s=arc-20160816;
        b=C/uoapy3Gu9jpAKHWgn80eH88vFWB4YlB0Iyq+JGQ5GB1KEn/JzDbX/Z1BmH+EtfS2
         DjavZw2rpNjBqspudPyygLYTPJezYBjCeY7Jv5X5CeyOnpechTZau8zS1WPKLLs7wYWy
         yXe800rbVkGFE9MoQ634/UYrMDyQ2OxkyZVeIzcz38SDCqXZI+L6Ls8h/A01yCk3cNyX
         f8dHIWAiJaARx2t1fmi0I8Bj8FdAHJ1ghKuSifZa1EGyxocsuv6aoaLzn1FFROEZYKoC
         sSfrhLiXJURppHMsP6fvai64BiEbxzXpfuW8zsDAamFIGnU8Y4GJhkdq/Zlmaa4nHJfT
         u4QA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:mime-version:message-id:date:subject:cc:to:from;
        bh=xp3vv7qwhwCsSMT/IjsALKzRpIEeI7C7k39cd2Men+o=;
        b=XDxIJ5+bxJNIqNotFv+X0YcMlxrU7OwbES/DIYxWSSmcHfxAGnHMAwx0mG+fTc0hB1
         dfgxNmw8JvL3l7x+a3mLWDXVBgc8WOypDhzV6uMRfON35LaneV7P/Cthw7/aBuSwRL8H
         63sYdnLCftGOWjEFRtVoXOxtrhfJtjY5B6IvZeE/7oI7jE9iqmxUvi47vtKfS/6uX9cV
         7XXvj5PoFEB3nzc/FpR3g9c3jXqyGFEOFIhJAzdjiyq9jULxovO9l4z2NzGq0sN4RXqh
         UtXHOEk5HDik07RYkCiotmqSDiMRIl4NPieHetL2BUXiPcaGhLYN4k3QnwR/teXYfNED
         OupQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-162.sinamail.sina.com.cn (mail3-162.sinamail.sina.com.cn. [202.108.3.162])
        by mx.google.com with SMTP id v136si36887519pfc.9.2019.08.01.20.33.45
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 20:33:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) client-ip=202.108.3.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D43AF16000075DB; Fri, 2 Aug 2019 11:33:44 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 68876130410446
From: Hillf Danton <hdanton@sina.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: memcontrol: switch to rcu protection in drain_all_stock()
Date: Fri,  2 Aug 2019 11:33:33 +0800
Message-Id: <20190801233513.137917-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190801233513.137917-1-guro@fb.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190802033333.OO_sZQO9dpFnZ1vumT_ij3msqGe1vh_tKY8duC4mJOQ@z>


On Thu, 1 Aug 2019 16:35:13 -0700 Roman Gushchin wrote:
> 
> Commit 72f0184c8a00 ("mm, memcg: remove hotplug locking from try_charge")
> introduced css_tryget()/css_put() calls in drain_all_stock(),
> which are supposed to protect the target memory cgroup from being
> released during the mem_cgroup_is_descendant() call.
> 
> However, it's not completely safe. In theory, memcg can go away
> between reading stock->cached pointer and calling css_tryget().

Good catch!
> 
> So, let's read the stock->cached pointer and evaluate the memory
> cgroup inside a rcu read section, and get rid of
> css_tryget()/css_put() calls.

You need to either adjust the boundry of the rcu-protected section, or
retain the call pairs, as the memcg cache is dereferenced again in
drain_stock().
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memcontrol.c | 17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5c7b9facb0eb..d856b64426b7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2235,21 +2235,22 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
>  	for_each_online_cpu(cpu) {
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
>  		struct mem_cgroup *memcg;
> +		bool flush = false;
>  
> +		rcu_read_lock();
>  		memcg = stock->cached;
> -		if (!memcg || !stock->nr_pages || !css_tryget(&memcg->css))
> -			continue;
> -		if (!mem_cgroup_is_descendant(memcg, root_memcg)) {
> -			css_put(&memcg->css);
> -			continue;
> -		}
> -		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> +		if (memcg && stock->nr_pages &&
> +		    mem_cgroup_is_descendant(memcg, root_memcg))
> +			flush = true;
> +		rcu_read_unlock();
> +
> +		if (flush &&
> +		    !test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
>  			if (cpu == curcpu)
>  				drain_local_stock(&stock->work);
>  			else
>  				schedule_work_on(cpu, &stock->work);
>  		}
> -		css_put(&memcg->css);
>  	}
>  	put_cpu();
>  	mutex_unlock(&percpu_charge_mutex);
> -- 
> 2.21.0
> 


