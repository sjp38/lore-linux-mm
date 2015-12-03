Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BAC566B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:54:54 -0500 (EST)
Received: by wmww144 with SMTP id w144so11564185wmw.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:54:54 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id l70si1918531wmb.75.2015.12.03.00.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 00:54:53 -0800 (PST)
Received: by wmec201 with SMTP id c201so12448206wme.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:54:53 -0800 (PST)
Date: Thu, 3 Dec 2015 09:54:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151203085451.GC9264@dhcp22.suse.cz>
References: <20151201133455.GB27574@bbox>
 <20151202101643.GC25284@dhcp22.suse.cz>
 <20151203013404.GA30779@bbox>
 <20151203021006.GA31041@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203021006.GA31041@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-12-15 11:10:06, Minchan Kim wrote:
> On Thu, Dec 03, 2015 at 10:34:04AM +0900, Minchan Kim wrote:
> > On Wed, Dec 02, 2015 at 11:16:43AM +0100, Michal Hocko wrote:
> > > On Tue 01-12-15 22:34:55, Minchan Kim wrote:
> > > > With new test on mmotm-2015-11-25-17-08, I saw below WARNING message
> > > > several times. I couldn't see it with reverting new THP refcount
> > > > redesign.
> > > 
> > > Just a wild guess. What prevents migration/compaction from calling
> > > split_huge_page on thp zero page? There is VM_BUG_ON but it is not clear
> > 
> > I guess migration should work with LRU pages now but zero page couldn't
> > stay there.

Ahh, you are right. I have missed PageLRU check in isolate_migratepages_block
pfn walker.

> > > whether you run with CONFIG_DEBUG_VM enabled.
> > 
> > I enabled VM_DEBUG_VM.
> > 
> > > 
> > > Also, how big is the underflow?
[...]
> > nr_pages 293 new -324
> > nr_pages 16 new -340
> > nr_pages 342 new -91
> > nr_pages 246 new -337
> > nr_pages 15 new -352
> > nr_pages 15 new -367

They are quite large but that is not that surprising if we consider that
we are batching many uncharges at once.
 
> My guess is that it's related to new feature of Kirill's THP 'PageDoubleMap'
> so a THP page could be mapped a pte but !pmd_trans_huge(*pmd) so memcg
> precharge in move_charge should handle it?

I am not familiar with the current state of THP after the rework
unfortunately. So if I got you right then you are saying that
pmd_trans_huge_lock fails to notice a THP so we will not charge it as
THP and only charge one head page and then the tear down path will
correctly recognize it as a THP and uncharge the full size, right?

I have to admit I have no idea how PageDoubleMap works and how can
pmd_trans_huge fail.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
