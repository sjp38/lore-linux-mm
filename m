Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 207066B004D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 23:51:39 -0400 (EDT)
Date: Wed, 15 Jul 2009 20:51:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] throttle direct reclaim when too many pages are
 isolated already
Message-Id: <20090715205109.5f86e416.akpm@linux-foundation.org>
In-Reply-To: <4A5EA1A4.1080502@redhat.com>
References: <20090715223854.7548740a@bree.surriel.com>
	<20090715194820.237a4d77.akpm@linux-foundation.org>
	<4A5E9A33.3030704@redhat.com>
	<20090715202114.789d36f7.akpm@linux-foundation.org>
	<4A5E9E4E.5000308@redhat.com>
	<20090715203854.336de2d5.akpm@linux-foundation.org>
	<4A5EA1A4.1080502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009 23:42:28 -0400 Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Wed, 15 Jul 2009 23:28:14 -0400 Rik van Riel <riel@redhat.com> wrote:
> 
> >> If we are stuck at this point in the page reclaim code,
> >> it is because too many other tasks are reclaiming pages.
> >>
> >> That makes it fairly safe to just return SWAP_CLUSTER_MAX
> >> here and hope that __alloc_pages() can get a page.
> >>
> >> After all, if __alloc_pages() thinks it made progress,
> >> but still cannot make the allocation, it will call the
> >> pageout code again.
> > 
> > Which will immediately return because the caller still has
> > fatal_signal_pending()?
> 
> Other processes are in the middle of freeing pages at
> this point, so we should succeed in __alloc_pages()
> fairly quickly (and then die and free all our memory).

What if it's a uniprocessor machine and all those processes are
scheduled out?  We sit there chewing 100% CPU and not doing anything
afaict.

Even if it _is_ SMP, we could still chew decent-sized blips of CPU time
rattling around waiting for something to happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
