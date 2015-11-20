Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C6E4B6B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 13:57:00 -0500 (EST)
Received: by wmec201 with SMTP id c201so32977794wme.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 10:57:00 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 8si1257256wjy.211.2015.11.20.10.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 10:56:59 -0800 (PST)
Date: Fri, 20 Nov 2015 13:56:48 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 09/14] net: tcp_memcontrol: simplify linkage between
 socket and page counter
Message-ID: <20151120185648.GC5623@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-10-git-send-email-hannes@cmpxchg.org>
 <20151120124216.GD31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151120124216.GD31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Nov 20, 2015 at 03:42:16PM +0300, Vladimir Davydov wrote:
> On Thu, Nov 12, 2015 at 06:41:28PM -0500, Johannes Weiner wrote:
> > There won't be any separate counters for socket memory consumed by
> > protocols other than TCP in the future. Remove the indirection and
> 
> I really want to believe you're right. And with vmpressure propagation
> implemented properly you are likely to be right.
> 
> However, we might still want to account other socket protos to
> memcg->memory in the unified hierarchy, e.g. UDP, or SCTP, or whatever
> else. Adding new consumers should be trivial, but it will break the
> legacy usecase, where only TCP sockets are supposed to be accounted.
> What about adding a check to sock_update_memcg() so that it would enable
> accounting only for TCP sockets in case legacy hierarchy is used?

Yup, I was thinking the same thing. But we can cross that bridge when
we come to it and are actually adding further packet types.

> For the same reason, I think we'd better rename memcg->tcp_mem to
> something like memcg->sk_mem or we can even drop the cg_proto struct
> altogether embedding its fields directly to mem_cgroup struct.
> 
> Also, I don't see any reason to have tcp_memcontrol.c file. It's tiny
> and with this patch it does not depend on tcp code any more. Let's move
> it to memcontrol.c?

I actually had all this at first, but then wondered if it makes more
sense to keep the legacy code in isolation. Don't you think it would
be easier to keep track of what's v1 and what's v2 if we keep the
legacy stuff physically separate as much as possible? In particular I
found that 'tcp_mem.' marker really useful while working on the code.

In the same vein, tcp_memcontrol.c doesn't really hurt anybody and I'd
expect it to remain mostly unopened and unchanged in the future. But
if we merge it into memcontrol.c, that code will likely be in the way
and we'd have to make it explicit somehow that this is not actually
part of the new memory controller anymore.

What do you think?

> Other than that this patch looks OK to me.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
