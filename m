Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3765E6B0260
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:32:19 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so38715231wjd.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:32:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s28si1466359wra.10.2017.01.26.02.32.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 02:32:17 -0800 (PST)
Date: Thu, 26 Jan 2017 11:32:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170126103216.GG6590@dhcp22.suse.cz>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net>
 <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
 <20170126100802.GF6590@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126100802.GF6590@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu 26-01-17 11:08:02, Michal Hocko wrote:
> On Thu 26-01-17 10:36:49, Daniel Borkmann wrote:
> > On 01/26/2017 08:43 AM, Michal Hocko wrote:
> > > On Wed 25-01-17 21:16:42, Daniel Borkmann wrote:
> [...]
> > > > I assume that kvzalloc() is still the same from [1], right? If so, then
> > > > it would unfortunately (partially) reintroduce the issue that was fixed.
> > > > If you look above at flags, they're also passed to __vmalloc() to not
> > > > trigger OOM in these situations I've experienced.
> > > 
> > > Pushing __GFP_NORETRY to __vmalloc doesn't have the effect you might
> > > think it would. It can still trigger the OOM killer becauset the flags
> > > are no propagated all the way down to all allocations requests (e.g.
> > > page tables). This is the same reason why GFP_NOFS is not supported in
> > > vmalloc.
> > 
> > Ok, good to know, is that somewhere clearly documented (like for the
> > case with kmalloc())?
> 
> I am afraid that we really suck on this front. I will add something.

So I have folded the following to the patch 1. It is in line with
kvmalloc and hopefully at least tell more than the current code.
---
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d89034a393f2..6c1aa2c68887 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1741,6 +1741,13 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
  *	Allocate enough pages to cover @size from the page level
  *	allocator with @gfp_mask flags.  Map them into contiguous
  *	kernel virtual space, using a pagetable protection of @prot.
+ *
+ *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_REPEAT
+ *	and __GFP_NOFAIL are not supported
+ *
+ *	Any use of gfp flags outside of GFP_KERNEL should be consulted
+ *	with mm people.
+ *
  */
 static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
