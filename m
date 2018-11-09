Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9AA46B06C8
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 04:56:08 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y23-v6so879104eds.12
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 01:56:08 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p26-v6si365562edi.197.2018.11.09.01.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 01:56:07 -0800 (PST)
Date: Fri, 9 Nov 2018 10:56:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181109095604.GC5321@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri 09-11-18 18:41:53, Tetsuo Handa wrote:
> On 2018/11/09 17:43, Michal Hocko wrote:
> > @@ -4364,6 +4353,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> >  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
> >  	struct alloc_context ac = { };
> >  
> > +	/*
> > +	 * In the slowpath, we sanity check order to avoid ever trying to
> 
> Please keep the comment up to dated.

Does this following look better?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9fc10a1029cf..bf9aecba4222 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4354,10 +4354,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 	struct alloc_context ac = { };
 
 	/*
-	 * In the slowpath, we sanity check order to avoid ever trying to
-	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
-	 * be using allocators in order of preference for an area that is
-	 * too large.
+	 * There are several places where we assume that the order value is sane
+	 * so bail out early if the request is out of bound.
 	 */
 	if (order >= MAX_ORDER) {
 		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));

> I don't like that comments in OOM code is outdated.
> 
> > +	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
> > +	 * be using allocators in order of preference for an area that is
> > +	 * too large.
> > +	 */
> > +	if (order >= MAX_ORDER) {
> 
> Also, why not to add BUG_ON(gfp_mask & __GFP_NOFAIL); here?

Because we do not want to blow up the kernel just because of a stupid
usage of the allocator. Can you think of an example where it would
actually make any sense?

I would argue that such a theoretical abuse would blow up on an
unchecked NULL ptr access. Isn't that enough?
-- 
Michal Hocko
SUSE Labs
