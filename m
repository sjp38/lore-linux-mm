Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8A526B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 23:34:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so1206341611pgc.0
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 20:34:26 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b72si67783641pli.151.2017.01.02.20.34.25
        for <linux-mm@kvack.org>;
        Mon, 02 Jan 2017 20:34:26 -0800 (PST)
Date: Tue, 3 Jan 2017 13:34:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 0/9] mm/swap: Regular page swap optimizations
Message-ID: <20170103043411.GA15657@bbox>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
 <20161227074503.GA10616@bbox>
 <20170102154841.GG18058@quack2.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20170102154841.GG18058@quack2.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Nicholas Piggin <npiggin@gmail.com>

Hi Jan,

On Mon, Jan 02, 2017 at 04:48:41PM +0100, Jan Kara wrote:
> Hi,
> 
> On Tue 27-12-16 16:45:03, Minchan Kim wrote:
> > > Patch 3 splits the swap cache radix tree into 64MB chunks, reducing
> > >         the rate that we have to contende for the radix tree.
> > 
> > To me, it's rather hacky. I think it might be common problem for page cache
> > so can we think another generalized way like range_lock? Ccing Jan.
> 
> I agree on the hackyness of the patch and that page cache would suffer with
> the same contention (although the files are usually smaller than swap so it
> would not be that visible I guess). But I don't see how range lock would
> help here - we need to serialize modifications of the tree structure itself
> and that is difficult to achieve with the range lock. So what you would
> need is either a different data structure for tracking swap cache entries
> or a finer grained locking of the radix tree.

Thanks for the comment, Jan.

I think there are more general options. One is to shrink batching pages like
Mel and Tim had approached.

https://patchwork.kernel.org/patch/9008421/
https://patchwork.kernel.org/patch/9322793/

Or concurrent page cache by peter.

https://www.kernel.org/doc/ols/2007/ols2007v2-pages-311-318.pdf

Ccing Nick who might have an interest on lockless page cache.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
