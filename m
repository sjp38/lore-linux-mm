Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA1C6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 09:15:31 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id i1so338550oib.2
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 06:15:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j131si119550oih.225.2017.09.01.06.15.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 06:15:30 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm,page_alloc: don't call __node_reclaim() without scoped allocation constraints.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1504269608-9202-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170901125524.p3xtglunuufgfqcq@dhcp22.suse.cz>
In-Reply-To: <20170901125524.p3xtglunuufgfqcq@dhcp22.suse.cz>
Message-Id: <201709012215.BBB43272.OOLFMFQHFVSJOt@I-love.SAKURA.ne.jp>
Date: Fri, 1 Sep 2017 22:15:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, mgorman@suse.de, vbabka@suse.cz

Michal Hocko wrote:
> On Fri 01-09-17 21:40:07, Tetsuo Handa wrote:
> > We are doing the first allocation attempt before calling
> > current_gfp_context(). But since slab shrinker functions might depend on
> > __GFP_FS and/or __GFP_IO masking, calling slab shrinker functions from
> > node_reclaim() from get_page_from_freelist() without calling
> > current_gfp_context() has possibility of deadlock. Therefore, make sure
> > that the first memory allocation attempt does not call slab shrinker
> > functions.
> 
> But we do filter gfp_mask at __node_reclaim layer. Not really ideal from
> the readability point of view and maybe it could be cleaned up there
> shouldn't be any bug AFAICS. On the other hand we can save few cycles on
> the hot path that way and there are people who care about every cycle
> there and node reclaim is absolutely the last thing they care about.

Ah, indeed. We later do

struct scan_control sc = {
	.gfp_mask = current_gfp_context(gfp_mask),
}

in __node_reclaim(). OK, there will be no problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
