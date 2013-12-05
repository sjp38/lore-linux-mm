Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8C90C6B003D
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 12:13:22 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so3811211qcx.18
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 09:13:22 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id k3si44543212qao.10.2013.12.05.09.13.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 09:13:21 -0800 (PST)
Message-ID: <52A0B42C.5080405@ti.com>
Date: Thu, 5 Dec 2013 12:13:16 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation
 apis
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com> <20131203232445.GX8277@htj.dyndns.org> <529F5047.50309@ti.com> <20131204160730.GQ3158@htj.dyndns.org> <529F5C55.1020707@ti.com> <52A07BBE.7060507@ti.com> <20131205165936.GB24062@mtj.dyndns.org>
In-Reply-To: <20131205165936.GB24062@mtj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thursday 05 December 2013 11:59 AM, Tejun Heo wrote:
> Hello,
> 
> On Thu, Dec 05, 2013 at 03:12:30PM +0200, Grygorii Strashko wrote:
>> I'll try to provide more technical details here.
>> As Santosh mentioned in previous e-mails, it's not easy to simply
>> get rid of using MAX_NUMNODES:
>> 1) we introduce new interface memblock_allocX 
>> 2) our interface uses memblock APIs __next_free_mem_range_rev()
>>    and __next_free_mem_range()
>> 3) __next_free_mem_range_rev() and __next_free_mem_range() use MAX_NUMNODES
>> 4) _next_free_mem_range_rev() and __next_free_mem_range() are used standalone,
>>    outside of our interface as part of *for_each_free_mem_range* or for_each_mem_pfn_range ..
>>
>> The point [4] leads to necessity to find and correct all places where memmblock APIs
>> are used and where it's expected to get MAX_NUMNODES as input parameter.
>> The major problem is that simple "grep" will not work, because memmblock APIs calls
>> are hidden inside other MM modules and it's not always clear
>> what will be passed as input parameters to APIs of these MM modules
>> (for example sparse_memory_present_with_active_regions() or sparse.c).
> 
> Isn't that kinda trivial to work around?  Make those functions accept
> both MAX_NUMNODES and NUMA_NO_NODE but emit warning on MAX_NUMNODES
> (preferably throttled reasonably).  Given the history of API, we'd
> probably want to keep such warning for extended period of time but
> that's what we'd need to do no matter what.
> 
Looks a good idea.

>> As result, WIP patch, I did, and which was posted by Santosh illustrates
>> the probable size and complexity of the change.
> 
> Again, I don't really mind the order things happen but I don't think
> it's a good idea to spread misusage with a new API.  You gotta deal
> with it one way or the other.
> 
>> Sorry, but question here is not "Do or not to do?", but rather 'how to do?",
>> taking into account complexity and state of the current MM code.
>> For example. would it be ok if I'll workaround the issue as in the attached patch?
> 
> Well, it's more of when.  It's not really a technically difficult
> task and all I'm saying is it better be sooner than later.
> 
Fair enough. Based on your suggestion, we will try to see if
we can proceed with 4) accepting both MAX_NUMNODES and NUMA_NO_NODE.

Thanks for the suggestion.

regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
