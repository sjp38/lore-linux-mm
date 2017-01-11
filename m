Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B04846B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 10:52:43 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id l2so28782861wml.5
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:52:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1si4877089wjf.2.2017.01.11.07.52.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 07:52:42 -0800 (PST)
Date: Wed, 11 Jan 2017 16:52:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
 added to -mm tree
Message-ID: <20170111155239.GD16365@dhcp22.suse.cz>
References: <586edadc.figmHAGrTxvM7Wei%akpm@linux-foundation.org>
 <20170110235250.GA7130@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110235250.GA7130@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, hillf.zj@alibaba-inc.com, mgorman@suse.de, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Wed 11-01-17 08:52:50, Minchan Kim wrote:
[...]
> > @@ -2055,8 +2055,8 @@ static bool inactive_list_is_low(struct
> >  	if (!file && !total_swap_pages)
> >  		return false;
> >  
> > -	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > -	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > +	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > +	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> >  
> 
> the decision of deactivating is based on eligible zone's LRU size,
> not whole zone so why should we need to get a trace of all zones's LRU?

Strictly speaking, the total_ counters are not necessary for making the
decision. I found reporting those numbers useful regardless because this
will give us also an information how large is the eligible portion of
the LRU list. We do not have any other tracepoint which would report
that.
 
[...]
> > @@ -2223,7 +2228,7 @@ static void get_scan_count(struct lruvec
> >  	 * lruvec even if it has plenty of old anonymous pages unless the
> >  	 * system is under heavy pressure.
> >  	 */
> > -	if (!inactive_list_is_low(lruvec, true, sc) &&
> > +	if (!inactive_list_is_low(lruvec, true, sc, false) &&
> 
> Hmm, I was curious why you added trace boolean arguement and found it here.
> Yes, here is not related to deactivation directly but couldn't we help to
> trace it unconditionally?

I've had it like that when I was debugging the mentioned bug and found
it a bit disturbing. It generated more output than I would like and it
wasn't really clear from which code path  this has been called from.

> With that, we can know why VM reclaim only
> file-backed page on slow device although enough anonymous pages on fast
> swap like zram are enough.

That would be something for a separate tracepoint in g_s_c

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
