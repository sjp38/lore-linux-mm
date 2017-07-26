Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50FDD6B02B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:23:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p17so8682129wmd.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:23:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y199si9995093wme.208.2017.07.26.14.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 14:23:12 -0700 (PDT)
Date: Wed, 26 Jul 2017 14:23:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memcontrol: Cast mismatched enum types passed to
 memcg state and event functions
Message-Id: <20170726142309.ac40faf5eb99568e6edb064c@linux-foundation.org>
In-Reply-To: <20170726192356.18420-1-mka@chromium.org>
References: <20170726192356.18420-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>

On Wed, 26 Jul 2017 12:23:56 -0700 Matthias Kaehlcke <mka@chromium.org> wrote:

> In multiple instances enum values of an incorrect type are passed to
> mod_memcg_state() and other memcg functions. Apparently this is
> intentional, however clang rightfully generates tons of warnings about
> the mismatched types. Cast the offending values to the type expected
> by the called function. The casts add noise, but this seems preferable
> over losing the typesafe interface or/and disabling the warning.
> 
> ...
>
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -576,7 +576,7 @@ static inline void __mod_lruvec_state(struct lruvec *lruvec,
>  	if (mem_cgroup_disabled())
>  		return;
>  	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> -	__mod_memcg_state(pn->memcg, idx, val);
> +	__mod_memcg_state(pn->memcg, (enum memcg_stat_item)idx, val);
>  	__this_cpu_add(pn->lruvec_stat->count[idx], val);
>  }

__mod_memcg_state()'s `idx' arg can be either enum memcg_stat_item or
enum memcg_stat_item.  I think it would be better to just admit to
ourselves that __mod_memcg_state() is more general than it appears, and
change it to take `int idx'.  I assume that this implicit cast of an
enum to an int will not trigger a clang warning?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
