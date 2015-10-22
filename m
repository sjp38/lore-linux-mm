Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id E69C26B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:45:28 -0400 (EDT)
Received: by lfbn126 with SMTP id n126so24430914lfb.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:45:28 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id zv6si10439954lbb.62.2015.10.22.11.45.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 11:45:26 -0700 (PDT)
Date: Thu, 22 Oct 2015 21:45:10 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Message-ID: <20151022184509.GM18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Johannes,

On Thu, Oct 22, 2015 at 12:21:28AM -0400, Johannes Weiner wrote:
...
> Patch #5 adds accounting and tracking of socket memory to the unified
> hierarchy memory controller, as described above. It uses the existing
> per-cpu charge caches and triggers high limit reclaim asynchroneously.
> 
> Patch #8 uses the vmpressure extension to equalize pressure between
> the pages tracked natively by the VM and socket buffer pages. As the
> pool is shared, it makes sense that while natively tracked pages are
> under duress the network transmit windows are also not increased.

First of all, I've no experience in networking, so I'm likely to be
mistaken. Nevertheless I beg to disagree that this patch set is a step
in the right direction. Here goes why.

I admit that your idea to get rid of explicit tcp window control knobs
and size it dynamically basing on memory pressure instead does sound
tempting, but I don't think it'd always work. The problem is that in
contrast to, say, dcache, we can't shrink tcp buffers AFAIU, we can only
stop growing them. Now suppose a system hasn't experienced memory
pressure for a while. If we don't have explicit tcp window limit, tcp
buffers on such a system might have eaten almost all available memory
(because of network load/problems). If a user workload that needs a
significant amount of memory is started suddenly then, the network code
will receive a notification and surely stop growing buffers, but all
those buffers accumulated won't disappear instantly. As a result, the
workload might be unable to find enough free memory and have no choice
but invoke OOM killer. This looks unexpected from the user POV.

That said, I think we do need per memcg tcp window control similar to
what we have system-wide. In other words, Glauber's work makes sense to
me. You might want to point me at my RFC patch where I proposed to
revert it (https://lkml.org/lkml/2014/9/12/401). Well, I've changed my
mind since then. Now I think I was mistaken, luckily I was stopped.
However, I may be mistaken again :-)

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
