Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 084B06B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 11:39:15 -0400 (EDT)
Received: by oies66 with SMTP id s66so31064847oie.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 08:39:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n189si5786872oia.128.2015.10.21.08.39.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 08:39:13 -0700 (PDT)
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable() checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
	<20151021143337.GD8805@dhcp22.suse.cz>
	<alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
	<20151021145505.GE8805@dhcp22.suse.cz>
In-Reply-To: <20151021145505.GE8805@dhcp22.suse.cz>
Message-Id: <201510220039.BIF64554.OMOVFLJFFOSQHt@I-love.SAKURA.ne.jp>
Date: Thu, 22 Oct 2015 00:39:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, cl@linux.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Michal Hocko wrote:
> On Wed 21-10-15 09:49:07, Christoph Lameter wrote:
> > On Wed, 21 Oct 2015, Michal Hocko wrote:
> > 
> > > Because all the WQ workers are stuck somewhere, maybe in the memory
> > > allocation which cannot make any progress and the vmstat update work is
> > > queued behind them.

After invoking the OOM killer, we can easily observe that vmstat_update
cannot be processed due to memory allocation by disk_events_workfn stalls.
http://lkml.kernel.org/r/201509120019.BJI48986.OOSVMJtOLFQHFF@I-love.SAKURA.ne.jp

I worried that blocking forever from workqueue is an exclusive occupation of
workqueue. In fact, changing to GFP_ATOMIC avoids this problem.
http://lkml.kernel.org/r/201503012017.EAD00571.HOOJVOStMFLFQF@I-love.SAKURA.ne.jp

Now we realized that we are hitting this problem before invoking the OOM
killer. The situation is similar to the case after the OOM killer is
invoked; there are no reclaimable pages but vmstat_update cannot be
processed. We are caught by a small difference of vmstat counter values.

> > >
> > > At least this is my current understanding.
> > 
> > Eww. Maybe need a queue that does not do such evil things as memory
> > allocation?
> 
> I am not sure how to achieve that. Requiring non-sleeping worker would
> work out but do we have enough users to add such an API?

If a queue does not need to sleep, can't that queue be processed from
timer context (e.g. mod_timer()) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
