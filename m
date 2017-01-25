Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6F096B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:42:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e4so138656455pfg.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 00:42:02 -0800 (PST)
Received: from out0-158.mail.aliyun.com (out0-158.mail.aliyun.com. [140.205.0.158])
        by mx.google.com with ESMTP id e185si17859795pgc.284.2017.01.25.00.42.01
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 00:42:01 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161220134904.21023-1-mhocko@kernel.org> <20161220134904.21023-3-mhocko@kernel.org> <001f01d272f7$e53acbd0$afb06370$@alibaba-inc.com> <20170124124048.GE6867@dhcp22.suse.cz> <003a01d276d8$c41e0180$4c5a0480$@alibaba-inc.com> <20170125075956.GA32377@dhcp22.suse.cz>
In-Reply-To: <20170125075956.GA32377@dhcp22.suse.cz>
Subject: Re: [PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
Date: Wed, 25 Jan 2017 16:41:54 +0800
Message-ID: <004101d276e6$e1e829d0$a5b87d70$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'David Rientjes' <rientjes@google.com>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>

On Wednesday, January 25, 2017 4:00 PM Michal Hocko wrote: 
> On Wed 25-01-17 15:00:51, Hillf Danton wrote:
> > On Tuesday, January 24, 2017 8:41 PM Michal Hocko wrote:
> > > On Fri 20-01-17 16:33:36, Hillf Danton wrote:
> > > >
> > > > On Tuesday, December 20, 2016 9:49 PM Michal Hocko wrote:
> > > > >
> > > > > @@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
> > > > >  	 * make sure exclude 0 mask - all other users should have at least
> > > > >  	 * ___GFP_DIRECT_RECLAIM to get here.
> > > > >  	 */
> > > > > -	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> > > > > +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
> > > > >  		return true;
> > > > >
> > > > As to GFP_NOFS|__GFP_NOFAIL request, can we check gfp mask
> > > > one bit after another?
> > > >
> > > > 	if (oc->gfp_mask) {
> > > > 		if (!(oc->gfp_mask & __GFP_FS))
> > > > 			return false;
> > > >
> > > > 		/* No service for request that can handle fail result itself */
> > > > 		if (!(oc->gfp_mask & __GFP_NOFAIL))
> > > > 			return false;
> > > > 	}
> > >
> > > I really do not understand this request.
> >
> > It's a request of both NOFS and NOFAIL, and I think we can keep it from
> > hitting oom killer by shuffling the current gfp checks.
> > I hope it can make nit sense to your work.
> >
> 
> I still do not understand. The whole point we are doing the late
> __GFP_FS check is explained in 3da88fb3bacf ("mm, oom: move GFP_NOFS
> check to out_of_memory"). And the reason why I am _removing_
> __GFP_NOFAIL is explained in the changelog of this patch.
> 
> > > This patch is removing the __GFP_NOFAIL part...
> >
> > Yes, and I don't stick to handling NOFAIL requests inside oom.
> >
> > > Besides that why should they return false?
> >
> > It's feedback to page allocator that no kill is issued, and
> > extra attention is needed.
> 
> Be careful, the semantic of out_of_memory is different. Returning false
> means that the oom killer has been disabled and so the allocation should
> fail rather than loop for ever.
> 
By returning  false, I mean that oom killer is making no progress.
And I prefer to give up looping if oom killer can't help.
It's a change in the current semantic to fail the request and I have
to test it isn't bad.

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
