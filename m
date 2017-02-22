Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD956B0388
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 23:12:23 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id n127so61580285qkf.3
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 20:12:23 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 10si17419qtu.139.2017.02.21.20.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 20:12:22 -0800 (PST)
Date: Tue, 21 Feb 2017 20:11:57 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V2 6/7] proc: show MADV_FREE pages info in smaps
Message-ID: <20170222041156.GA4077@shli-mbp.local>
References: <cover.1486163864.git.shli@fb.com>
 <1239fb2871c55d63e7e649ad14c6dabaef131d66.1486163864.git.shli@fb.com>
 <20170222024721.GA17580@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170222024721.GA17580@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Feb 22, 2017 at 11:47:21AM +0900, Minchan Kim wrote:
> On Fri, Feb 03, 2017 at 03:33:22PM -0800, Shaohua Li wrote:
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > ---
> >  fs/proc/task_mmu.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index ee3efb2..8f2423f 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -440,6 +440,7 @@ struct mem_size_stats {
> >  	unsigned long private_dirty;
> >  	unsigned long referenced;
> >  	unsigned long anonymous;
> > +	unsigned long lazyfree;
> >  	unsigned long anonymous_thp;
> >  	unsigned long shmem_thp;
> >  	unsigned long swap;
> > @@ -456,8 +457,11 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
> >  	int i, nr = compound ? 1 << compound_order(page) : 1;
> >  	unsigned long size = nr * PAGE_SIZE;
> >  
> > -	if (PageAnon(page))
> > +	if (PageAnon(page)) {
> >  		mss->anonymous += size;
> > +		if (!PageSwapBacked(page))
> 
> How about this?
> 
> 		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))

Yes, already fixed like this.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
