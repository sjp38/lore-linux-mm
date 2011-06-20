Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8152A6B0083
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:59:38 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5KGZCFX007452
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:35:12 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5KGxY6Y164200
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:59:34 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5KGxWv2016432
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:59:33 -0400
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1308587683-2555-2-git-send-email-amwang@redhat.com>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
	 <1308587683-2555-2-git-send-email-amwang@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jun 2011 09:59:23 -0700
Message-ID: <1308589163.11430.245.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 2011-06-21 at 00:34 +0800, Amerigo Wang wrote:
> +config TRANSPARENT_HUGEPAGE_THRESHOLD
> +       depends on TRANSPARENT_HUGEPAGE
> +       int "The minimal threshold of enabling Transparent Hugepage"
> +       range 512 8192
> +       default "512"
> +       help
> +         The threshold of enabling Transparent Huagepage automatically,
> +         in Mbytes, below this value, Transparent Hugepage will be disabled
> +         by default during boot. 

It makes some sense to me that there would _be_ a threshold, simply
because you need some space to defragment things.  But, I can't imagine
any kind of user having *ANY* kind of idea what to set this to.  Could
we add some text to this?  Maybe:

        Transparent hugepages are created by moving other pages out of
        the way to create large, contiguous swaths of free memory.
        However, some memory on a system can not be easily moved.  It is
        likely on small systems that this unmovable memory will occupy a
        large portion of total memory, which makes even attempting to
        create transparent hugepages very expensive.
        
        If you are unsure, set this to the smallest possible value.
        
        To override this at boot, use the $FOO boot command-line option.

I'm also not sure putting a ceiling on this makes a lot of sense.
What's the logic behind that?  I know it would be a mess to expose it to
users, but shouldn't this be a per-zone limit, logically?  Seems like a
8GB system would have similar issues to a two-numa-node 16GB system.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
