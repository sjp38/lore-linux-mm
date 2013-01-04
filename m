Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 45D2A6B005D
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 21:51:07 -0500 (EST)
Date: Fri, 4 Jan 2013 11:51:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/8] Don't allow volatile attribute on THP and KSM
Message-ID: <20130104025105.GB2617@blaptop>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
 <1357187286-18759-3-git-send-email-minchan@kernel.org>
 <50E5B173.7070807@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50E5B173.7070807@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Jan 03, 2013 at 08:27:31AM -0800, Dave Hansen wrote:
> On 01/02/2013 08:28 PM, Minchan Kim wrote:
> > VOLATILE imply the the pages in the range isn't working set any more
> > so it's pointless that make them to THP/KSM.
> 
> One of the points of this implementation is that it be able to preserve
> memory contents when there is no pressure.  If those contents happen to
> contain a THP/KSM page, and there's no pressure, it seems like the right
> thing to do is to leave that memory in place.

Indeed. I should have written more cleary,

Current implementation is following as

1. madvised-THP/KSM(1, 10) -> mvolatile(1, 10) -> fail
2. mvolatile(1, 10) -> madvised-THP/KSM(1, 10) -> fail
3. always-THP -> mvolatile -> success -> if memory pressure happens
   -> split_huge_page -> discard.

I think 2,3 makes sense to me but we need to fix 1 in further patches.

> 
> It might be a fair thing to do this in order to keep the implementation
> more sane at the moment.  But, we should make sure there's some good
> text on that in the changelog.

Absolutely, Thanks for pointing out, Dave.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
