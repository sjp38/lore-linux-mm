Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 123AA6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 08:43:34 -0500 (EST)
Received: by wmuu63 with SMTP id u63so21662904wmu.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 05:43:33 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id q78si12183246wmg.72.2015.12.03.05.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 05:43:33 -0800 (PST)
Received: by wmuu63 with SMTP id u63so21662280wmu.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 05:43:32 -0800 (PST)
Date: Thu, 3 Dec 2015 14:43:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151203134326.GG9264@dhcp22.suse.cz>
References: <20151201133455.GB27574@bbox>
 <20151202101643.GC25284@dhcp22.suse.cz>
 <20151203013404.GA30779@bbox>
 <20151203021006.GA31041@bbox>
 <20151203085451.GC9264@dhcp22.suse.cz>
 <20151203125950.GA1428@bbox>
 <20151203133719.GF9264@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203133719.GF9264@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-12-15 14:37:19, Michal Hocko wrote:
> On Thu 03-12-15 21:59:50, Minchan Kim wrote:
> > On Thu, Dec 03, 2015 at 09:54:52AM +0100, Michal Hocko wrote:
> > > On Thu 03-12-15 11:10:06, Minchan Kim wrote:
> > > > On Thu, Dec 03, 2015 at 10:34:04AM +0900, Minchan Kim wrote:
> > > > > On Wed, Dec 02, 2015 at 11:16:43AM +0100, Michal Hocko wrote:
> [...]
> > > > > > Also, how big is the underflow?
> > > [...]
> > > > > nr_pages 293 new -324
> > > > > nr_pages 16 new -340
> > > > > nr_pages 342 new -91
> > > > > nr_pages 246 new -337
> > > > > nr_pages 15 new -352
> > > > > nr_pages 15 new -367
> > > 
> > > They are quite large but that is not that surprising if we consider that
> > > we are batching many uncharges at once.
> > >  
> > > > My guess is that it's related to new feature of Kirill's THP 'PageDoubleMap'
> > > > so a THP page could be mapped a pte but !pmd_trans_huge(*pmd) so memcg
> > > > precharge in move_charge should handle it?
> > > 
> > > I am not familiar with the current state of THP after the rework
> > > unfortunately. So if I got you right then you are saying that
> > > pmd_trans_huge_lock fails to notice a THP so we will not charge it as
> > > THP and only charge one head page and then the tear down path will
> > > correctly recognize it as a THP and uncharge the full size, right?
> > 
> > Exactly.
> 
> Hmm, but are pages represented by those ptes on the LRU list?
> __split_huge_pmd_locked doesn't seem to do any lru care. If they are not
> on any LRU then mem_cgroup_move_charge_pte_range should ignore such a pte
> and the THP (which the pte is part of) should stay in the original
> memcg.

Ohh, PageLRU is
PAGEFLAG(LRU, lru, PF_HEAD)

So we are checking the head and it is on LRU. Now I can see how this
might happen. Let me think about a fix...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
