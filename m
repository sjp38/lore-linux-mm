Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2696B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 08:05:27 -0400 (EDT)
Received: by widdi4 with SMTP id di4so199064642wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 05:05:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x19si9720549wjq.43.2015.05.06.05.05.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 05:05:25 -0700 (PDT)
Date: Wed, 6 May 2015 13:05:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
Message-ID: <20150506120521.GI2462@suse.de>
References: <554030D1.8080509@hp.com>
 <5543F802.9090504@hp.com>
 <554415B1.2050702@hp.com>
 <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
 <20150505104514.GC2462@suse.de>
 <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
 <20150505221329.GE2462@suse.de>
 <20150505152549.037679566fad8c593df176ed@linux-foundation.org>
 <20150506071246.GF2462@suse.de>
 <20150506102220.GH2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150506102220.GH2462@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 06, 2015 at 11:22:20AM +0100, Mel Gorman wrote:
> On Wed, May 06, 2015 at 08:12:46AM +0100, Mel Gorman wrote:
> > On Tue, May 05, 2015 at 03:25:49PM -0700, Andrew Morton wrote:
> > > On Tue, 5 May 2015 23:13:29 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > > Alternatively, the page allocator can go off and synchronously
> > > > > initialize some pageframes itself.  Keep doing that until the
> > > > > allocation attempt succeeds.
> > > > > 
> > > > 
> > > > That was rejected during review of earlier attempts at this feature on
> > > > the grounds that it impacted allocator fast paths. 
> > > 
> > > eh?  Changes are only needed on the allocation-attempt-failed path,
> > > which is slow-path.
> > 
> > We'd have to distinguish between falling back to other zones because the
> > high zone is artifically exhausted and normal ALLOC_BATCH exhaustion. We'd
> > also have to avoid falling back to remote nodes prematurely. While I have
> > not tried an implementation, I expected they would need to be in the fast
> > paths unless I used jump labels to get around it. I'm going to try altering
> > when we initialise instead so that it happens earlier.
> > 
> 
> Which looks as follows. Waiman, a test on the 24TB machine would be
> appreciated again. This patch should be applied instead of "mm: meminit:
> Take into account that large system caches scale linearly with memory"
> 
> ---8<---
> mm: meminit: Finish initialisation of memory before basic setup
> 

*sigh* Eventually build testing found the need for this

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1cef116727b6..052b9ba65b66 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -243,7 +243,7 @@ static inline void reset_deferred_meminit(pg_data_t *pgdat)
 }
 
 /* Returns true if the struct page for the pfn is uninitialised */
-static inline bool __init early_page_uninitialised(unsigned long pfn)
+static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 {
 	int nid = early_pfn_to_nid(pfn);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
