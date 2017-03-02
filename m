Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED036B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:00:13 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m67so4814201qkf.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:00:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y5si6871991qka.176.2017.03.02.05.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 05:00:11 -0800 (PST)
Date: Thu, 2 Mar 2017 08:00:09 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302130009.GC3213@bfoster.bfoster>
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
 <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
 <42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp>
 <20170302103520.GC1404@dhcp22.suse.cz>
 <20170302122426.GA3213@bfoster.bfoster>
 <20170302124909.GE1404@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302124909.GE1404@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Mar 02, 2017 at 01:49:09PM +0100, Michal Hocko wrote:
> On Thu 02-03-17 07:24:27, Brian Foster wrote:
> > On Thu, Mar 02, 2017 at 11:35:20AM +0100, Michal Hocko wrote:
> > > On Thu 02-03-17 19:04:48, Tetsuo Handa wrote:
> > > [...]
> > > > So, commit 5d17a73a2ebeb8d1("vmalloc: back off when the current task is
> > > > killed") implemented __GFP_KILLABLE flag and automatically applied that
> > > > flag. As a result, those who are not ready to fail upon SIGKILL are
> > > > confused. ;-)
> > > 
> > > You are right! The function is documented it might fail but the code
> > > doesn't really allow that. This seems like a bug to me. What do you
> > > think about the following?
> > > ---
> > > From d02cb0285d8ce3344fd64dc7e2912e9a04bef80d Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Thu, 2 Mar 2017 11:31:11 +0100
> > > Subject: [PATCH] xfs: allow kmem_zalloc_greedy to fail
> > > 
> > > Even though kmem_zalloc_greedy is documented it might fail the current
> > > code doesn't really implement this properly and loops on the smallest
> > > allowed size for ever. This is a problem because vzalloc might fail
> > > permanently. Since 5d17a73a2ebe ("vmalloc: back off when the current
> > > task is killed") such a failure is much more probable than it used to
> > > be. Fix this by bailing out if the minimum size request failed.
> > > 
> > > This has been noticed by a hung generic/269 xfstest by Xiong Zhou.
> > > 
> > > Reported-by: Xiong Zhou <xzhou@redhat.com>
> > > Analyzed-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  fs/xfs/kmem.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > > diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> > > index 339c696bbc01..ee95f5c6db45 100644
> > > --- a/fs/xfs/kmem.c
> > > +++ b/fs/xfs/kmem.c
> > > @@ -34,6 +34,8 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
> > >  	size_t		kmsize = maxsize;
> > >  
> > >  	while (!(ptr = vzalloc(kmsize))) {
> > > +		if (kmsize == minsize)
> > > +			break;
> > >  		if ((kmsize >>= 1) <= minsize)
> > >  			kmsize = minsize;
> > >  	}
> > 
> > More consistent with the rest of the kmem code might be to accept a
> > flags argument and do something like this based on KM_MAYFAIL.
> 
> Well, vmalloc doesn't really support GFP_NOFAIL semantic right now for
> the same reason it doesn't support GFP_NOFS. So I am not sure this is a
> good idea.
> 

Not sure I follow..? I'm just suggesting to control the loop behavior
based on the KM_ flag, not to do or change anything wrt to GFP_ flags.

> > The one
> > current caller looks like it would pass it, but I suppose we'd still
> > need a mechanism to break out should a new caller not pass that flag.
> > Would a fatal_signal_pending() check in the loop as well allow us to
> > break out in the scenario that is reproduced here?
> 
> Yes that check would work as well I just thought the break out when the
> minsize request fails to be more logical. There might be other reasons
> to fail the request and looping here seems just wrong. But whatever you
> or other xfs people prefer.

There may be higher level reasons for why this code should or should not
loop, that just seems like a separate issue to me. My thinking is more
that this appears to be how every kmem_*() function operates today and
it seems a bit out of place to change behavior of one to fix a bug.

Maybe I'm missing something though.. are we subject to the same general
problem in any of the other kmem_*() functions that can currently loop
indefinitely?

Brian

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
