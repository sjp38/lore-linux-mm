Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0176B0023
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:39:37 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so1150519vcb.14
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 12:39:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111025112300.GB10797@suse.de>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
	<20111025090956.GA10797@suse.de>
	<CAMbhsRR07Gpv-nEAvq8OQmLxkMyL5cASpq1vqQ8qN5ctwnamsQ@mail.gmail.com>
	<20111025112300.GB10797@suse.de>
Date: Tue, 25 Oct 2011 22:39:34 +0300
Message-ID: <CAOJsxLH54aUjVE3b7queQMOJP1kb+bxtUTAUA=T=N378M5_hJA@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

Hi Mel,

On Tue, Oct 25, 2011 at 2:23 PM, Mel Gorman <mgorman@suse.de> wrote:
> I see what you mean with GFP_NOIO but there is an important difference
> between GFP_NOIO and suspend. =A0A GFP_NOIO low-order allocation currentl=
y
> implies __GFP_NOFAIL as commented on in should_alloc_retry(). If no progr=
ess
> is made, we call wait_iff_congested() and sleep for a bit. As the system
> is running, kswapd and other process activity will proceed and eventually
> reclaim enough pages for the GFP_NOIO allocation to succeed. In a running
> system, GFP_NOIO can stall for a period of time but your patch will cause
> the allocation to fail. While I expect callers return ENOMEM or handle
> the situation properly with a wait-and-retry loop, there will be
> operations that fail that used to succeed. This is why I'd prefer it was
> a suspend-specific fix unless we know there is a case where a machine
> livelocks due to a GFP_NOIO allocation looping forever and even then I'd
> wonder why kswapd was not helping.

I'm not that happy about your patch because it's going to the
direction where the page allocator is special-casing for suspension.
If you don't think it's a good idea to fix it for the general case
(i.e. Colin's patch), why don't we fix it up in a way that suspension
code passes sane GFP flags?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
