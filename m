Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DF03390013A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 18:13:47 -0400 (EDT)
Date: Wed, 24 Aug 2011 00:13:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3 of 3] thp: mremap support and TLB optimization
Message-ID: <20110823221321.GD23870@redhat.com>
References: <patchbomb.1312649882@localhost>
 <10a29e95223e52e49a61.1312649885@localhost>
 <20110823141445.35864dc8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823141445.35864dc8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Hi Andrew,

On Tue, Aug 23, 2011 at 02:14:45PM -0700, Andrew Morton wrote:
> > +	if ((old_addr & ~HPAGE_PMD_MASK) ||
> > +	    (new_addr & ~HPAGE_PMD_MASK) ||
> > +	    (old_addr + HPAGE_PMD_SIZE) > old_end ||
> 
> Can (old_addr + HPAGE_PMD_SIZE) wrap past zero?

Good question. old_addr is hpage aligned so to overflow it'd need to
be exactly at address 0-HPAGE_PMD_SIZE. Can any userland map an
address there? I doubt and surely not x86* or sparc (currently THP is
only enabled on x86 anyway so answer is it can't wrap past zero). But
probably we should add a wrap check for other archs in the future
unless we have a real guarantee from all archs to avoid the check. I
only can guarantee about x86*.

> -	if (!pmd_none(*new_pmd)) {
> -		WARN_ON(1);
> +	if (!WARN_ON(pmd_none(*new_pmd))) {

WARN_ON(!pmd_none

Thanks for the cleanups!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
