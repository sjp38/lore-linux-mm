Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D8C36B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 22:13:32 -0400 (EDT)
Message-ID: <4A4AC636.4010307@redhat.com>
Date: Tue, 30 Jun 2009 22:13:10 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Found the commit that causes the OOMs
References: <1246291007.663.630.camel@macbook.infradead.org> <20090630140512.GA16923@localhost> <20090701094446.85C8.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090701094446.85C8.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@gmail.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> if my guess is correct, we need to implement #-of-reclaim-process throttling
> mechanism.

There are probably some other things that want throttling,
too.

For example, the number of pages currently under IO can
be as large as the entire file and anon inactive lists,
which can cause page reclaim to fail because none of the
pages are reclaimable yet.

This is probably not a big issue for the page cache,
since the readahead window will collapse before we hit
this problem.

However, we may want to take measures to ensure that
the total number of pages in swap readahead do not
take up the entire inactive anon list - maybe we should
limit it to half that amount, to stay on the safe side?

I'll whip up a patch for this tomorrow.

That should get rid of the OOMs that have been observed
with the swap readahead patches by Johannes.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
