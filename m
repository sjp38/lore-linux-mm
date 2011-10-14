Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA876B016C
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 16:59:53 -0400 (EDT)
Received: by pzd13 with SMTP id 13so1643539pzd.6
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 13:59:50 -0700 (PDT)
Date: Fri, 14 Oct 2011 13:59:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] hugepages: Fix race between hugetlbfs umount and
 quota update.
Message-Id: <20111014135948.a45a8ac1.akpm@linux-foundation.org>
In-Reply-To: <20111012044317.GA31436@drongo>
References: <4E4EB603.8090305@cray.com>
	<20110819145109.dcd5dac6.akpm@linux-foundation.org>
	<20111012044317.GA31436@drongo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Andrew Barry <abarry@cray.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Gibson <david@gibson.dropbear.id.au>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Hastings <abh@cray.com>

On Wed, 12 Oct 2011 15:43:17 +1100
Paul Mackerras <paulus@samba.org> wrote:

> In the meantime we have a user-triggerable kernel crash.  As far as I
> can see, if we did what you suggest, we would end up with a situation
> where we could run out of huge pages even though everyone was within
> quota.  Which is arguably better than a kernel crash, but still less
> than ideal.  What do you suggest?

My issue with the patch is that it's rather horrible.  We have a layer
of separation between core hugetlb pages and hugetlbfs.  That layering
has already been mucked up in various places and this patch mucks it up
further, and quite severely.

So I believe we should rethink the patch.  Either a) get the layering
correct by not poking into hugetlbfs internals from within hugetlb core
via one of the usual techniques or b) make a deliberate decision to
just give up on that layering: state that hugetlb and hugetlbfs are now
part of the same subsystem.  Make the necessaary Kconfig changes,
remove ifdefs, move code around, etc.

If we go ahead with the proposed patch-n-run bugfix, the bad code will
be there permanently - nobody will go in and clean this mess up and the
kernel is permanently worsened.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
