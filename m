Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D96B46B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 10:58:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so44526921wmw.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 07:58:23 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id 71si39214187wmr.122.2016.05.11.07.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 07:58:22 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mm, compaction: avoid uninitialized variable use
Date: Wed, 11 May 2016 16:52:41 +0200
Message-ID: <2695751.e2s15gCWav@wuerfel>
In-Reply-To: <20160511144407.GA21503@dhcp22.suse.cz>
References: <1462973126-1183468-1-git-send-email-arnd@arndb.de> <20160511144407.GA21503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wednesday 11 May 2016 16:44:07 Michal Hocko wrote:
> On Wed 11-05-16 15:24:44, Arnd Bergmann wrote:
> > A recent rework of the compaction code introduced a warning about
> > an uninitialized variable when CONFIG_COMPACTION is disabled and
> > __alloc_pages_direct_compact() does not set its 'compact_result'
> > output argument:
> > 
> > mm/page_alloc.c: In function '__alloc_pages_nodemask':
> > mm/page_alloc.c:3651:6: error: 'compact_result' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > 
> > This adds another check for CONFIG_COMPACTION to ensure we never
> > evaluate the uninitialized variable in this configuration, which
> > is probably the simplest way to avoid the warning.
> 
> I think that hiding this into __alloc_pages_direct_compact is a better
> idea. See the diff below

Ok, sounds good.

> --- 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4950d01ff935..14e3b4d93adc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3300,6 +3300,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>                 unsigned int alloc_flags, const struct alloc_context *ac,
>                 enum migrate_mode mode, enum compact_result *compact_result)
>  {
> +       *compact_result = COMPACT_DEFERRED;
>         return NULL;
>  }
> 

I thought about this but didn't know which COMPACT_* value was appropriate here.

The behavior then changes a bit with your approach compared to mine,
because 

                if (compact_result == COMPACT_DEFERRED)
                        goto nopage;

is true now. I assume this is what we want though.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
