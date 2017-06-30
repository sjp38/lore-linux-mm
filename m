Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 525D82802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 11:42:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 130so3165278wmq.4
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 08:42:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si6121119wrd.260.2017.06.30.08.42.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 08:42:28 -0700 (PDT)
Date: Fri, 30 Jun 2017 17:42:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
Message-ID: <20170630154224.GA9714@dhcp22.suse.cz>
References: <20170630141847.GN22917@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630141847.GN22917@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 30-06-17 16:18:47, Michal Hocko wrote:
> fe53ca54270a ("mm: use early_pfn_to_nid in page_ext_init") seem
> to silently depend on CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID resp.
> CONFIG_HAVE_MEMBLOCK_NODE_MAP. early_pfn_to_nid is returning zero with
> !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) && !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
> I am not sure how widely is this used but such a code is tricky. I see
> how catching early allocations during defered initialization might be
> useful but a subtly broken code sounds like a problem to me.  So is
> fe53ca54270a worth this or we should revert it?

I've dug little bit further. It seems that only s390 and ia64 select
HAVE_ARCH_EARLY_PFN_TO_NID. Much more architectures enabled
HAVE_MEMBLOCK_NODE_MAP though but still
alpha, arc, arm, avr32, blackfin, c6x, cris, frv, h8300, hexagon,
Kconfig, m32r, m68k, mn10300, nios2, openrisc, parisc, tile, um,
unicore32, xtensa do not. I can only see alpha having NUMA and even that
is marked BROKEN. So it seems that this is not a real problem after all.

Still subtle, so I guess we want to have the following. What do you
think?

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 16532fa0bb64..894697c1e6f5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1055,6 +1055,7 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
 static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 {
+	BUILD_BUG_ON(!IS_ENABLED(CONFIG_NUMA));
 	return 0;
 }
 #endif
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
