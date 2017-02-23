Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF026B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 14:05:14 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id d88so105467ybi.3
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 11:05:14 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g88si5562786ioj.172.2017.02.23.11.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 11:05:13 -0800 (PST)
Date: Thu, 23 Feb 2017 11:04:46 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V4 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170223190446.GA32825@shli-mbp.local>
References: <cover.1487788131.git.shli@fb.com>
 <a1a28aa85280a7b3fd6145604eed4132228bd6d1.1487788131.git.shli@fb.com>
 <20170223155827.GB4031@cmpxchg.org>
 <20170223162601.GA18526@brenorobert-mbp.dhcp.thefacebook.com>
 <20170223182206.GA5686@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170223182206.GA5686@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Thu, Feb 23, 2017 at 01:22:06PM -0500, Johannes Weiner wrote:
> On Thu, Feb 23, 2017 at 08:26:03AM -0800, Shaohua Li wrote:
> > On Thu, Feb 23, 2017 at 10:58:27AM -0500, Johannes Weiner wrote:
> > > Hi Shaohua,
> > > 
> > > On Wed, Feb 22, 2017 at 10:50:41AM -0800, Shaohua Li wrote:
> > > > @@ -268,6 +268,12 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
> > > >  		int lru = page_lru_base_type(page);
> > > >  
> > > >  		del_page_from_lru_list(page, lruvec, lru);
> > > > +		if (PageAnon(page) && !PageSwapBacked(page)) {
> > > > +			SetPageSwapBacked(page);
> > > > +			/* charge to anon scanned/rotated reclaim_stat */
> > > > +			file = 0;
> > > > +			lru = LRU_INACTIVE_ANON;
> > > > +		}
> > > 
> > > As per my previous feedback, please remove this. Write-after-free will
> > > be caught and handled in the reclaimer, read-after-free is a bug that
> > > really doesn't require optimizing page aging for. And we definitely
> > > shouldn't declare invalid data suddenly valid because it's being read.
> > 
> > GUP could run into this. Don't we move the page because it's hot? I think it's
> > not just about page aging. If we leave the page there, page reclaim will just
> > waste time to reclaim the pages which should't be reclaimed.
> 
> There is just no convincing justification to add this code, because it
> optimizes something that doesn't have a real world application. If we
> just delete this branch, for all intents and purposes the outcome will
> be perfectly acceptable.

Ok, looks you want to ignore all corner cases, the gup case is one and the
unmap failure and mlock case we discussed before are another. I don't disagree
with the intention, but I had the feeling those code will eventually come back.
Anyway, I'll delete this code in next post.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
