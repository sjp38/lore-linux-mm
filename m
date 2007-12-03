Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB3I7Ng1021569
	for <linux-mm@kvack.org>; Mon, 3 Dec 2007 13:07:23 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB3I6xNc659652
	for <linux-mm@kvack.org>; Mon, 3 Dec 2007 13:07:21 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB3I6lCp010061
	for <linux-mm@kvack.org>; Mon, 3 Dec 2007 11:06:47 -0700
Date: Mon, 3 Dec 2007 10:06:38 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] mm: fix confusing __GFP_REPEAT related comments
Message-ID: <20071203180638.GB28850@us.ibm.com>
References: <20071129214828.GD20882@us.ibm.com> <20071202115857.GB31637@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071202115857.GB31637@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: haveblue@us.ibm.com, akpm@linux-foundation.org, mel@skynet.ie, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.12.2007 [03:58:57 -0800], William Lee Irwin III wrote:
> On Thu, Nov 29, 2007 at 01:48:28PM -0800, Nishanth Aravamudan wrote:
> > The definition and use of __GFP_REPEAT, __GFP_NOFAIL and __GFP_NORETRY
> > in the core VM have somewhat differing comments as to their actual
> > semantics. Annoyingly, the flags definition has inline and header
> > comments, which might be interpreted as not being equivalent. Just add
> > references to the header comments in the inline ones so they don't go
> > out of sync in the future. In their use in __alloc_pages() clarify that
> > the current implementation treats low-order allocations and __GFP_REPEAT
> > allocations as distinct cases, albeit currently with the same result.
> 
> This is a bit beyond the scope of the patch, but doesn't the obvious
> livelock behavior here disturb anyone else?

This was a concer to me as well, certainly. And perhaps an argument to
divorce low-order allocations from __GFP_REPEAT. I guess we hope reclaim
is good enough to eventually make enough progress ... however, if it
doesn't, I think we'll trigger this condition:


	if (likely(did_some_progress)) {
		...
	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
		try with high watermarks
		if still failing the alloc
			if PAGE_ALLOC_COSTLY_ORDER
				fail
		  	else
				OOM
	}

So, I think, the livelock condition is avoided in general as (for
low-order allocations), we can OOM to free memory, so the potentially
infinite loop should eventually finish?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
