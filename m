Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 033F06B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 10:48:53 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so76314571wma.2
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 07:48:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si69978168wmd.31.2017.01.02.07.48.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 07:48:51 -0800 (PST)
Date: Mon, 2 Jan 2017 16:48:41 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 0/9] mm/swap: Regular page swap optimizations
Message-ID: <20170102154841.GG18058@quack2.suse.cz>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
 <20161227074503.GA10616@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161227074503.GA10616@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, jack@suse.cz

Hi,

On Tue 27-12-16 16:45:03, Minchan Kim wrote:
> > Patch 3 splits the swap cache radix tree into 64MB chunks, reducing
> >         the rate that we have to contende for the radix tree.
> 
> To me, it's rather hacky. I think it might be common problem for page cache
> so can we think another generalized way like range_lock? Ccing Jan.

I agree on the hackyness of the patch and that page cache would suffer with
the same contention (although the files are usually smaller than swap so it
would not be that visible I guess). But I don't see how range lock would
help here - we need to serialize modifications of the tree structure itself
and that is difficult to achieve with the range lock. So what you would
need is either a different data structure for tracking swap cache entries
or a finer grained locking of the radix tree.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
