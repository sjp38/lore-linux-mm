Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 45A9382F66
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:36:02 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so141438278wic.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:36:01 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id ci12si15985844wjb.148.2015.10.22.08.36.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 08:36:01 -0700 (PDT)
Received: by wijp11 with SMTP id p11so38088621wij.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:36:01 -0700 (PDT)
Date: Thu, 22 Oct 2015 17:35:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151022153559.GF26854@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
 <20151021143337.GD8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
 <20151021145505.GE8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022151528.GG30579@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Fri 23-10-15 00:15:28, Tejun Heo wrote:
> On Thu, Oct 22, 2015 at 05:06:23PM +0200, Michal Hocko wrote:
> > Do I get it right that if vmstat_update has its own workqueue with
> > WQ_MEM_RECLAIM then there is a _guarantee_ that the rescuer will always
> > be able to process vmstat_update work from the requested CPU?
> 
> Yeah.

Thanks for the confirmation.

> > That should be sufficient because vmstat_update doesn't sleep on
> > allocation. I agree that this would be a more appropriate fix.
> 
> The problem seems to be reclaim path busy looping waiting for
> vmstat_update and workqueue thinking that the work item must be making
> forward-progress and thus not starting the next work item.

But that shouldn't happen because the allocation path does cond_resched
even when nothing is really reclaimable (e.g. wait_iff_congested from
__alloc_pages_slowpath).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
