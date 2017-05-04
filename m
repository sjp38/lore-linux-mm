Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C162C831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 07:44:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g67so1341155wrd.0
        for <linux-mm@kvack.org>; Thu, 04 May 2017 04:44:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si2251346wra.71.2017.05.04.04.44.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 04:44:11 -0700 (PDT)
Date: Thu, 4 May 2017 13:43:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file
 is low
Message-ID: <20170504114358.GD31540@dhcp22.suse.cz>
References: <20170419001405.GA13364@bbox>
 <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
 <20170420060904.GA3720@bbox>
 <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
 <20170502080246.GD14593@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705021331450.116499@chino.kir.corp.google.com>
 <20170503061528.GB1236@dhcp22.suse.cz>
 <20170503070656.GA8836@dhcp22.suse.cz>
 <20170503084952.GD8836@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705031547360.50439@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1705031547360.50439@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 03-05-17 15:52:04, David Rientjes wrote:
> On Wed, 3 May 2017, Michal Hocko wrote:
[...]
> >  	/*
> > -	 * If there is enough inactive page cache, i.e. if the size of the
> > -	 * inactive list is greater than that of the active list *and* the
> > -	 * inactive list actually has some pages to scan on this priority, we
> > -	 * do not reclaim anything from the anonymous working set right now.
> > -	 * Without the second condition we could end up never scanning an
> > -	 * lruvec even if it has plenty of old anonymous pages unless the
> > -	 * system is under heavy pressure.
> > +	 * Make sure there are enough pages on the biased LRU before we go
> > +	 * and do an exclusive reclaim from that list, i.e. if the
> > +	 * size of the inactive list is greater than that of the active list
> > +	 * *and* the inactive list actually has some pages to scan on this
> > +	 * priority.
> > +	 * Without the second condition we could end up never scanning other
> > +	 * lruvecs even if they have plenty of old pages unless the system is
> > +	 * under heavy pressure.
> >  	 */
> > -	if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
> > -	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
> > -		scan_balance = SCAN_FILE;
> > +	lru = LRU_INACTIVE_ANON + LRU_FILE * (scan_balance == SCAN_FILE);
> 
> This part seems to complicate the logic since it determines the lru under 
> test based on the current setting of scan_balance.  I think I prefer 
> individual heuristics with well written comments, but others may feel 
> differently about this.

I do not claim the code would more obvious than before but it gets rid
of the duplication which is usually a good thing. This size check has
the same reasoning regardless of the type of the LRU. But I am not going
to insist...
 
> > +	if (!inactive_list_is_low(lruvec, is_file_lru(lru), memcg, sc, false) &&
> > +	    lruvec_lru_size(lruvec, lru, sc->reclaim_idx) >> sc->priority)
> >  		goto out;
> > -	}
> >  
> >  	scan_balance = SCAN_FRACT;
> >  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
