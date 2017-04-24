Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA58F6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 04:42:22 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l11so210549717iod.15
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 01:42:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i72si7437839pgd.403.2017.04.24.01.42.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 01:42:21 -0700 (PDT)
Date: Mon, 24 Apr 2017 10:42:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-ID: <20170424084216.GB1739@dhcp22.suse.cz>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
 <alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
 <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1704181435560.112481@chino.kir.corp.google.com>
 <20170419111342.GF29789@dhcp22.suse.cz>
 <20170419132212.GA3514@redhat.com>
 <20170419133339.GI29789@dhcp22.suse.cz>
 <20170422081030.GA5476@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170422081030.GA5476@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

On Sat 22-04-17 10:10:34, Stanislaw Gruszka wrote:
[...]
> > This whole special casing
> > of debug_guardpage_minorder is just too strange to me. We do have a rate
> > limit to not flood the log.
> 
> I added this check to skip warning if buddy allocator fail, what I
> considered likely scenario taking the conditions. The check remove
> warning completely, rate limit only limit the speed warnings shows in
> logs.

Yes and this is what I argue against. The feature limits the amount of
_usable_ memory and as such it changes the behavior of the allocator
which can lead to all sorts of problems (including high memory pressure,
stalls, OOM etc.). The warning is there to help debug all those
problems and removing it just changes that behavior in an unexpected
way. This is just wrong thing to do IMHO. Even worse so when it
motivates to make other code in the allocator more complicated. If there
is really a problem logs flooded by the allocation failures while using
the guard page we should address it by a more strict ratelimiting.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
