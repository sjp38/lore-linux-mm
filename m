Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 526826B004F
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 03:10:33 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p9Q7AUYn013092
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 00:10:30 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by hpaq2.eem.corp.google.com with ESMTP id p9Q7917Z003873
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 00:10:28 -0700
Received: by pzk1 with SMTP id 1so5247163pzk.9
        for <linux-mm@kvack.org>; Wed, 26 Oct 2011 00:10:28 -0700 (PDT)
Date: Wed, 26 Oct 2011 00:10:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <CAMbhsRScgfokDOiT7c9RbmqC7E_ZXrwLEYXE7JZWFGoePjAXvg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1110260006470.23227@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com> <20111025090956.GA10797@suse.de> <alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com> <CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
 <alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com> <alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com> <CAMbhsRS+-jn7d1bTd4F0_RB9860iWjOHLfOkDsqLfWEUbR3TYA@mail.gmail.com> <alpine.DEB.2.00.1110252322220.20273@chino.kir.corp.google.com>
 <CAMbhsRQdrWRLkj7U-u2AZxM11mSUNj5_1K27g58cMBo1Js1Yeg@mail.gmail.com> <alpine.DEB.2.00.1110252327270.20273@chino.kir.corp.google.com> <CAMbhsRR0z-aJ848gq6ZQATZOgz=EybVsRtaQbjCr42PtCubCzw@mail.gmail.com> <alpine.DEB.2.00.1110252347330.20273@chino.kir.corp.google.com>
 <CAMbhsRScgfokDOiT7c9RbmqC7E_ZXrwLEYXE7JZWFGoePjAXvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 25 Oct 2011, Colin Cross wrote:

> > gfp_allowed_mask is initialized to GFP_BOOT_MASK to start so that __GFP_FS
> > is never allowed before the slab allocator is completely initialized, so
> > you've now implicitly made all early boot allocations to be __GFP_NORETRY
> > even though they may not pass it.
> 
> Only before interrupts are enabled, and then isn't it vulnerable to
> the same livelock?  Interrupts are off, single cpu, kswapd can't run.
> If an allocation ever failed, which seems unlikely, why would retrying
> help?
> 

If you want to claim gfp_allowed_mask as a pm-only entity, then I see no 
problem with this approach.  However, if gfp_allowed_mask would be allowed 
to temporarily change after init for another purpose then it would make 
sense to retry because another allocation with __GFP_FS on another cpu or 
kswapd could start making progress could allow for future memory freeing.

The suggestion to add a hook directly into a pm-interface was so that we 
could isolate it only to suspend and, to me, is the most maintainable 
solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
