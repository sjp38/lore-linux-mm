Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 45DA86B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 04:07:45 -0500 (EST)
Received: by padhx2 with SMTP id hx2so110982495pad.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 01:07:45 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id px16si17801933pab.64.2015.11.20.01.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 01:07:44 -0800 (PST)
Date: Fri, 20 Nov 2015 12:07:25 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 04/14] net: tcp_memcontrol: remove bogus hierarchy
 pressure propagation
Message-ID: <20151120090725.GW31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:23PM -0500, Johannes Weiner wrote:
> When a cgroup currently breaches its socket memory limit, it enters
> memory pressure mode for itself and its *ancestors*. This throttles
> transmission in unrelated sibling and cousin subtrees that have
> nothing to do with the breached limit.
> 
> On the contrary, breaching a limit should make that group and its
> *children* enter memory pressure mode. But this happens already,
> albeit lazily: if an ancestor limit is breached, siblings will enter
> memory pressure on their own once the next packet arrives for them.

Hmm, we still call sk_prot->enter_memory_pressure, which might hurt a
workload in the root cgroup AFAICS. Strange. You fix it in patch 8
though.

> 
> So no additional hierarchy code is needed. Remove the bogus stuff.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
