Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 684C66B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 02:01:11 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 14so264063747pgg.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 23:01:11 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id u201si22427889pgb.84.2017.01.24.23.01.08
        for <linux-mm@kvack.org>;
        Tue, 24 Jan 2017 23:01:10 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161220134904.21023-1-mhocko@kernel.org> <20161220134904.21023-3-mhocko@kernel.org> <001f01d272f7$e53acbd0$afb06370$@alibaba-inc.com> <20170124124048.GE6867@dhcp22.suse.cz>
In-Reply-To: <20170124124048.GE6867@dhcp22.suse.cz>
Subject: Re: [PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
Date: Wed, 25 Jan 2017 15:00:51 +0800
Message-ID: <003a01d276d8$c41e0180$4c5a0480$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'David Rientjes' <rientjes@google.com>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>

On Tuesday, January 24, 2017 8:41 PM Michal Hocko wrote: 
> On Fri 20-01-17 16:33:36, Hillf Danton wrote:
> >
> > On Tuesday, December 20, 2016 9:49 PM Michal Hocko wrote:
> > >
> > > @@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
> > >  	 * make sure exclude 0 mask - all other users should have at least
> > >  	 * ___GFP_DIRECT_RECLAIM to get here.
> > >  	 */
> > > -	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> > > +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
> > >  		return true;
> > >
> > As to GFP_NOFS|__GFP_NOFAIL request, can we check gfp mask
> > one bit after another?
> >
> > 	if (oc->gfp_mask) {
> > 		if (!(oc->gfp_mask & __GFP_FS))
> > 			return false;
> >
> > 		/* No service for request that can handle fail result itself */
> > 		if (!(oc->gfp_mask & __GFP_NOFAIL))
> > 			return false;
> > 	}
> 
> I really do not understand this request. 

It's a request of both NOFS and NOFAIL, and I think we can keep it from
hitting oom killer by shuffling the current gfp checks.
I hope it can make nit sense to your work.

> This patch is removing the __GFP_NOFAIL part... 

Yes, and I don't stick to handling NOFAIL requests inside oom.
 
> Besides that why should they return false?

It's feedback to page allocator that no kill is issued, and 
extra attention is needed.

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
