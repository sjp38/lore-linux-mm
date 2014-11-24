Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B96DA6B00B5
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 11:55:48 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so6363072wiv.5
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:55:48 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id ot1si12007672wjc.164.2014.11.24.08.55.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 08:55:47 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id k14so12792678wgh.10
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:55:47 -0800 (PST)
Date: Mon, 24 Nov 2014 17:55:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/5] mm: Kill shrinker's global semaphore.
Message-ID: <20141124165544.GB11745@curandero.mameluci.net>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
 <201411231350.DHI12456.OLOFFJSFtQVMHO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411231350.DHI12456.OLOFFJSFtQVMHO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sun 23-11-14 13:50:50, Tetsuo Handa wrote:
> >From 92aec48e3b2e21c3716654670a24890f34c58683 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 23 Nov 2014 13:39:25 +0900
> Subject: [PATCH 2/5] mm: Kill shrinker's global semaphore.
> 
> Currently register_shrinker()/unregister_shrinker() calls down_write()
> while shrink_slab() calls down_read_trylock().

> This implies that the OOM killer becomes disabled because
> shrink_slab() pretends "we reclaimed some slab memory" even
> if "no slab memory can be reclaimed" when somebody calls
> register_shrinker()/unregister_shrinker() while one of shrinker
> functions allocates memory and/or holds mutex which may take
> unpredictably long duration to complete.

Which load would be SLAB mostly that this would matter?

Other than that I thought that {un}register_shrinker are really unlikely
paths called during initialization and tear down which usually do not
happen during OOM conditions.

> This patch replaces global semaphore with per a shrinker refcounter
> so that shrink_slab() can respond "we could not reclaim slab memory"
> when out_of_memory() needs to be called.
> 
> Before this patch, response time of addition/removal are unpredictable
> when one of shrinkers are in use by shrink_slab(), nearly 0 otherwise.
> 
> After this patch, response time of addition is nearly 0. Response time of
> removal remains unpredictable when the shrinker to remove is in use by
> shrink_slab(), nearly two RCU grace periods otherwise.

I cannot judge the patch itself as this is out of my area but is the
complexity worth it? I think the OOM argument is bogus because there
SLAB usually doesn't dominate the memory consumption in my experience.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
