Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 001226B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:14:50 -0400 (EDT)
Date: Fri, 9 Oct 2009 21:14:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
Message-ID: <20091009131436.GA23774@localhost>
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1255090830.8802.60.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1255090830.8802.60.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 09, 2009 at 02:20:30PM +0200, Peter Zijlstra wrote:
> On Fri, 2009-10-09 at 13:19 +0200, Ehrhardt Christian wrote:
> > From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> > 
> > On one hand the define VM_MAX_READAHEAD in include/linux/mm.h is just a default
> > and can be configured per block device queue.
> > On the other hand a lot of admins do not use it, therefore it is reasonable to
> > set a wise default.
> > 
> > This path allows to configure the value via Kconfig mechanisms and therefore
> > allow the assignment of different defaults dependent on other Kconfig symbols.
> > 
> > Using this, the patch increases the default max readahead for s390 improving
> > sequential throughput in a lot of scenarios with almost no drawbacks (only
> > theoretical workloads with a lot concurrent sequential read patterns on a very
> > low memory system suffer due to page cache trashing as expected).
> 
> Why can't this be solved in userspace?
> 
> Also, can't we simply raise this number if appropriate? Wu did some

Agreed, and Ehrhardt's 512KB readahead size looks like a good default :)

> read-ahead trashing detection bits a long while back which should scale
> the read-ahead window back when we're low on memory, not sure that ever
> made it in, but that sounds like a better option than having different
> magic numbers for each platform.

The current kernel could roughly estimate the thrashing safe size (the
context readahead). However that's not enough. Context readahead is
normally active only for interleaved reads. The normal behavior is to
scale up readahead size aggressively. For better support for embedded
systems, we may need a flag/mode which tells: "we recently experienced
thrashing, so estimate and stick to the thrashing safe size instead of
keep scaling up readahead size and thus risk thrashing again".

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
