Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id DBA3C6B003B
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 11:59:41 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so7880113qae.6
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 08:59:41 -0800 (PST)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id j1si56175319qer.77.2013.12.05.08.59.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 08:59:41 -0800 (PST)
Received: by mail-qc0-f180.google.com with SMTP id w7so5058306qcr.39
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 08:59:40 -0800 (PST)
Date: Thu, 5 Dec 2013 11:59:36 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation apis
Message-ID: <20131205165936.GB24062@mtj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
 <20131203232445.GX8277@htj.dyndns.org>
 <529F5047.50309@ti.com>
 <20131204160730.GQ3158@htj.dyndns.org>
 <529F5C55.1020707@ti.com>
 <52A07BBE.7060507@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A07BBE.7060507@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Thu, Dec 05, 2013 at 03:12:30PM +0200, Grygorii Strashko wrote:
> I'll try to provide more technical details here.
> As Santosh mentioned in previous e-mails, it's not easy to simply
> get rid of using MAX_NUMNODES:
> 1) we introduce new interface memblock_allocX 
> 2) our interface uses memblock APIs __next_free_mem_range_rev()
>    and __next_free_mem_range()
> 3) __next_free_mem_range_rev() and __next_free_mem_range() use MAX_NUMNODES
> 4) _next_free_mem_range_rev() and __next_free_mem_range() are used standalone,
>    outside of our interface as part of *for_each_free_mem_range* or for_each_mem_pfn_range ..
> 
> The point [4] leads to necessity to find and correct all places where memmblock APIs
> are used and where it's expected to get MAX_NUMNODES as input parameter.
> The major problem is that simple "grep" will not work, because memmblock APIs calls
> are hidden inside other MM modules and it's not always clear
> what will be passed as input parameters to APIs of these MM modules
> (for example sparse_memory_present_with_active_regions() or sparse.c).

Isn't that kinda trivial to work around?  Make those functions accept
both MAX_NUMNODES and NUMA_NO_NODE but emit warning on MAX_NUMNODES
(preferably throttled reasonably).  Given the history of API, we'd
probably want to keep such warning for extended period of time but
that's what we'd need to do no matter what.

> As result, WIP patch, I did, and which was posted by Santosh illustrates
> the probable size and complexity of the change.

Again, I don't really mind the order things happen but I don't think
it's a good idea to spread misusage with a new API.  You gotta deal
with it one way or the other.

> Sorry, but question here is not "Do or not to do?", but rather 'how to do?",
> taking into account complexity and state of the current MM code.
> For example. would it be ok if I'll workaround the issue as in the attached patch?

Well, it's more of when.  It's not really a technically difficult
task and all I'm saying is it better be sooner than later.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
