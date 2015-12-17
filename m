Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 186084402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:09:48 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id kw15so48291553lbb.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 08:09:48 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p16si8330992lfb.105.2015.12.17.08.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 08:09:46 -0800 (PST)
Date: Thu, 17 Dec 2015 11:09:25 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151217160925.GA24124@cmpxchg.org>
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
 <a6d639c29f845c2da9adaaab536754c714099e92.1450352791.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6d639c29f845c2da9adaaab536754c714099e92.1450352791.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Dec 17, 2015 at 03:29:54PM +0300, Vladimir Davydov wrote:
> In the legacy hierarchy we charge memsw, which is dubious, because:
> 
>  - memsw.limit must be >= memory.limit, so it is impossible to limit
>    swap usage less than memory usage. Taking into account the fact that
>    the primary limiting mechanism in the unified hierarchy is
>    memory.high while memory.limit is either left unset or set to a very
>    large value, moving memsw.limit knob to the unified hierarchy would
>    effectively make it impossible to limit swap usage according to the
>    user preference.
> 
>  - memsw.usage != memory.usage + swap.usage, because a page occupying
>    both swap entry and a swap cache page is charged only once to memsw
>    counter. As a result, it is possible to effectively eat up to
>    memory.limit of memory pages *and* memsw.limit of swap entries, which
>    looks unexpected.
> 
> That said, we should provide a different swap limiting mechanism for
> cgroup2.
> 
> This patch adds mem_cgroup->swap counter, which charges the actual
> number of swap entries used by a cgroup. It is only charged in the
> unified hierarchy, while the legacy hierarchy memsw logic is left
> intact.
> 
> The swap usage can be monitored using new memory.swap.current file and
> limited using memory.swap.max.
> 
> Note, to charge swap resource properly in the unified hierarchy, we have
> to make swap_entry_free uncharge swap only when ->usage reaches zero,
> not just ->count, i.e. when all references to a swap entry, including
> the one taken by swap cache, are gone. This is necessary, because
> otherwise swap-in could result in uncharging swap even if the page is
> still in swap cache and hence still occupies a swap entry. At the same
> time, this shouldn't break memsw counter logic, where a page is never
> charged twice for using both memory and swap, because in case of legacy
> hierarchy we uncharge swap on commit (see mem_cgroup_commit_charge).

This was actually an oversight when rewriting swap accounting. It
should have always been uncharged when the swap slot is released.

> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
