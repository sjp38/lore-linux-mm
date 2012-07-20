Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 873336B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:51:28 -0400 (EDT)
Date: Fri, 20 Jul 2012 15:51:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120720145121.GJ9222@suse.de>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720143635.GE12434@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120720143635.GE12434@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 20, 2012 at 04:36:35PM +0200, Michal Hocko wrote:
> And here is my attempt for the fix (Hugh mentioned something similar
> earlier but he suggested using special flags in ptes or VMAs). I still
> owe doc. update and it hasn't been tested with too many configs and I
> could missed some definition updates.
> I also think that changelog could be much better, I will add (steal) the
> full bug description if people think that this way is worth going rather
> than the one suggested by Mel.
> To be honest I am not quite happy how I had to pollute generic mm code with
> something that is specific to a single architecture.
> Mel hammered it with the test case and it survived.

Tested-by: Mel Gorman <mgorman@suse.de>

This approach looks more or less like what I was expecting. I like that
the trick was applied to the page table page instead of using PTE tricks
or by bodging it with a VMA flag like I was thinking so kudos for that. I
also prefer this approach to trying to free the page tables on or near
huge_pmd_unshare()

In general I think this patch would execute better than mine because it is
far less heavy-handed but I share your concern that it changes the core MM
quite a bit for a corner case that only one architecture cares about. I am
completely biased of course, but I still prefer my patch because other than
an API change it keeps the bulk of the madness in arch/x86/mm/hugetlbpage.c
. I am also not concerned with the scalability of how quickly we can setup
page table sharing.

Hugh, I'm afraid you get to choose :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
