Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 4A1A16B0002
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 14:40:51 -0500 (EST)
Date: Tue, 12 Feb 2013 14:40:40 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie
 to a config option
Message-ID: <20130212194040.GO3016@phenom.dumpdata.com>
References: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com>
 <20130206190924.GB32275@kroah.com>
 <761b5c6e-df13-49ff-b322-97a737def114@default>
 <20130206214316.GA21148@kroah.com>
 <abbc2f75-2982-470c-a3ca-675933d112c3@default>
 <20130207000338.GB18984@kroah.com>
 <7393d8c5-fb02-4087-93d1-0f999fb3cafd@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7393d8c5-fb02-4087-93d1-0f999fb3cafd@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, sjenning@linux.vnet.ibm.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@linuxdriverproject.org, ngupta@vflare.org

On Mon, Feb 11, 2013 at 01:43:58PM -0800, Dan Magenheimer wrote:
> > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> 
> > So, how about this, please draw up a specific plan for how you are going
> > to get this code out of drivers/staging/  I want to see the steps
> > involved, who is going to be doing the work, and who you are going to
> > have to get to agree with your changes to make it happen.
> >  :
> > Yeah, a plan, I know it goes against normal kernel development
> > procedures, but hey, we're in our early 20's now, it's about time we
> > started getting responsible.
> 
> Hi Greg --
> 
> I'm a big fan of planning, though a wise boss once told me:
> "Plans fail... planning succeeds".
> 
> So here's the plan I've been basically trying to pursue since about
> ten months ago, ignoring the diversion due to "zcache1 vs zcache2"
> from last summer.  There is no new functionality on this plan
> other than as necessary from feedback obtained at or prior to
> LSF/MM in April 2012.
> 
> Hope this meets your needs, and feedback welcome!
> Dan
> 
> =======
> 
> ** ZCACHE PLAN FOR PROMOTION FROM STAGING **
> 
> PLAN STEPS
> 
> 1. merge zcache and ramster to eliminate horrible code duplication
> 2. converge on a predictable, writeback-capable allocator
> 3. use debugfs instead of sysfs (per akpm feedback in 2011)
> 4. zcache side of cleancache/mm WasActive patch
> 5. zcache side of frontswap exclusive gets
> 6. zcache must be able to writeback to physical swap disk
>     (per Andrea Arcangeli feedback in 2011)
> 7. implement adequate policy for writeback
> 8. frontswap/cleancache work to allow zcache to be loaded
>     as a module
> 9. get core mm developer to review
> 10. incorporate feedback from review
> 11. get review/acks from 1-2 additional mm developers
> 12. incorporate any feedback from additional mm reviews
> 13. propose location/file-naming in mm tree
> 14. repeat 9-13 as necessary until akpm is happy and merges
> 
> STATUS/OWNERSHIP
> 
> 1. DONE as part of "new" zcache; now in staging/zcache
> 2. DONE as part of "new" zcache (cf zbud.[ch]); now in staging/zcache
>     (this was the core of the zcache1 vs zcache2 flail)
> 3. DONE as part of "new" zcache; now in staging/zcache
> 4. DONE as part of "new" zcache; per cleancache performance
>     feedback see https://lkml.org/lkml/2011/8/17/351, now
>     in staging/zcache; dependent on proposed mm patch, see
>     https://lkml.org/lkml/2012/1/25/300 
> 5. DONE as part of "new" zcache; performance tuning only,
>     now in staging/zcache; dependent on frontswap patch
>     merged in 3.7 (33c2a174)
> 6. PROTOTYPED as part of "new" zcache; protoype is now
>     in staging/zcache but has bad memory leak; reimplemented
>     to use sjennings clever tricks and proposed mm patches
>     with new version posted https://lkml.org/lkml/2013/2/6/437;
>     rejected by GregKH as it smells like new functionality
> 
>     (******** YOU ARE HERE *********)
> 
> 7. PROTOTYPED as part of "new" zcache; now in staging/zcache;
>     needs more review (plan to discuss at LSF/MM 2013)
> 8. IN PROGRESS; owned by Konrad Wilk; v2 recently posted
>    http://lkml.org/lkml/2013/2/1/542

<nods> This is the frontswap/cleancache being able to use
modularized backends.

> 9. IN PROGRESS; owned by Konrad Wilk; Mel Gorman provided
>    great feedback in August 2012 (unfortunately of "old"
>    zcache)
> 10. Konrad posted series of fixes (that now need rebasing)
>     https://lkml.org/lkml/2013/2/1/566 

<nods> That way we can run those and the frontswap in parallel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
