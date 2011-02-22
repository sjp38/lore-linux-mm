Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E7FC58D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 11:20:40 -0500 (EST)
Date: Tue, 22 Feb 2011 17:20:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/8] Preserve local node for KSM copies
Message-ID: <20110222162011.GD13092@random.random>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
 <1298315270-10434-4-git-send-email-andi@firstfloor.org>
 <alpine.DEB.2.00.1102220945210.16060@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1102220945210.16060@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>, arcange@redhat.com

On Tue, Feb 22, 2011 at 09:47:26AM -0600, Christoph Lameter wrote:
> On Mon, 21 Feb 2011, Andi Kleen wrote:
> 
> > Add a alloc_page_vma_node that allows passing the "local" node in.
> > Use it in ksm to allocate copy pages on the same node as
> > the original as possible.
> 
> Why would that be useful? The shared page could be on a node that is not
> near the process that maps the page. Would it not be better to allocate on
> the node that is local to the process that maps the page?

This is what I was trying to understand. To me it looks like this is
making things worse. Following the "vma" advice like current code
does, sounds much better than following the previous page that may
have been allocated in the wrong node if the allocation from the right
node couldn't be satisfied at the time the page was first allocated
(we should still try to allocate from the right node following the vma
hint).

In the KSM case this badness is exacerbated by the fact a ksm page is
guarnteed to be randomly-numa allocated, because it's shared across
all processes regardless of their vma settings. KSM is not NUMA aware,
so following the location of the KSM "page" seems a regression
compared to the current code that at least follows the vma when
bringing up a page during swapin.

I've an hard time generally to see how following "page" (that is
especially wrong with KSM because of the very sharing effect) is
better than following "vma".

KSM may become NUMA aware if we replicate the stable tree in each
node, but we're not even close to that, so I've an hard time how
"page" hinting instead of "vma" hinting can do any good, especially in
KSM case. But I've to think more about this.. but if you've
suggestions you're welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
