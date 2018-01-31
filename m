Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 661AA6B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:24:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id x188so444036wmg.2
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 12:24:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si2018430wrg.439.2018.01.31.12.24.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 12:24:41 -0800 (PST)
Date: Wed, 31 Jan 2018 21:24:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] few MM topics
Message-ID: <20180131202438.GA21609@dhcp22.suse.cz>
References: <20180124092649.GC21134@dhcp22.suse.cz>
 <20180131192104.GD4841@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131192104.GD4841@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-nvme@lists.infradead.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>

On Wed 31-01-18 11:21:04, Darrick J. Wong wrote:
> On Wed, Jan 24, 2018 at 10:26:49AM +0100, Michal Hocko wrote:
[...]
> > - I would also love to talk to some FS people and convince them to move
> >   away from GFP_NOFS in favor of the new scope API. I know this just
> >   means to send patches but the existing code is quite complex and it
> >   really requires somebody familiar with the specific FS to do that
> >   work.
> 
> Hm, are you talking about setting PF_MEMALLOC_NOFS instead of passing
> *_NOFS to allocation functions and whatnot?

yes memalloc_nofs_{save,restore}

> Right now XFS will set it
> on any thread which has a transaction open, but that doesn't help for
> fs operations that don't have transactions (e.g. reading metadata,
> opening files).  I suppose we could just set the flag any time someone
> stumbles into the fs code from userspace, though you're right that seems
> daunting.

I would really love to see the code to take the nofs scope
(memalloc_nofs_save) at the point where the FS "critical" section starts
(from the reclaim recursion POV). This would both document the context
and also limit NOFS allocations to bare minumum.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
