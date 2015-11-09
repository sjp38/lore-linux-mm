Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 210A56B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 13:54:06 -0500 (EST)
Received: by ykdv3 with SMTP id v3so191665957ykd.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 10:54:05 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id x8si2515772ywc.73.2015.11.09.10.54.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:54:05 -0800 (PST)
Received: by ykek133 with SMTP id k133so281394431yke.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 10:54:05 -0800 (PST)
Date: Mon, 9 Nov 2015 13:54:01 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151109185401.GB28507@mtj.duckdns.org>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
 <20151109182840.GJ31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151109182840.GJ31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Vladmir.

On Mon, Nov 09, 2015 at 09:28:40PM +0300, Vladimir Davydov wrote:
> > I am _all_ for this semantic I am just not sure what to do with the
> > legacy kmem controller. Can we change its semantic? If we cannot do that
> 
> I think we can. If somebody reports a "bug" caused by this change, i.e.
> basically notices that something that used to be accounted is not any
> longer, it will be trivial to fix by adding __GFP_ACCOUNT where
> appropriate. If it is not, e.g. if accounting of objects of a particular
> type leads to intense false-sharing, we would end up disabling
> accounting for it anyway.

I agree too, if anything is meaningfully broken by the flip, it just
indicates that the whitelist needs to be expanded; however, I wonder
whether this would be done better at slab level rather than per
allocation site.

A class of objects which can consume noticeable amount of memory which
can be attributed to userland is likely to be on its own slab already
or separating it out to its own slab is likely to be a good idea.
Marking those slabs as kmemcg accounted seems better suited to the
semantics - it's always about classes of objects - and less
error-prone than marking individual allocation sites.

This also reduces the number of slabs to worry about and more
importantly makes it clear which slabs need to be replicated for
kmemcg accounting from the beginning and the slab part of
implementation can be far simpler / more static.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
