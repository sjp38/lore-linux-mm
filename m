Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 277E06B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 13:32:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v14so405950pgq.11
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 10:32:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4-v6si754280plr.391.2018.04.09.10.32.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 10:32:01 -0700 (PDT)
Date: Mon, 9 Apr 2018 19:31:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Block layer use of __GFP flags
Message-ID: <20180409173158.GN21835@dhcp22.suse.cz>
References: <20180408065425.GD16007@bombadil.infradead.org>
 <aea2f6bcae3fe2b88e020d6a258706af1ce1a58b.camel@wdc.com>
 <20180408190825.GC5704@bombadil.infradead.org>
 <63d16891d115de25ac2776088571d7e90dab867a.camel@wdc.com>
 <20180409090016.GA21771@dhcp22.suse.cz>
 <0dc5f067247d10f7e3c60f544b2a9019c898fbad.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0dc5f067247d10f7e3c60f544b2a9019c898fbad.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "martin@lichtvoll.de" <martin@lichtvoll.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hare@suse.com" <hare@suse.com>, "oleksandr@natalenko.name" <oleksandr@natalenko.name>, "willy@infradead.org" <willy@infradead.org>, "axboe@kernel.dk" <axboe@kernel.dk>

On Mon 09-04-18 15:03:45, Bart Van Assche wrote:
> On Mon, 2018-04-09 at 11:00 +0200, Michal Hocko wrote:
> > On Mon 09-04-18 04:46:22, Bart Van Assche wrote:
> > [...]
> > [...]
> > > diff --git a/drivers/ide/ide-pm.c b/drivers/ide/ide-pm.c
> > > index ad8a125defdd..3ddb464b72e6 100644
> > > --- a/drivers/ide/ide-pm.c
> > > +++ b/drivers/ide/ide-pm.c
> > > @@ -91,7 +91,7 @@ int generic_ide_resume(struct device *dev)
> > >  
> > >  	memset(&rqpm, 0, sizeof(rqpm));
> > >  	rq = blk_get_request_flags(drive->queue, REQ_OP_DRV_IN,
> > > -				   BLK_MQ_REQ_PREEMPT);
> > > +				   BLK_MQ_REQ_PREEMPT, __GFP_RECLAIM);
> > 
> > Is there any reason to use __GFP_RECLAIM directly. I guess you wanted to
> > have GFP_NOIO semantic, right? So why not be explicit about that. Same
> > for other instances of this flag in the patch
> 
> Hello Michal,
> 
> Thanks for the review. The use of __GFP_RECLAIM in this code (which was
> called __GFP_WAIT in the past) predates the git history.

Yeah, __GFP_WAIT -> __GFP_RECLAIM was a pseudo automated change IIRC.
Anyway GFP_NOIO should be pretty much equivalent and self explanatory.
__GFP_RECLAIM is more of an internal thing than something be for used as
a plain gfp mask.

Sure, there is no real need to change that but if you want to make the
code more neat and self explanatory I would go with GFP_NOIO.

Just my 2c
-- 
Michal Hocko
SUSE Labs
