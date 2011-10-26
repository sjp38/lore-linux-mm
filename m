Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24EDB6B003B
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 02:51:53 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p9Q6poit012087
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:51:50 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq6.eem.corp.google.com with ESMTP id p9Q6os0c012547
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:51:48 -0700
Received: by pzk36 with SMTP id 36so6402342pzk.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:51:48 -0700 (PDT)
Date: Tue, 25 Oct 2011 23:51:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <CAMbhsRR0z-aJ848gq6ZQATZOgz=EybVsRtaQbjCr42PtCubCzw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1110252347330.20273@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com> <20111025090956.GA10797@suse.de> <alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com> <CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
 <alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com> <alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com> <CAMbhsRS+-jn7d1bTd4F0_RB9860iWjOHLfOkDsqLfWEUbR3TYA@mail.gmail.com> <alpine.DEB.2.00.1110252322220.20273@chino.kir.corp.google.com>
 <CAMbhsRQdrWRLkj7U-u2AZxM11mSUNj5_1K27g58cMBo1Js1Yeg@mail.gmail.com> <alpine.DEB.2.00.1110252327270.20273@chino.kir.corp.google.com> <CAMbhsRR0z-aJ848gq6ZQATZOgz=EybVsRtaQbjCr42PtCubCzw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1542067330-1319611906=:20273"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1542067330-1319611906=:20273
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 25 Oct 2011, Colin Cross wrote:

> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index fef8dc3..59cd4ff 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -1786,6 +1786,13 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
> >>                 return 0;
> >>
> >>         /*
> >> +        * If PM has disabled I/O, OOM is disabled and reclaim is unlikely
> >> +        * to make any progress.  To prevent a livelock, don't retry.
> >> +        */
> >> +       if (!(gfp_allowed_mask & __GFP_FS))
> >> +               return 0;
> >> +
> >> +       /*
> >>          * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
> >>          * means __GFP_NOFAIL, but that may not be true in other
> >>          * implementations.
> >
> > Eek, this is precisely what we don't want and is functionally the same as
> > what you initially proposed except it doesn't care about __GFP_NOFAIL.
> 
> This is checking against gfp_allowed_mask, not gfp_mask.
> 

gfp_allowed_mask is initialized to GFP_BOOT_MASK to start so that __GFP_FS 
is never allowed before the slab allocator is completely initialized, so 
you've now implicitly made all early boot allocations to be __GFP_NORETRY 
even though they may not pass it.
--397155492-1542067330-1319611906=:20273--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
