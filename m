Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 856486B0036
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:52:42 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so2349676pdj.1
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 14:52:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pq7si18357624pac.358.2014.04.30.14.52.40
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 14:52:41 -0700 (PDT)
Date: Wed, 30 Apr 2014 14:52:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-Id: <20140430145238.4215f914f7ad025da4db5470@linux-foundation.org>
In-Reply-To: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 28 Apr 2014 14:26:41 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> Hi,
> previous discussions have shown that soft limits cannot be reformed
> (http://lwn.net/Articles/555249/). This series introduces an alternative
> approach for protecting memory allocated to processes executing within
> a memory cgroup controller. It is based on a new tunable that was
> discussed with Johannes and Tejun held during the kernel summit 2013 and
> at LSF 2014.
> 
> This patchset introduces such low limit that is functionally similar
> to a minimum guarantee. Memcgs which are under their lowlimit are not
> considered eligible for the reclaim (both global and hardlimit) unless
> all groups under the reclaimed hierarchy are below the low limit when
> all of them are considered eligible.

Permitting containers to avoid global reclaim sounds rather worrisome. 

Fairness: won't it permit processes to completely protect their memory
while everything else in the system is getting utterly pounded?  We
need to consider global-vs-memcg fairness as well as memcg-vs-memgc.

Security: can this feature be used to DoS the machine?  Set up enough
hierarchies which are below their low limit and we risk memory
exhaustion and swap-thrashing and oom-killings for other processes.


All of that being said, your statement doesn't appear to be true ;)

> +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> +{
> +	if (!__shrink_zone(zone, sc, true)) {
> +		/*
> +		 * First round of reclaim didn't find anything to reclaim
> +		 * because of low limit protection so try again and ignore
> +		 * the low limit this time.
> +		 */
> +		__shrink_zone(zone, sc, false);
> +	}
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
