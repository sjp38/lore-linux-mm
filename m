Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31E726B03A0
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:54:36 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a20so39063527wme.5
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:54:36 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id 18si13401314wmq.97.2016.11.21.04.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:54:34 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id xy5so3758172wjc.1
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:54:33 -0800 (PST)
Date: Mon, 21 Nov 2016 13:54:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Don't fail costly __GFP_NOFAIL
 allocations.
Message-ID: <20161121125431.GA18112@dhcp22.suse.cz>
References: <1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161121060313.GB29816@dhcp22.suse.cz>
 <201611212016.GGG52176.LSOVtOHJFMQFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201611212016.GGG52176.LSOVtOHJFMQFFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, stable@vger.kernel.org

On Mon 21-11-16 20:16:40, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 17-11-16 21:50:04, Tetsuo Handa wrote:
> > > Filesystem code might request costly __GFP_NOFAIL !__GFP_REPEAT GFP_NOFS
> > > allocations. But commit 0a0337e0d1d13446 ("mm, oom: rework oom detection")
> > > overlooked that __GFP_NOFAIL allocation requests need to invoke the OOM
> > > killer and retry even if order > PAGE_ALLOC_COSTLY_ORDER && !__GFP_REPEAT.
> > > The caller will crash if such allocation request failed.
> >
> > Could you point to such an allocation request please? Costly GFP_NOFAIL
> > requests are a really high requirement and I am even not sure we should
> > support them. buffered_rmqueue already warns about order > 1 NOFAIL
> > allocations.
> 
> That question is pointless. You are simply lucky that you see only order 0 or
> order 1. There are many __GFP_NOFAIL allocations where order is determined at
> runtime. There is no guarantee that order 2 and above never happens.

You are pushing to the extreme again! Your changelog stated this might
be an existing and the real life problem and that is the reason I've
asked. Especially because you have marked the patch for stable. As I've
said in my previous response. Your patch looks correct, I am just not
entirely happy to clutter the code path even more for GFP_NOFAIL for
something we maybe even do not support. All the checks we have there are
head spinning already.

So we have two options, either we have real users of GFP_NOFAIL for
costly orders and handle that properly with all that information in the
changelog or simply rely on the warning and fix callers who do that
accidentally. But please stop this, theoretically something might do
$THIS_RANDOM_GFP_FLAGS + order combination and we absolutely must handle
that in the allocator.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
