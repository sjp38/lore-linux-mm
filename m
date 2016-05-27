Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D76086B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 02:07:41 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d197so170742666ioe.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 23:07:41 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o82si10431986itb.83.2016.05.26.23.07.40
        for <linux-mm@kvack.org>;
        Thu, 26 May 2016 23:07:41 -0700 (PDT)
Date: Fri, 27 May 2016 15:08:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
Message-ID: <20160527060839.GC13661@js1304-P5Q-DELUXE>
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <20160524025811.GA29094@bbox>
 <20160526003719.GB9661@bbox>
 <8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
 <20160527051432.GF2322@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527051432.GF2322@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Shi, Yang" <yang.shi@linaro.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Fri, May 27, 2016 at 02:14:32PM +0900, Minchan Kim wrote:
> On Thu, May 26, 2016 at 04:15:28PM -0700, Shi, Yang wrote:
> > On 5/25/2016 5:37 PM, Minchan Kim wrote:
> > >On Tue, May 24, 2016 at 11:58:11AM +0900, Minchan Kim wrote:
> > >>On Mon, May 23, 2016 at 10:16:08AM -0700, Yang Shi wrote:
> > >>>Per the discussion with Joonsoo Kim [1], we need check the return value of
> > >>>lookup_page_ext() for all call sites since it might return NULL in some cases,
> > >>>although it is unlikely, i.e. memory hotplug.
> > >>>
> > >>>Tested with ltp with "page_owner=0".
> > >>>
> > >>>[1] http://lkml.kernel.org/r/20160519002809.GA10245@js1304-P5Q-DELUXE
> > >>>
> > >>>Signed-off-by: Yang Shi <yang.shi@linaro.org>
> > >>
> > >>I didn't read code code in detail to see how page_ext memory space
> > >>allocated in boot code and memory hotplug but to me, it's not good
> > >>to check NULL whenever we calls lookup_page_ext.
> > >>
> > >>More dangerous thing is now page_ext is used by optionable feature(ie, not
> > >>critical for system stability) but if we want to use page_ext as
> > >>another important tool for the system in future,
> > >>it could be a serious problem.

Hello, Minchan.

I wonder how pages that isn't managed by kernel yet will cause serious
problem. Until onlining, these pages are out of our scope. Any
information about them would be useless until it is actually
activated. I guess that returning NULL for those pages will not hurt
any functionality. Do you have any possible scenario that this causes the
serious problem?

And, allocation such memory space doesn't come from free. If someone
just add the memory device and don't online it, these memory will be
wasted. I don't know if there is such a usecase but it's possible
scenario.

> > >>
> > >>Can we put some hooks of page_ext into memory-hotplug so guarantee
> > >>that page_ext memory space is allocated with memmap space at the
> > >>same time? IOW, once every PFN wakers find a page is valid, page_ext
> > >>is valid, too so lookup_page_ext never returns NULL on valid page
> > >>by design.
> > >>
> > >>I hope we consider this direction, too.
> > >
> > >Yang, Could you think about this?
> > 
> > Thanks a lot for the suggestion. Sorry for the late reply, I was
> > busy on preparing patches. I do agree this is a direction we should
> > look into, but I haven't got time to think about it deeper. I hope
> > Joonsoo could chime in too since he is the original author for page
> > extension.
> > 
> > >
> > >Even, your patch was broken, I think.
> > >It doesn't work with !CONFIG_DEBUG_VM && !CONFIG_PAGE_POISONING because
> > >lookup_page_ext doesn't return NULL in that case.
> > 
> > Actually, I think the #ifdef should be removed if lookup_page_ext()
> > is possible to return NULL. It sounds not make sense returning NULL
> > only when DEBUG_VM is enabled. It should return NULL no matter what
> > debug config is selected. If Joonsoo agrees with me I'm going to
> > come up with a patch to fix it.

Agreed but let's wait for Minchan's response.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
