Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD666B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 20:21:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 63so3181173pgc.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:21:44 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u1si1141492pgc.810.2017.08.28.17.21.42
        for <linux-mm@kvack.org>;
        Mon, 28 Aug 2017 17:21:43 -0700 (PDT)
Date: Tue, 29 Aug 2017 09:22:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm/slub: wake up kswapd for initial high order
 allocation
Message-ID: <20170829002222.GA14489@js1304-P5Q-DELUXE>
References: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
 <f1423efc-3c60-c03e-0d81-f2e8fcccbcd6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f1423efc-3c60-c03e-0d81-f2e8fcccbcd6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Mon, Aug 28, 2017 at 12:04:41PM +0200, Vlastimil Babka wrote:
> On 08/28/2017 03:11 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > slub uses higher order allocation than it actually needs. In this case,
> > we don't want to do direct reclaim to make such a high order page since
> > it causes a big latency to the user. Instead, we would like to fallback
> > lower order allocation that it actually needs.
> > 
> > However, we also want to get this higher order page in the next time
> > in order to get the best performance and it would be a role of
> > the background thread like as kswapd and kcompactd. To wake up them,
> > we should not clear __GFP_KSWAPD_RECLAIM.
> > 
> > Unlike this intention, current code clears __GFP_KSWAPD_RECLAIM so fix it.
> > 
> > Note that this patch does some clean up, too.
> > __GFP_NOFAIL is cleared twice so remove one.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hm, so this seems to revert Mel's 444eb2a449ef ("mm: thp: set THP defrag
> by default to madvise and add a stall-free defrag option") wrt the slub
> allocate_slab() part. AFAICS the intention in Mel's patch was that he
> removed a special case in __alloc_page_slowpath() where including
> __GFP_THISNODE and lacking ~__GFP_DIRECT_RECLAIM effectively means also
> lacking __GFP_KSWAPD_RECLAIM. The commit log claims that slab/slub might
> change behavior so he moved the removal of __GFP_KSWAPD_RECLAIM to them.
> 
> But AFAICS, only slab uses __GFP_THISNODE, while slub doesn't. So your
> patch would indeed revert an unintentional change of Mel's commit. Is it
> right or do I miss something?

I didn't look at that patch. What I tried here is just restoring first
intention of this code. I now realize that Mel did it for specific
purpose. Thanks for notifying it.

Anyway, your analysis looks correct and this change doesn't hurt Mel's
intention and restores original behaviour of the code. I will add your
analysis on the commit description and resubmit it. Is it okay to you?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
