Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0D3DF6B004D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 12:05:12 -0400 (EDT)
Date: Wed, 5 Aug 2009 18:05:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090805160504.GD23385@random.random>
References: <20090805024058.GA8886@localhost>
 <4A793B92.9040204@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A793B92.9040204@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 10:58:10AM +0300, Avi Kivity wrote:
> How do you distinguish between kvm pages and non-kvm anonymous pages?  
> More importantly, why should you?

It can't distinguish. Besides the pages being refaulted (as minor
faults) implies they weren't collected yet. So the fact they are
allowed to stay on active list or not can't matter or alter the
refaulting issue.

> Jeff, do you see the refaults on Nehalem systems?  If so, that's likely 
> due to the lack of an accessed bit on EPT pagetables.  It would be 
> interesting to compare with Barcelona  (which does).

It seems it wasn't using EPT.

Refaulting as minor faults, still possible w/ or w/o EPT and young
bit... when young bit is found not set, we just unmap the spte/pte and
we leave the page in lru for a while until it is collected. So it can
be refaulted even with young bit perfectly functional in spte and pte.

But the _whole_ point of NPT young bit (shame on EPT) and in pte, is
to try not to unmap the pagetables to get the aging information. So
there's a one more pass with young bit functional compared to without
young bit functional, but it doesn't mean that when young bit is clear
at second pass we immediately free the page, just we go into the
"refaulting lru cache waiting to be collected". And if the page isn't
actually collected it doesn't matter if it's in active or inactive
list, so patch can't matter if it's ""minor"" refaults what we're
talking about here :).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
