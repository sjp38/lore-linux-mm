Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 673F86B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:06:26 -0400 (EDT)
Received: by wijp11 with SMTP id p11so36742561wij.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:06:26 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id pb10si18936499wjb.185.2015.10.22.08.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 08:06:24 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so140142725wic.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:06:24 -0700 (PDT)
Date: Thu, 22 Oct 2015 17:06:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151022150623.GE26854@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
 <20151021143337.GD8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
 <20151021145505.GE8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022140944.GA30579@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu 22-10-15 23:09:44, Tejun Heo wrote:
> On Thu, Oct 22, 2015 at 08:39:11AM -0500, Christoph Lameter wrote:
> > On Thu, 22 Oct 2015, Tetsuo Handa wrote:
> > 
> > > The problem would be that the "struct task_struct" to execute vmstat_update
> > > job does not exist, and will not be able to create one on demand because we
> > > are stuck at __GFP_WAIT allocation. Therefore adding a dedicated kernel
> > > thread for vmstat_update job would work. But ...
> > 
> > Yuck. Can someone please get this major screwup out of the work queue
> > subsystem? Tejun?
> 
> Hmmm?  Just use a dedicated workqueue with WQ_MEM_RECLAIM.

Do I get it right that if vmstat_update has its own workqueue with
WQ_MEM_RECLAIM then there is a _guarantee_ that the rescuer will always
be able to process vmstat_update work from the requested CPU?

That should be sufficient because vmstat_update doesn't sleep on
allocation. I agree that this would be a more appropriate fix.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
