Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5C7A6B02F4
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 08:55:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 136so184910wmm.4
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 05:55:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si76264wrh.252.2017.09.01.05.55.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 05:55:27 -0700 (PDT)
Date: Fri, 1 Sep 2017 14:55:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,page_alloc: don't call __node_reclaim() without
 scoped allocation constraints.
Message-ID: <20170901125524.p3xtglunuufgfqcq@dhcp22.suse.cz>
References: <1504269608-9202-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1504269608-9202-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

On Fri 01-09-17 21:40:07, Tetsuo Handa wrote:
> We are doing the first allocation attempt before calling
> current_gfp_context(). But since slab shrinker functions might depend on
> __GFP_FS and/or __GFP_IO masking, calling slab shrinker functions from
> node_reclaim() from get_page_from_freelist() without calling
> current_gfp_context() has possibility of deadlock. Therefore, make sure
> that the first memory allocation attempt does not call slab shrinker
> functions.

But we do filter gfp_mask at __node_reclaim layer. Not really ideal from
the readability point of view and maybe it could be cleaned up there
shouldn't be any bug AFAICS. On the other hand we can save few cycles on
the hot path that way and there are people who care about every cycle
there and node reclaim is absolutely the last thing they care about.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
