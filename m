Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 851E09000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 05:17:53 -0400 (EDT)
Date: Thu, 7 Jul 2011 10:17:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 01/14] mm: Serialize access to min_free_kbytes
Message-ID: <20110707091744.GF15285@suse.de>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
 <1308575540-25219-2-git-send-email-mgorman@suse.de>
 <20110706164447.d571051a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110706164447.d571051a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, Jul 06, 2011 at 04:44:47PM -0700, Andrew Morton wrote:
> On Mon, 20 Jun 2011 14:12:07 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > There is a race between the min_free_kbytes sysctl, memory hotplug
> > and transparent hugepage support enablement.  Memory hotplug uses a
> > zonelists_mutex to avoid a race when building zonelists. Reuse it to
> > serialise watermark updates.
> 
> This patch appears to be a standalone fix, unrelated to the overall
> patch series?
> 

Yes. In the original series this would have been a more serious problem
as min_free_kbytes was potentially adjusted more frequently.

> How does one trigger the race and what happens when it hits, btw?

One could trigger the trace by having multiple processes on different
CPUs write to min_free_kbytes. One could add memory hotplug events
to that for extra fun but it is unnecessary to trigger the race.

The consequences are that the value for min_free_kbytes and the zone
watermarks get out of sync. Whether the zone watermarks will be too
high or too low would depend on the timing. For the most part, the
consequence will simply be that the min free level for some zones will
be wrong. A more serious consequence is that totalreserve_pages could
get out of sync and strict no memory overcommit could fail a mmap when
it should have succeeded for the value of min_free_kbytes or suspend
fail because it did not preallocate enough pages.

It's not exactly earth shattering.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
