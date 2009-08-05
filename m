Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 099866B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 12:20:17 -0400 (EDT)
Date: Wed, 5 Aug 2009 18:19:49 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090805161949.GE23385@random.random>
References: <20090805024058.GA8886@localhost>
 <4A793B92.9040204@redhat.com>
 <20090805160504.GD23385@random.random>
 <9EECC02A4CC333418C00A85D21E89326B651C0BD@azsmsx502.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9EECC02A4CC333418C00A85D21E89326B651C0BD@azsmsx502.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Cc: Avi Kivity <avi@redhat.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 09:12:39AM -0700, Dike, Jeffrey G wrote:
> Sounds like there's some terminology confusion.  A refault is a page
> being discarded due to memory pressure and subsequently being
> faulted back in.  I was counting the number of faults between the
> discard and faulting back in for each affected page.  For a large
> number of predominately stack pages, that number was very small.

Hmm ok, but if it's anonymous pages we're talking about here (I see
KVM in the equation so it has to be!) normally we call that thing
swapin to imply I/O is involved, not refault...  Refault to me sounds
minor fault from swapcache (clean or dirty) and that's about it...

Anon page becomes swapcache, it is unmapped if young bit permits, and
then it's collected from lru eventually, if it is collected I/O will
be generated as swapin during the next page fault.

If it's too much swapin, then yes, it could be that patch that
prevents young bit to keep the anon pages in active list. But fix is
to remove the whole check, not just to enable list_add for anon pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
