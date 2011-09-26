Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 34F6C9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 09:01:58 -0400 (EDT)
Date: Mon, 26 Sep 2011 14:00:14 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 6/8] drivers: add Contiguous Memory Allocator
Message-ID: <20110926130014.GG22455@n2100.arm.linux.org.uk>
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <1309851710-3828-7-git-send-email-m.szyprowski@samsung.com> <20110705113345.GA8286@n2100.arm.linux.org.uk> <201107051427.44899.arnd@arndb.de> <1312393430.2855.51.camel@mulgrave>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312393430.2855.51.camel@mulgrave>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Jesse Barker <jesse.barker@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, ksummit-2011-discuss@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Wed, Aug 03, 2011 at 12:43:50PM -0500, James Bottomley wrote:
> I assume from the above that ARM has a hardware page walker?

Correct, and speculative prefetch (which isn't prevented by not having
TLB entries), so you can't keep entries out of the TLB.  If it's in
the page tables it can end up in the TLB.

The problem is that we could end up with conflicting attributes available
to the hardware for the same physical page, and it is _completely_
undefined how hardware behaves with that (except that it does not halt -
and there's no exception path for the condition because there's no
detection of the problem case.)

So, if you had one mapping which was fully cacheable and another mapping
which wasn't, you can flush the TLB all you like - it could be possible
that you still up with an access through the non-cacheable mapping being
cached (either hitting speculatively prefetched cache lines via the
cacheable mapping, or the cacheable attributes being applied to the
non-cacheable mapping - or conversely uncacheable attributes applied to
the cacheable mapping.)

Essentially, the condition is labelled 'unpredictable' in the TRMs,
which basically means that not even observed behaviour can be relied
upon, because there may be cases where the observed behaviour fails.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
