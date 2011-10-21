Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1C8FF6B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 18:50:17 -0400 (EDT)
Date: Sat, 22 Oct 2011 00:50:08 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Message-ID: <20111021225008.GK608@redhat.com>
References: <201110122012.33767.pluto@agmk.net>
 <alpine.LSU.2.00.1110131547550.1346@sister.anvils>
 <alpine.LSU.2.00.1110131629530.1410@sister.anvils>
 <20111016235442.GB25266@redhat.com>
 <CAPQyPG69WePwar+k0nhwfdW7vv7FjqJBYwKfYm7n5qaPwS-WgQ@mail.gmail.com>
 <20111021155632.GD4082@suse.de>
 <20111021174120.GJ608@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111021174120.GJ608@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nai Xia <nai.xia@gmail.com>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Oct 21, 2011 at 07:41:20PM +0200, Andrea Arcangeli wrote:
> We have two options:
> 
> 1) we remove the vma_merge call from copy_vma and we do the vma_merge
> manually after mremap succeed (so then we're as safe as fork is and we
> relay on the ordering). No locks but we'll just do 1 more allocation
> for one addition temporary vma that will be removed after mremap
> completed.
> 
> 2) Hugh's original fix.

3) put the src vma at the tail if vma_merge succeeds and the src vma
and dst vma aren't the same

I tried to implement this but I'm still wondering about the safety of
this with concurrent processes all calling mremap at the same time on
the same anon_vma same_anon_vma list, the reasoning I think it may be
safe is in the comment. I run a few mremap with my benchmark where the
THP aware mremap in -mm gets a x10 boost and moves 5G and it didn't
crash but that's about it and not conclusive, if you review please
comment...

I've to pack luggage and prepare to fly to KS tomorrow so I may not be
responsive in the next few days.

===
