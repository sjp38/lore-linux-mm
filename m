Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9C26B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 08:18:35 -0500 (EST)
Received: by widem10 with SMTP id em10so22607888wid.5
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 05:18:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q7si2696574wix.82.2015.03.03.05.18.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 05:18:32 -0800 (PST)
Date: Tue, 3 Mar 2015 14:18:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 4/4] cxgb4: drop __GFP_NOFAIL allocation
Message-ID: <20150303131826.GB2409@dhcp22.suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
 <1425304483-7987-5-git-send-email-mhocko@suse.cz>
 <201503032122.HJD73998.OFFMQFLHtJOSOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503032122.HJD73998.OFFMQFLHtJOSOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, david@fromorbit.com, tytso@mit.edu, mgorman@suse.de, sparclinux@vger.kernel.org, vipul@chelsio.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 03-03-15 21:22:22, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > index ccf3436024bc..f351920fc293 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > @@ -1220,6 +1220,10 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
> >  	struct fw_filter_wr *fwr;
> >  	unsigned int ftid;
> >  
> > +	skb = alloc_skb(sizeof(*fwr), GFP_KERNEL);
> > +	if (!skb)
> > +		return -ENOMEM;
> > +
> >  	/* If the new filter requires loopback Destination MAC and/or VLAN
> >  	 * rewriting then we need to allocate a Layer 2 Table (L2T) entry for
> >  	 * the filter.
> > @@ -1227,19 +1231,21 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
> >  	if (f->fs.newdmac || f->fs.newvlan) {
> >  		/* allocate L2T entry for new filter */
> >  		f->l2t = t4_l2t_alloc_switching(adapter->l2t);
> > -		if (f->l2t == NULL)
> > +		if (f->l2t == NULL) {
> > +			kfree(skb);
> 
> I think we need to use kfree_skb() than kfree() for memory allocated by alloc_skb().

Definitely! Good point, thanks!

Andrew, I've noticed you have picked up the patch. Should I resend or
the below incremental one is good enough?
---
