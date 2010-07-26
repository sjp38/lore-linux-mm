Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 315656B02A4
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 06:40:26 -0400 (EDT)
Date: Mon, 26 Jul 2010 12:40:20 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Fix off-by-one bug in mbind() syscall implementation
Message-ID: <20100726104020.GB17756@basil.fritz.box>
References: <1280136498-28219-1-git-send-email-andre.przywara@amd.com>
 <20100726094931.GA17756@basil.fritz.box>
 <4C4D620E.9010008@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C4D620E.9010008@amd.com>
Sender: owner-linux-mm@kvack.org
To: Andre Przywara <andre.przywara@amd.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 12:23:10PM +0200, Andre Przywara wrote:
> Andi Kleen wrote:
> >On Mon, Jul 26, 2010 at 11:28:18AM +0200, Andre Przywara wrote:
> >>When the mbind() syscall implementation processes the node mask
> >>provided by the user, the last node is accidentally masked out.
> >>This is present since the dawn of time (aka Before Git), I guess
> >>nobody realized that because libnuma as the most prominent user of
> >>mbind() uses large masks (sizeof(long)) and nobody cared if the
> >>64th node is not handled properly. But if the user application
> >>defers the masking to the kernel and provides the number of valid bits
> >>in maxnodes, there is always the last node missing.
> >>However this also affect the special case with maxnodes=0, the manpage
> >>reads that mbind(ptr, len, MPOL_DEFAULT, &some_long, 0, 0); should
> >>reset the policy to the default one, but in fact it returns EINVAL.
> >>This patch just removes the decrease-by-one statement, I hope that
> >>there is no workaround code in the wild that relies on the bogus
> >>behavior.
> >
> >Actually libnuma and likely most existing users rely on it.
> If grep didn't fool me, then the only users in libnuma aware of that
> bug are the test implementations in numactl-2.0.3/test, namely
> /test/tshm.c (NUMA_MAX_NODES+1) and test/mbind_mig_pages.c
> (old_nodes->size + 1).

At least libnuma 1 (which is the libnuma most distributions use today)
explicitely knows about it and will break if you change it.

> 
> Has this bug been known before?

Yes (and you can argue whether it's a problem or not)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
