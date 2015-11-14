Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D76F06B0263
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 10:15:31 -0500 (EST)
Received: by wmec201 with SMTP id c201so119828549wme.0
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 07:15:31 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c12si13396688wmh.122.2015.11.14.07.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 07:15:30 -0800 (PST)
Date: Sat, 14 Nov 2015 10:15:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 03/14] net: tcp_memcontrol: properly detect ancestor
 socket pressure
Message-ID: <20151114151518.GB28175@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-4-git-send-email-hannes@cmpxchg.org>
 <20151114124552.GI31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151114124552.GI31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, Nov 14, 2015 at 03:45:52PM +0300, Vladimir Davydov wrote:
> On Thu, Nov 12, 2015 at 06:41:22PM -0500, Johannes Weiner wrote:
> > When charging socket memory, the code currently checks only the local
> > page counter for excess to determine whether the memcg is under socket
> > pressure. But even if the local counter is fine, one of the ancestors
> > could have breached its limit, which should also force this child to
> > enter socket pressure. This currently doesn't happen.
> > 
> > Fix this by using page_counter_try_charge() first. If that fails, it
> > means that either the local counter or one of the ancestors are in
> > excess of their limit, and the child should enter socket pressure.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks Vladimir!

> For the record: it was broken by commit 3e32cb2e0a12 ("mm: memcontrol:
> lockless page counters").

I didn't realize that.

Fixes: 3e32cb2e0a12 ("mm: memcontrol: lockless page counters")

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
