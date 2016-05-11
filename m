Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF4D6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 10:53:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so44415363wmw.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 07:53:25 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id gf10si9945225wjc.141.2016.05.11.07.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 07:53:24 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e201so9946222wme.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 07:53:24 -0700 (PDT)
Date: Wed, 11 May 2016 16:53:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, compaction: avoid uninitialized variable use
Message-ID: <20160511145321.GA22776@dhcp22.suse.cz>
References: <1462973126-1183468-1-git-send-email-arnd@arndb.de>
 <20160511144407.GA21503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160511144407.GA21503@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-05-16 16:44:07, Michal Hocko wrote:
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
> > 
> > A more elaborate rework might make this more readable.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: 13cff7b81275 ("mm, compaction: simplify __alloc_pages_direct_compact feedback interface")
> 
> Please do not use SHA for mmotm commits because they are unstable and
> change each linux-next release.
> 
> --- 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4950d01ff935..14e3b4d93adc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3300,6 +3300,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		unsigned int alloc_flags, const struct alloc_context *ac,
>  		enum migrate_mode mode, enum compact_result *compact_result)
>  {
> +	*compact_result = COMPACT_DEFERRED;

Sorry, this should have been COMPACT_SKIPPED.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
