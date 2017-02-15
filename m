Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7186A44059E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 11:11:43 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so65351564wjc.4
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 08:11:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n22si5591213wra.214.2017.02.15.08.11.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 08:11:42 -0800 (PST)
Subject: Re: [PATCH v2 00/10] try to reduce fragmenting fallbacks
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170213110701.vb4e6zrwhwliwm7k@techsingularity.net>
 <37f46f4c-4006-a76a-bf0a-5a4e3b0d68e6@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <eefd3aaf-b680-9e66-38e2-cfb56211bfcd@suse.cz>
Date: Wed, 15 Feb 2017 17:11:38 +0100
MIME-Version: 1.0
In-Reply-To: <37f46f4c-4006-a76a-bf0a-5a4e3b0d68e6@suse.cz>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/15/2017 03:29 PM, Vlastimil Babka wrote:
> Results for patch 4 ("count movable pages when stealing from pageblock")
> are really puzzling me, as it increases the number of fragmenting events
> for reclaimable allocations, implicating "reclaimable placed with (i.e.
> falling back to) unmovable" (which is not listed separately above, but
> follows logically from "reclaimable placed with movable" not changing
> that much). I really wonder why is that. The patch effectively only
> changes the decision to change migratetype of a pageblock, it doesn't
> affect the actual stealing decision (which is always true for
> RECLAIMABLE anyway, see can_steal_fallback()). Moreover, since we can't
> distinguish UNMOVABLE from RECLAIMABLE when counting, good_pages is 0
> and thus even the decision to change pageblock migratetype shouldn't be
> changed by the patch for this case. I must recheck the implementation...

Ah, there it is... not enough LISP

-       if (pages >= (1 << (pageblock_order-1)) ||
+       /* Claim the whole block if over half of it is free or good type */
+       if (free_pages + good_pages >= (1 << (pageblock_order-1)) ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
