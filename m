Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 67E84280730
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 17:24:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k10so121706199pgs.11
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 14:24:10 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 127si2006835pgh.893.2017.08.22.14.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 14:24:09 -0700 (PDT)
Date: Tue, 22 Aug 2017 14:24:08 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170822212408.GC28715@tassilo.jf.intel.com>
References: <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <20170822190828.GO32112@worktop.programming.kicks-ass.net>
 <CA+55aFzPt401xpRzd6Qu-WuDNGneR_m7z25O=0YspNi+cLRb8w@mail.gmail.com>
 <20170822193714.GZ28715@tassilo.jf.intel.com>
 <alpine.DEB.2.20.1708221605220.18344@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1708221605220.18344@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 22, 2017 at 04:08:52PM -0500, Christopher Lameter wrote:
> On Tue, 22 Aug 2017, Andi Kleen wrote:
> 
> > We only see it on 4S+ today. But systems are always getting larger,
> > so what's a large system today, will be a normal medium scale system
> > tomorrow.
> >
> > BTW we also collected PT traces for the long hang cases, but it was
> > hard to find a consistent pattern in them.
> 
> Hmmm... Maybe it would be wise to limit the pages autonuma can migrate?
> 
> If a page has more than 50 refcounts or so then dont migrate it. I think
> high number of refcounts and a high frequewncy of calls are reached in
> particular for pages of the c library. Attempting to migrate those does
> not make much sense anyways because the load may shift and another
> function may become popular. We may end up shifting very difficult to
> migrate pages back and forth.

I believe in this case it's used by threads, so a reference count limit
wouldn't help.

If migrating code was a problem I would probably rather just disable
migration of read-only pages.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
