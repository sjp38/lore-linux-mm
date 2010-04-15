Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B6A7A6B0201
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:13:03 -0400 (EDT)
Message-ID: <4BC6CB30.7030308@kernel.org>
Date: Thu, 15 Apr 2010 17:15:44 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>	 <d5d70d4b57376bc89f178834cf0e424eaa681ab4.1271171877.git.minchan.kim@gmail.com>	 <20100413154820.GC25756@csn.ul.ie> <4BC65237.5080408@kernel.org>	 <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>	 <4BC6BE78.1030503@kernel.org> <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>
In-Reply-To: <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello,

On 04/15/2010 05:00 PM, Minchan Kim wrote:
> Yes. I don't like it.
> With it, someone who does care about API usage uses alloc_pages_exact_node but
> someone who don't have a time or careless uses alloc_pages_node.
> It would make API fragmentation and not good.
> Maybe we can weed out -1 and make new API which is more clear.
> 
> * struct page *alloc_pages_any_node(gfp_t gfp_mask, unsigned int order);
> * struct page *alloc_pages_exact_node(int nid, gfp_mask, unsigned int order);

I'm not an expert on that part of the kernel but isn't
alloc_pages_any_node() identical to alloc_pages_exact_node()?  All
that's necessary to do now is to weed out callers which pass in
negative nid to alloc_pages_node(), right?  If so, why not just do a
clean sweep of alloc_pages_node() users and update them so that they
don't call in w/ -1 nid and add WARN_ON_ONCE() in alloc_pages_node()?
Is there any reason to keep both variants going forward?  If not,
introducing new API just to weed out invalid usages seems like an
overkill.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
