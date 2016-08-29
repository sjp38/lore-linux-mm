Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D2130830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 10:50:50 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so99684984lfg.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 07:50:50 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t81si12139890wmf.64.2016.08.29.07.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 07:50:49 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so9883125wmg.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 07:50:49 -0700 (PDT)
Date: Mon, 29 Aug 2016 16:50:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: clarify COMPACTION Kconfig text
Message-ID: <20160829145047.GF2968@dhcp22.suse.cz>
References: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
 <20160829141045.GB2172@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160829141045.GB2172@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 29-08-16 10:10:45, Johannes Weiner wrote:
> On Tue, Aug 23, 2016 at 10:09:17AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > The current wording of the COMPACTION Kconfig help text doesn't
> > emphasise that disabling COMPACTION might cripple the page allocator
> > which relies on the compaction quite heavily for high order requests and
> > an unexpected OOM can happen with the lack of compaction. Make sure
> > we are vocal about that.
> 
> I find it weird to even have this as a config option after we removed
> lumpy reclaim. Why offer a configuration that may easily OOM on allocs
> that we don't even consider "costly" to generate? There might be some
> specialized setups that know they can live without the higher-order
> allocations and rather have the savings in kernel size, but I'd argue
> that for the vast majority of Linux setups compaction is an essential
> part of our VM at this point. Seems like a candidate for EXPERT to me.

I was thinking about making it depend on EXPERT as well but then I just
felt like making the text more verbose should be sufficient. If somebody
runs a kernel without COMPACTION and doesn't see any issues then why
should we make life harder for him. But I was thinking about a different
thing. We should warn that the compaction is disabled when the oom
killer hits for higher order. What do you think?
--- 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 10f686969fc4..b3c47072a206 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -406,6 +406,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
 		current->signal->oom_score_adj);
+	if (!IS_ENABLED(COMPACTION) && oc->order)
+		pr_warn("COMPACTION is disabled!!!\n");
 
 	cpuset_print_current_mems_allowed();
 	dump_stack();

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
