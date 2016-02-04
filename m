Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 040894403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 15:46:32 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 128so44749777wmz.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 12:46:31 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mo12si13585683wjc.138.2016.02.04.12.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 12:46:31 -0800 (PST)
Date: Thu, 4 Feb 2016 15:45:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: make tree_{stat,events} fetch all
 stats
Message-ID: <20160204204540.GD8208@cmpxchg.org>
References: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 04, 2016 at 04:03:37PM +0300, Vladimir Davydov wrote:
> Currently, tree_{stat,events} helpers can only get one stat index at a
> time, so when there are a lot of stats to be reported one has to call it
> over and over again (see memory_stat_show). This is neither effective,
> nor does it look good. Instead, let's make these helpers take a snapshot
> of all available counters.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

This looks much better, and most of the callstacks involved here are
very flat, so the increased stack consumption should be alright.

The only exception there is the threshold code, which can happen from
the direct reclaim path and thus with a fairly deep stack already.

Would it be better to leave mem_cgroup_usage() alone, open-code it,
and then use tree_stat() and tree_events() only for v2 memory.stat?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
