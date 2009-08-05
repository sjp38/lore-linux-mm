Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E0C016B005D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 13:53:43 -0400 (EDT)
Message-ID: <4A79C70C.6010200@redhat.com>
Date: Wed, 05 Aug 2009 13:53:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost>
In-Reply-To: <20090805024058.GA8886@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:

> The refaults can be drastically reduced by the following patch, which
> respects the referenced bit of all anonymous pages (including the KVM
> pages).

The big question is, which referenced bit?

All anonymous pages get the referenced bit set when they are
initially created.  Acting on that bit is pretty useless, since
it does not add any information at all.

> However it risks reintroducing the problem addressed by commit 7e9cd4842
> (fix reclaim scalability problem by ignoring the referenced bit,
> mainly the pte young bit). I wonder if there are better solutions?

Reintroducing that problem is disastrous for large systems
running eg. JVMs or certain scientific computing workloads.

When you have a 256GB system that is low on memory, you need
to be able to find a page to swap out soon.  If all 64 million
pages in your system are "recently referenced", you run into
BIG trouble.

I do not believe we can afford to reintroduce that problem.

Also, the inactive list (where references to anonymous pages
_do_ count) is pretty big.  Is it not big enough in Jeff's
test case?

Jeff, what kind of workloads are you running in the guests?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
