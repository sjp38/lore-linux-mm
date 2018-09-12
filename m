Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B36AF8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:25:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g18-v6so1029648edg.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:25:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v19-v6si1475798eda.162.2018.09.12.08.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 08:25:55 -0700 (PDT)
Date: Wed, 12 Sep 2018 17:25:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180912152553.GA20287@dhcp22.suse.cz>
References: <20180907130550.11885-1-mhocko@kernel.org>
 <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
 <20180911115613.GR10951@dhcp22.suse.cz>
 <20180912135417.GA15194@redhat.com>
 <20180912142126.GM10951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912142126.GM10951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stefan Priebe <s.priebe@profihost.ag>

On Wed 12-09-18 16:21:26, Michal Hocko wrote:
> On Wed 12-09-18 09:54:17, Andrea Arcangeli wrote:
[...]
> > I wasn't particularly happy about your patch because it still swaps
> > with certain defrag settings which is still allowing things that
> > shouldn't happen without some kind of privileged capability.
> 
> Well, I am not really sure about defrag=always. I would rather care
> about the default behavior to plug the regression first. And think about
> `always' mode on top. Or is this a no-go from your POV?

In other words the following on top
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 56c9aac4dc86..723e8d77c5ef 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -644,7 +644,7 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, un
 #endif
 
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | this_node);
+		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
-- 
Michal Hocko
SUSE Labs
