Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2DAF86B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 04:30:32 -0400 (EDT)
Message-ID: <4BCED815.90704@kernel.org>
Date: Wed, 21 Apr 2010 12:48:53 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
References: <4BC6CB30.7030308@kernel.org> <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com> <4BC6E581.1000604@kernel.org> <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com> <4BC6FBC8.9090204@kernel.org> <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com> <alpine.DEB.2.00.1004161105120.7710@router.home> <1271606079.2100.159.camel@barrios-desktop> <alpine.DEB.2.00.1004191235160.9855@router.home> <4BCCD8BD.1020307@kernel.org> <20100420150522.GG19264@csn.ul.ie>
In-Reply-To: <20100420150522.GG19264@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On 04/20/2010 05:05 PM, Mel Gorman wrote:
> alloc_pages_exact_node() avoids a branch in a hot path that is checking for
> something the caller already knows. That's the reason it exists.

Yeah sure but Minchan is trying to tidy up the API by converting
alloc_pages_node() users to use alloc_pages_exact_node(), at which
point, the distinction becomes pretty useless.  Wouldn't just making
alloc_pages_node() do what alloc_pages_exact_node() does now and
converting all its users be simpler?  IIRC, the currently planned
transformation looks like the following.

 alloc_pages()			-> alloc_pages_any_node()
 alloc_pages_node()		-> basically gonna be obsoleted by _exact_node
 alloc_pages_exact_node()	-> gonna be used by most NUMA aware allocs

So, let's just make sure no one calls alloc_pages_node() w/ -1 nid,
kill alloc_pages_node() and rename alloc_pages_exact_node() to
alloc_pages_node().

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
