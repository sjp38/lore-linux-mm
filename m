Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 793546B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 09:46:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so110111354pfj.6
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 06:46:17 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id zz3si15564166pac.76.2016.10.14.06.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 06:46:16 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id r16so7305665pfg.3
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 06:46:16 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Date: Fri, 14 Oct 2016 22:46:04 +0900
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161014134604.GA2179@blaptop>
References: <1476340749-13281-1-git-send-email-ming.ling@spreadtrum.com>
 <20161013080936.GG21678@dhcp22.suse.cz>
 <20161014083219.GA20260@spreadtrum.com>
 <20161014113044.GB6063@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161014113044.GB6063@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ming Ling <ming.ling@spreadtrum.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, minchan@kernel.org, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

Hi, Michal,

On Fri, Oct 14, 2016 at 01:30:44PM +0200, Michal Hocko wrote:

< snip>

> > void putback_movable_pages(struct list_head *l)
> > {
> > 	......
> > 	/*
> > 	 * We isolated non-lru movable page so here we can use
> >  	 * __PageMovable because LRU page's mapping cannot have
> > 	 * PAGE_MAPPING_MOVABLE.
> > 	 */
> > 	if (unlikely(__PageMovable(page))) {
> > 		VM_BUG_ON_PAGE(!PageIsolated(page), page);
> > 		lock_page(page);
> > 		if (PageMovable(page))
> > 			putback_movable_page(page);
> > 		else
> > 			__ClearPageIsolated(page);
> > 		unlock_page(page);
> > 		put_page(page);
> > 	} else {
> > 		putback_lru_page(page);
> > 	}
> > }
> 
> I am not familiar with this code enough to comment but to me it all
> sounds quite subtle.

It was due to lacking of page flags on 32bit machine, sadly.
Better idea is always welcome.

> 
> > > Why don't you simply mimic what shrink_inactive_list does? Aka count the
> > > number of isolated pages and then account them when appropriate?
> > >
> > I think i am correcting clearly wrong part. So, there is no need to
> > describe it too detailed. It's a misunderstanding, and i will add
> > more comments as you suggest.
> 
> OK, so could you explain why you prefer to relyon __PageMovable rather
> than do a trivial counting during the isolation?

I don't get it. Could you elaborate it a bit more?

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
