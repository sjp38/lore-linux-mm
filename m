Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D3F786B002D
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 21:46:19 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p9Q1kD1U010114
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 18:46:13 -0700
Received: from ggnk4 (ggnk4.prod.google.com [10.218.97.68])
	by hpaq13.eem.corp.google.com with ESMTP id p9Q1kBoT016532
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 18:46:12 -0700
Received: by ggnk4 with SMTP id k4so1711150ggn.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 18:46:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
	<20111025090956.GA10797@suse.de>
	<alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com>
Date: Tue, 25 Oct 2011 18:46:10 -0700
Message-ID: <CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 3:18 PM, David Rientjes <rientjes@google.com> wrote=
:
> On Tue, 25 Oct 2011, Mel Gorman wrote:
>
>> That said, it will be difficult to remember why checking __GFP_NOFAIL in
>> this case is necessary and someone might "optimitise" it away later. It
>> would be preferable if it was self-documenting. Maybe something like
>> this? (This is totally untested)
>>
>
> __GFP_NOFAIL _should_ be optimized away in this case because all he's
> passing is __GFP_WAIT | __GFP_NOFAIL. =A0That doesn't make any sense unle=
ss
> all you want to do is livelock.

__GFP_NOFAIL is not set in the case that I care about.  If my change
is hit, no forward progress has been made, so I agree it should not
honor __GFP_NOFAIL.

> __GFP_NOFAIL doesn't mean the page allocator would infinitely loop in all
> conditions. =A0That's why GFP_ATOMIC | __GFP_NOFAIL actually fails, and I
> would argue that __GFP_WAIT | __GFP_NOFAIL should fail as well since it's
> the exact same condition except doesn't have access to the extra memory
> reserves.
>
> Suspend needs to either set __GFP_NORETRY to avoid the livelock if it's
> going to disable all means of memory reclaiming or freeing in the page
> allocator. =A0Or, better yet, just make it GFP_NOWAIT.
>

It would be nice to give compaction and the slab shrinker a chance to
recover a few pages, both methods will work fine in suspend.
GFP_NOWAIT will prevent them from ever running, and __GFP_NORETRY will
give up even if they are making progress but haven't recovered enough
pages.

Converting suspend to GFP_NOWAIT would simply be ~GFP_KERNEL instead
of ~GFP_IOFS in pm_restrict_gfp_mask().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
