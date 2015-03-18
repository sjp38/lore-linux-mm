Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 866516B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:35:59 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so40788532pdn.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 04:35:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id km1si35492382pab.14.2015.03.18.04.35.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 04:35:58 -0700 (PDT)
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150317102508.GG28112@dhcp22.suse.cz>
	<20150317132926.GA1824@phnom.home.cmpxchg.org>
	<20150317141729.GI28112@dhcp22.suse.cz>
	<20150317172628.GA5109@phnom.home.cmpxchg.org>
	<20150317194136.GA31691@dhcp22.suse.cz>
In-Reply-To: <20150317194136.GA31691@dhcp22.suse.cz>
Message-Id: <201503182035.FJD69716.FMOHLOOFQFtVSJ@I-love.SAKURA.ne.jp>
Date: Wed, 18 Mar 2015 20:35:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I'm not opposing to have fundamental solutions. As you know the fundamental
solution will need many years to complete, I'm asking for interim workaround
which we can use now.

Michal Hocko wrote:
> The problem, as I see it, is that such a change cannot be pushed to
> Linus tree without extensive testing because there are thousands of code
> paths which never got exercised. We have basically two options here.

Your options are based on your proposal.
We can have different options based on Johannes's and my proposal.

> Either have a non-upstream patch (e.g. sitting in mmotm and linux-next)
> and have developers to do their testing. This will surely help to
> catch a lot of fallouts and fix them right away. But we will miss those
> who are using Linus based trees and would be willing to help to test
> in their loads which we never dreamed of.
> The other option would be pushing an experimental code to the Linus
> tree (and distribution kernels) and allow people to turn it on to help
> testing.

The third option is to purge majority of code paths which never got
exercised, by replacing kmalloc() with kmalloc_nofail() where amount of
requested size is known to be <= PAGE_SIZE bytes.

The third option becomes possible if we "allow triggering the OOM killer for
both __GFP_FS allocations and !__GFP_FS allocations" and "introduce the
OOM-killer timeout" so that OOM-deadlock which we are already observing can
be handled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
