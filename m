Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9306B00EB
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 09:22:11 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so1251312wes.7
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 06:22:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hl6si1742646wjb.55.2014.06.12.06.22.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 06:22:09 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:22:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140612132207.GA32720@dhcp22.suse.cz>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <1402473624-13827-2-git-send-email-mhocko@suse.cz>
 <20140611153631.GH2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140611153631.GH2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 11-06-14 11:36:31, Johannes Weiner wrote:
[...]
> This code is truly dreadful.
> 
> Don't call it guarantee when it doesn't guarantee anything.  I thought
> we agreed that min, low, high, max, is reasonable nomenclature, please
> use it consistently.

I can certainly change the internal naming. I will use your wmark naming
suggestion.
 
> With my proposed cleanups and scalability fixes in the other mail, the
> vmscan.c changes to support the min watermark would be something like
> the following.

The semantic is, however, much different as pointed out in the other email.
The following on top of you cleanup will lead to the same deadlock
described in 1st patch (mm, memcg: allow OOM if no memcg is eligible
during direct reclaim).

Anyway, the situation now is pretty chaotic. I plan to gather all the
patchse posted so far and repost for the future discussion. I just need
to finish some internal tasks and will post it soon.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 687076b7a1a6..cee19b6d04dc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2259,7 +2259,7 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  				 */
>  				if (priority < DEF_PRIORITY - 2)
>  					break;
> -
> +			case MEMCG_WMARK_MIN:
>  				/* XXX: skip the whole subtree */
>  				memcg = mem_cgroup_iter(root, memcg, &reclaim);
>  				continue;
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
