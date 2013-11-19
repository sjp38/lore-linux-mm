Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id BF4E26B0036
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 17:53:12 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so4487785pab.34
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 14:53:12 -0800 (PST)
Received: from psmtp.com ([74.125.245.204])
        by mx.google.com with SMTP id bf6si12609950pad.309.2013.11.19.14.53.10
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 14:53:11 -0800 (PST)
Date: Tue, 19 Nov 2013 23:52:52 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] mm: hugetlbfs: fix hugetlbfs optimization v2
Message-ID: <20131119225252.GD10493@redhat.com>
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
 <528A56A7.3020301@oracle.com>
 <528BC9AA.5020300@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <528BC9AA.5020300@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

5~Hi Khalid,

On Tue, Nov 19, 2013 at 01:27:22PM -0700, Khalid Aziz wrote:
> > Block size        3.12         3.12+patch 1      3.12+patch 1,2,3
> > ----------        ----         ------------      ----------------
> > 1M                8467           8114              7648
> > 64K               4049           4043              4175
> >
> > Performance numbers with 64K reads look good but there is further
> > deterioration with 1M reads.
> >
> > --
> > Khalid
> 
> Hi Andrea,
> 
> I found that a background task running on my test server had influenced 
> the performance numbers for 1M reads. I cleaned that problem up and 
> re-ran the test. I am seeing 8456 MB/sec with all three patches applied, 
> so 1M number is looking good as well.

Good news thanks!

1/3 should go in -mm I think as it fixes many problems.

The rest can be applied with less priority and is not as urgent.

I've also tried to optimize it further in the meantime as I thought it
wasn't fully ok yet. So I could send another patchset. I haven't
changed 1/3 and I don't plan changing it. And I kept 3/3 at the end as
it's the one with a bit more of complexity than the rest.

I basically removed a few more atomic ops for each put_page/get_page
for both hugetlbfs and slab, and the important thing is they're zero
cost changes for the non-hugetlbfs/slab fast paths so they're probably
worth it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
