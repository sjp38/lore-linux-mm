Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 692A46B005A
	for <linux-mm@kvack.org>; Fri,  1 May 2009 10:09:28 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3FAC482C486
	for <linux-mm@kvack.org>; Fri,  1 May 2009 10:21:00 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ypad9vsdZYaj for <linux-mm@kvack.org>;
	Fri,  1 May 2009 10:21:00 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0B76182C541
	for <linux-mm@kvack.org>; Fri,  1 May 2009 10:20:54 -0400 (EDT)
Date: Fri, 1 May 2009 09:59:35 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
In-Reply-To: <20090501140015.GA27831@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0905010958090.18324@qirst.com>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils> <20090430132544.GB21997@csn.ul.ie> <Pine.LNX.4.64.0905011202530.8513@blonde.anvils> <20090501140015.GA27831@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 May 2009, Mel Gorman wrote:

> > Andrew noticed another oddity: that if it goes the hashdist __vmalloc()
> > way, it won't be limited by MAX_ORDER.  Makes one wonder whether it
> > ought to fall back to __vmalloc() if the alloc_pages_exact() fails.
>
> I don't believe so. __vmalloc() is only used when hashdist= is used or on IA-64
> (according to the documentation). It is used in the case that the caller is
> willing to deal with the vmalloc() overhead (e.g. using base page PTEs) in
> exchange for the pages being interleaved on different nodes so that access
> to the hash table has average performance[*]
>
> If we automatically fell back to vmalloc(), I bet 2c we'd eventually get
> a mysterious performance regression report for a workload that depended on
> the hash tables performance but that there was enough memory for the hash
> table to be allocated with vmalloc() instead of alloc_pages_exact().

Can we fall back to a huge page mapped vmalloc? Like what the vmemmap code
does? Then we also would not have MAX_ORDER limitations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
