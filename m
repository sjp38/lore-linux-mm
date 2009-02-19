Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C16BF6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 09:28:04 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0662A82C5FF
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 09:32:10 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eGwHowGyjX58 for <linux-mm@kvack.org>;
	Thu, 19 Feb 2009 09:32:09 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BBFEB82C601
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 09:32:02 -0500 (EST)
Date: Thu, 19 Feb 2009 09:19:57 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <2f11576a0902190549p2d3c90e2md16726cbe2f5d019@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0902190915460.32273@qirst.com>
References: <20090218093858.8990.A69D9226@jp.fujitsu.com>  <1234944569.24030.20.camel@penberg-laptop>  <20090219085229.954A.A69D9226@jp.fujitsu.com>  <1235034967.29813.10.camel@penberg-laptop>  <2f11576a0902190451w294aa2fan29b61fa3619f459b@mail.gmail.com>
 <1235049334.29813.18.camel@penberg-laptop> <2f11576a0902190549p2d3c90e2md16726cbe2f5d019@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

What could be changed in the patch is to set SLUB_MAX_SIZE depending on
the page size of the underlying architecture.

#define SLUB_MAX_SIZE MAX(PAGE_SIZE, 8192)

So on 4k architectures SLUB_MAX_SIZE is set to 8192 and on 16k or 64k
arches its set to PAGE_SIZE.

And then define

#define SLUB_MAX_KMALLOC_ORDER get_order(SLUB_MAX_SIZE)

which will be 1 on 4k arches and 0 on higher sized arches.

Then also the kmalloc array would need to be dimensioned using
SLUB_MAX_KMALLOC_ORDER.


The definition of SLUB_NAX_KMALLOC_ORDER could be a bit challenging for
the C compiler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
