Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B04966B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 07:49:13 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v66so28605430wrc.4
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 04:49:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si10956181wmu.42.2017.03.02.04.49.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 04:49:12 -0800 (PST)
Date: Thu, 2 Mar 2017 13:49:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302124909.GE1404@dhcp22.suse.cz>
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
 <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
 <42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp>
 <20170302103520.GC1404@dhcp22.suse.cz>
 <20170302122426.GA3213@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302122426.GA3213@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu 02-03-17 07:24:27, Brian Foster wrote:
> On Thu, Mar 02, 2017 at 11:35:20AM +0100, Michal Hocko wrote:
> > On Thu 02-03-17 19:04:48, Tetsuo Handa wrote:
> > [...]
> > > So, commit 5d17a73a2ebeb8d1("vmalloc: back off when the current task is
> > > killed") implemented __GFP_KILLABLE flag and automatically applied that
> > > flag. As a result, those who are not ready to fail upon SIGKILL are
> > > confused. ;-)
> > 
> > You are right! The function is documented it might fail but the code
> > doesn't really allow that. This seems like a bug to me. What do you
> > think about the following?
> > ---
> > From d02cb0285d8ce3344fd64dc7e2912e9a04bef80d Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Thu, 2 Mar 2017 11:31:11 +0100
> > Subject: [PATCH] xfs: allow kmem_zalloc_greedy to fail
> > 
> > Even though kmem_zalloc_greedy is documented it might fail the current
> > code doesn't really implement this properly and loops on the smallest
> > allowed size for ever. This is a problem because vzalloc might fail
> > permanently. Since 5d17a73a2ebe ("vmalloc: back off when the current
> > task is killed") such a failure is much more probable than it used to
> > be. Fix this by bailing out if the minimum size request failed.
> > 
> > This has been noticed by a hung generic/269 xfstest by Xiong Zhou.
> > 
> > Reported-by: Xiong Zhou <xzhou@redhat.com>
> > Analyzed-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  fs/xfs/kmem.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> > index 339c696bbc01..ee95f5c6db45 100644
> > --- a/fs/xfs/kmem.c
> > +++ b/fs/xfs/kmem.c
> > @@ -34,6 +34,8 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
> >  	size_t		kmsize = maxsize;
> >  
> >  	while (!(ptr = vzalloc(kmsize))) {
> > +		if (kmsize == minsize)
> > +			break;
> >  		if ((kmsize >>= 1) <= minsize)
> >  			kmsize = minsize;
> >  	}
> 
> More consistent with the rest of the kmem code might be to accept a
> flags argument and do something like this based on KM_MAYFAIL.

Well, vmalloc doesn't really support GFP_NOFAIL semantic right now for
the same reason it doesn't support GFP_NOFS. So I am not sure this is a
good idea.

> The one
> current caller looks like it would pass it, but I suppose we'd still
> need a mechanism to break out should a new caller not pass that flag.
> Would a fatal_signal_pending() check in the loop as well allow us to
> break out in the scenario that is reproduced here?

Yes that check would work as well I just thought the break out when the
minsize request fails to be more logical. There might be other reasons
to fail the request and looping here seems just wrong. But whatever you
or other xfs people prefer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
