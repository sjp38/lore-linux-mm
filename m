Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 525C76B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 19:53:18 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so5222891pdj.31
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 16:53:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tb5si8704400pac.191.2014.01.10.16.53.16
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 16:53:17 -0800 (PST)
Date: Fri, 10 Jan 2014 16:53:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation
 apis
Message-Id: <20140110165314.80adf6b53c310693529c3c80@linux-foundation.org>
In-Reply-To: <52A0B42C.5080405@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
	<1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
	<20131203232445.GX8277@htj.dyndns.org>
	<529F5047.50309@ti.com>
	<20131204160730.GQ3158@htj.dyndns.org>
	<529F5C55.1020707@ti.com>
	<52A07BBE.7060507@ti.com>
	<20131205165936.GB24062@mtj.dyndns.org>
	<52A0B42C.5080405@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Tejun Heo <tj@kernel.org>, Grygorii Strashko <grygorii.strashko@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>

On Thu, 5 Dec 2013 12:13:16 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:

> On Thursday 05 December 2013 11:59 AM, Tejun Heo wrote:
> > Hello,
> > 
> > On Thu, Dec 05, 2013 at 03:12:30PM +0200, Grygorii Strashko wrote:
> >> I'll try to provide more technical details here.
> >> As Santosh mentioned in previous e-mails, it's not easy to simply
> >> get rid of using MAX_NUMNODES:
> >> 1) we introduce new interface memblock_allocX 
> >> 2) our interface uses memblock APIs __next_free_mem_range_rev()
> >>    and __next_free_mem_range()
> >> 3) __next_free_mem_range_rev() and __next_free_mem_range() use MAX_NUMNODES
> >> 4) _next_free_mem_range_rev() and __next_free_mem_range() are used standalone,
> >>    outside of our interface as part of *for_each_free_mem_range* or for_each_mem_pfn_range ..
> >>
> >> The point [4] leads to necessity to find and correct all places where memmblock APIs
> >> are used and where it's expected to get MAX_NUMNODES as input parameter.
> >> The major problem is that simple "grep" will not work, because memmblock APIs calls
> >> are hidden inside other MM modules and it's not always clear
> >> what will be passed as input parameters to APIs of these MM modules
> >> (for example sparse_memory_present_with_active_regions() or sparse.c).
> > 
> > Isn't that kinda trivial to work around?  Make those functions accept
> > both MAX_NUMNODES and NUMA_NO_NODE but emit warning on MAX_NUMNODES
> > (preferably throttled reasonably).  Given the history of API, we'd
> > probably want to keep such warning for extended period of time but
> > that's what we'd need to do no matter what.
> > 
> Looks a good idea.
> 
> >> As result, WIP patch, I did, and which was posted by Santosh illustrates
> >> the probable size and complexity of the change.
> > 
> > Again, I don't really mind the order things happen but I don't think
> > it's a good idea to spread misusage with a new API.  You gotta deal
> > with it one way or the other.
> > 
> >> Sorry, but question here is not "Do or not to do?", but rather 'how to do?",
> >> taking into account complexity and state of the current MM code.
> >> For example. would it be ok if I'll workaround the issue as in the attached patch?
> > 
> > Well, it's more of when.  It's not really a technically difficult
> > task and all I'm saying is it better be sooner than later.
> > 
> Fair enough. Based on your suggestion, we will try to see if
> we can proceed with 4) accepting both MAX_NUMNODES and NUMA_NO_NODE.
> 
> Thanks for the suggestion.

So where do we now stand with this MAX_NUMNODES-vs-NUMA_NO_NODE mess? 
Is the conversion to NUMA_NO_NODE in current linux-next completed and
nicely tested?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
