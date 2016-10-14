Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97D696B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 11:03:58 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id l84so193961208ywe.5
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 08:03:58 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id r82si202737wma.1.2016.10.14.08.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 08:03:57 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id z189so203127wmb.1
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 08:03:57 -0700 (PDT)
Date: Fri, 14 Oct 2016 17:03:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161014150355.GH6063@dhcp22.suse.cz>
References: <1476340749-13281-1-git-send-email-ming.ling@spreadtrum.com>
 <20161013080936.GG21678@dhcp22.suse.cz>
 <20161014083219.GA20260@spreadtrum.com>
 <20161014113044.GB6063@dhcp22.suse.cz>
 <20161014134604.GA2179@blaptop>
 <20161014135334.GF6063@dhcp22.suse.cz>
 <20161014144448.GA2899@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161014144448.GA2899@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ming Ling <ming.ling@spreadtrum.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On Fri 14-10-16 23:44:48, Minchan Kim wrote:
> On Fri, Oct 14, 2016 at 03:53:34PM +0200, Michal Hocko wrote:
> > On Fri 14-10-16 22:46:04, Minchan Kim wrote:
> > [...]
> > > > > > Why don't you simply mimic what shrink_inactive_list does? Aka count the
> > > > > > number of isolated pages and then account them when appropriate?
> > > > > >
> > > > > I think i am correcting clearly wrong part. So, there is no need to
> > > > > describe it too detailed. It's a misunderstanding, and i will add
> > > > > more comments as you suggest.
> > > > 
> > > > OK, so could you explain why you prefer to relyon __PageMovable rather
> > > > than do a trivial counting during the isolation?
> > > 
> > > I don't get it. Could you elaborate it a bit more?
> > 
> > It is really simple. You can count the number of file and anonymous
> > pages while they are isolated and then account them to NR_ISOLATED_*
> > later. Basically the same thing we do during the reclaim. We absolutely
> > do not have to rely on __PageMovable and make this code more complex
> > than necessary.
> 
> I don't understand your point.
> isolate_migratepages_block can isolate any movable pages, for instance,
> anon, file and non-lru and they are isolated into cc->migratepges.
> Then, acct_isolated accounts them to NR_ISOLATED_*.
> Isn't it same with the one you suggested?
> The problem is we should identify which pages is non-lru movable first.
> If it's not non-lru, it means the page is either anon or file so we
> can account them. 
> That's exactly waht Ming Ling did.
> 
> Sorry if I didn't get your point. Maybe, it would be better to give
> pseudo code out of your mind for better understanding rather than
> several ping-ping with vague words.

diff --git a/mm/compaction.c b/mm/compaction.c
index 0409a4ad6ea1..6584705a46f6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -685,7 +685,8 @@ static bool too_many_isolated(struct zone *zone)
  */
 static unsigned long
 isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
-			unsigned long end_pfn, isolate_mode_t isolate_mode)
+			unsigned long end_pfn, isolate_mode_t isolate_mode,
+			unsigned long *isolated_file, unsigned long *isolated_anon)
 {
 	struct zone *zone = cc->zone;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
@@ -866,6 +867,10 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
+		if (page_is_file_cache(page))
+			(*isolated_file)++;
+		else
+			(*isolated_anon)++;
 
 isolate_success:
 		list_add(&page->lru, &cc->migratepages);

Makes more sense?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
