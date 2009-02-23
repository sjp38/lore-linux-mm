Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A31A26B00BF
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:42:26 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 04/20] Convert gfp_zone() to use a table of precalculated values
Date: Tue, 24 Feb 2009 02:41:47 +1100
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0902231003090.7298@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0902231003090.7298@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902240241.48575.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 February 2009 02:23:52 Christoph Lameter wrote:
> On Sun, 22 Feb 2009, Mel Gorman wrote:
> > Every page allocation uses gfp_zone() to calcuate what the highest zone
> > allowed by a combination of GFP flags is. This is a large number of
> > branches to have in a fast path. This patch replaces the branches with a
> > lookup table that is calculated at boot-time and stored in the
> > read-mostly section so it can be shared. This requires __GFP_MOVABLE to
> > be redefined but it's debatable as to whether it should be considered a
> > zone modifier or not.
>
> Are you sure that this is a benefit? Jumps are forward and pretty short
> and the compiler is optimizing a branch away in the current code.

Pretty easy to mispredict there, though, especially as you can tend
to get allocations interleaved between kernel and movable (or simply
if the branch predictor is cold there are a lot of branches on x86-64).

I would be interested to know if there is a measured improvement. It
adds an extra dcache line to the footprint, but OTOH the instructions
you quote is more than one icache line, and presumably Mel's code will
be a lot shorter.

>
> 0xffffffff8027bde8 <try_to_free_pages+95>:      mov    %esi,-0x58(%rbp)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
