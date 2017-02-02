Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3726B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 05:48:13 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id yr2so3034929wjc.4
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 02:48:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si28132202wrb.166.2017.02.02.02.48.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 02:48:11 -0800 (PST)
Date: Thu, 2 Feb 2017 11:48:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170202104808.GG22806@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
 <20170202104422.GF22806@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170202104422.GF22806@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 02-02-17 11:44:22, Michal Hocko wrote:
> On Tue 31-01-17 14:32:08, Vinayak Menon wrote:
> > During global reclaim, the nr_reclaimed passed to vmpressure
> > includes the pages reclaimed from slab. But the corresponding
> > scanned slab pages is not passed. This can cause total reclaimed
> > pages to be greater than scanned, causing an unsigned underflow
> > in vmpressure resulting in a critical event being sent to root
> > cgroup. So do not consider reclaimed slab pages for vmpressure
> > calculation. The reclaimed pages from slab can be excluded because
> > the freeing of a page by slab shrinking depends on each slab's
> > object population, making the cost model (i.e. scan:free) different
> > from that of LRU.
> 
> This might be true but what happens if the slab reclaim contributes
> significantly to the overal reclaim? This would be quite rare but not
> impossible.
> 
> I am wondering why we cannot simply make cap nr_reclaimed to nr_scanned
> and be done with this all? Sure it will be imprecise but the same will
> be true with this approach.

In other words something as "beautiful" as the following:
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 149fdf6c5c56..abea42817dd0 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -236,6 +236,15 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 		return;
 
 	/*
+	 * Due to accounting issues - e.g. THP contributing 1 to scanned but
+	 * potentially much more to reclaimed or SLAB pages not contributing
+	 * to scanned at all - we have to skew reclaimed to prevent from
+	 * wrong pressure levels due to overflows.
+	 */
+	if (reclaimed > scanned)
+		reclaimed = scanned;
+
+	/*
 	 * If we got here with no pages scanned, then that is an indicator
 	 * that reclaimer was unable to find any shrinkable LRUs at the
 	 * current scanning depth. But it does not mean that we should
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
