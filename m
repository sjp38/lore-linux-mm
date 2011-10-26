Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 00CCE6B0035
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 02:26:45 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p9Q6QgCj012476
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:26:42 -0700
Received: from vcbfl15 (vcbfl15.prod.google.com [10.220.204.79])
	by wpaz1.hot.corp.google.com with ESMTP id p9Q6P4SI031481
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:26:41 -0700
Received: by vcbfl15 with SMTP id fl15so1932869vcb.9
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:26:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110252322220.20273@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
	<20111025090956.GA10797@suse.de>
	<alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com>
	<CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
	<alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com>
	<CAMbhsRS+-jn7d1bTd4F0_RB9860iWjOHLfOkDsqLfWEUbR3TYA@mail.gmail.com>
	<alpine.DEB.2.00.1110252322220.20273@chino.kir.corp.google.com>
Date: Tue, 25 Oct 2011 23:26:40 -0700
Message-ID: <CAMbhsRQdrWRLkj7U-u2AZxM11mSUNj5_1K27g58cMBo1Js1Yeg@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 11:24 PM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 25 Oct 2011, Colin Cross wrote:
>
>> > Or, rather, when pm_restrict_gfp_mask() clears __GFP_IO and __GFP_FS that
>> > it also has the same behavior as __GFP_NORETRY in should_alloc_retry() by
>> > setting a variable in file scope.
>> >
>>
>> Why do you prefer that over adding a gfp_required_mask?
>>
>
> Because it avoids an unnecessary OR in the page and slab allocator
> fastpaths which are red hot :)
>

Makes sense.  What about this?  Official patch to follow.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fef8dc3..59cd4ff 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1786,6 +1786,13 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
                return 0;

        /*
+        * If PM has disabled I/O, OOM is disabled and reclaim is unlikely
+        * to make any progress.  To prevent a livelock, don't retry.
+        */
+       if (!(gfp_allowed_mask & __GFP_FS))
+               return 0;
+
+       /*
         * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
         * means __GFP_NOFAIL, but that may not be true in other
         * implementations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
