Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 131486B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 02:07:32 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id f8so56442008pag.2
        for <linux-mm@kvack.org>; Sun, 29 May 2016 23:07:32 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id ah8si48458862pad.148.2016.05.29.23.07.29
        for <linux-mm@kvack.org>;
        Sun, 29 May 2016 23:07:30 -0700 (PDT)
Date: Mon, 30 May 2016 15:08:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
Message-ID: <20160530060803.GA28624@bbox>
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <20160524025811.GA29094@bbox>
 <20160526003719.GB9661@bbox>
 <8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
 <20160527051432.GF2322@bbox>
 <20160527060839.GC13661@js1304-P5Q-DELUXE>
 <20160527081108.GG2322@bbox>
 <20160530053906.GA25079@js1304-P5Q-DELUXE>
MIME-Version: 1.0
In-Reply-To: <20160530053906.GA25079@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Shi, Yang" <yang.shi@linaro.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Mon, May 30, 2016 at 02:39:06PM +0900, Joonsoo Kim wrote:
> On Fri, May 27, 2016 at 05:11:08PM +0900, Minchan Kim wrote:
> > On Fri, May 27, 2016 at 03:08:39PM +0900, Joonsoo Kim wrote:
> > > On Fri, May 27, 2016 at 02:14:32PM +0900, Minchan Kim wrote:
> > > > On Thu, May 26, 2016 at 04:15:28PM -0700, Shi, Yang wrote:
> > > > > On 5/25/2016 5:37 PM, Minchan Kim wrote:
> > > > > >On Tue, May 24, 2016 at 11:58:11AM +0900, Minchan Kim wrote:
> > > > > >>On Mon, May 23, 2016 at 10:16:08AM -0700, Yang Shi wrote:
> > > > > >>>Per the discussion with Joonsoo Kim [1], we need check the return value of
> > > > > >>>lookup_page_ext() for all call sites since it might return NULL in some cases,
> > > > > >>>although it is unlikely, i.e. memory hotplug.
> > > > > >>>
> > > > > >>>Tested with ltp with "page_owner=0".
> > > > > >>>
> > > > > >>>[1] http://lkml.kernel.org/r/20160519002809.GA10245@js1304-P5Q-DELUXE
> > > > > >>>
> > > > > >>>Signed-off-by: Yang Shi <yang.shi@linaro.org>
> > > > > >>
> > > > > >>I didn't read code code in detail to see how page_ext memory space
> > > > > >>allocated in boot code and memory hotplug but to me, it's not good
> > > > > >>to check NULL whenever we calls lookup_page_ext.
> > > > > >>
> > > > > >>More dangerous thing is now page_ext is used by optionable feature(ie, not
> > > > > >>critical for system stability) but if we want to use page_ext as
> > > > > >>another important tool for the system in future,
> > > > > >>it could be a serious problem.
> > > 
> > > Hello, Minchan.
> > 
> > Hi Joonsoo,
> > 
> > > 
> > > I wonder how pages that isn't managed by kernel yet will cause serious
> > > problem. Until onlining, these pages are out of our scope. Any
> > > information about them would be useless until it is actually
> > > activated. I guess that returning NULL for those pages will not hurt
> > > any functionality. Do you have any possible scenario that this causes the
> > > serious problem?
> > 
> > I don't have any specific usecase now. That's why I said "in future".
> > And I don't want to argue whether there is possible scenario or not
> > to make the feature useful but if you want, I should write novel.
> > One of example, pop up my mind, xen, hv and even memory_hotplug itself
> > might want to use page_ext for their functionality extension to hook
> > guest pages.
> 
> There is no detail so I can't guess how to use it and how it causes
> the serious problem. But, we can do it when it is really needed.
> 
> > 
> > My opinion is that page_ext is extension of struct page so it would
> > be better to allow any operation on struct page without any limitation
> > if we can do it. Whether it's useful or useless depend on random
> > usecase and we don't need to limit that way from the beginning.
> 
> If there is no drawback, it would be a better design. But, we have
> trade-off that for some case that the memory is added but not
> onlined, there is memory saving if we allocate page_ext later.
> So, in current situation that there is no user to require such
> guarantee, I don't think it's worth doing right now.
> 
> > However, current design allows deferred page_ext population so any user
> > of page_ext should keep it in mind and should either make fallback plan
> > or don't use page_ext for those cases. If we decide go this way through
> > discussion, at least, we should make such limitation more clear to
> > somewhere in this chance, maybe around page_ext_operation->need comment.
> 
> Agreed.

Okay, We realized from this discussion that by design, guest of page_ext
at the meoment should know his page_ext access from the page can be failed
so every caller should prepare for it.

Shi, Yang, Please include some comment about that in your patch to
prevent further reviewer waste his time with repeating same discussion
and client of page_ext can know the limitation.

> 
> > My comment's point is that we should consider that way at least. It's
> > worth to discuss pros and cons, what's the best and what makes that way
> > hesitate if we can't.
> 
> Yes, your suggestion would be good for future direction, but, for now,
> I think that inserting NULL to all callers is right fix.
> 
> 1) Current design that page_ext is allocated when online is design
> decision of page_ext to save memory as much as possible. Fixing
> possible problem within this design decision looks good to me.

Okay. Shi Yang, please include this comment in your patch, too.

> 
> 2) Maybe, we need to backport fixes because it would crash older
> kernels. In this case, fix with NULL is easy to backport.

Agreed.

Then, Shi Yang need to mark the page as stable.
Shi, Please resend your patch with hard testing and more better
description with marking it as stable.
And I know another race problem about Shi's patch.
I will reply to the thread.

> 
> > > 
> > > And, allocation such memory space doesn't come from free. If someone
> > > just add the memory device and don't online it, these memory will be
> > 
> > Here goes several questions.
> > Cced hotplug guys
> > 
> > 1.
> > If someone just add the memory device without onlining, kernel code
> > can return pfn_valid == true on the offlined page?
> 
> AFAIK, yes.
> > 
> > 2.
> > If so, it means memmap on offline memory is already populated somewhere.
> > Where is the memmap allocated? part of offlined memory space or other memory?
> 
> Other memory.
> 
> > 3. Could we allocate page_ext in part of offline memory space so that
> > it doesn't consume online memory.
> > 
> > > wasted. I don't know if there is such a usecase but it's possible
> > > scenario.
> > 
> > > 
> > > > > >>
> > > > > >>Can we put some hooks of page_ext into memory-hotplug so guarantee
> > > > > >>that page_ext memory space is allocated with memmap space at the
> > > > > >>same time? IOW, once every PFN wakers find a page is valid, page_ext
> > > > > >>is valid, too so lookup_page_ext never returns NULL on valid page
> > > > > >>by design.
> > > > > >>
> > > > > >>I hope we consider this direction, too.
> > > > > >
> > > > > >Yang, Could you think about this?
> > > > > 
> > > > > Thanks a lot for the suggestion. Sorry for the late reply, I was
> > > > > busy on preparing patches. I do agree this is a direction we should
> > > > > look into, but I haven't got time to think about it deeper. I hope
> > > > > Joonsoo could chime in too since he is the original author for page
> > > > > extension.
> > > > > 
> > > > > >
> > > > > >Even, your patch was broken, I think.
> > > > > >It doesn't work with !CONFIG_DEBUG_VM && !CONFIG_PAGE_POISONING because
> > > > > >lookup_page_ext doesn't return NULL in that case.
> > > > > 
> > > > > Actually, I think the #ifdef should be removed if lookup_page_ext()
> > > > > is possible to return NULL. It sounds not make sense returning NULL
> > > > > only when DEBUG_VM is enabled. It should return NULL no matter what
> > > > > debug config is selected. If Joonsoo agrees with me I'm going to
> > > > > come up with a patch to fix it.
> > > 
> > > Agreed but let's wait for Minchan's response.
> > 
> > If we goes this way, how to guarantee this race?
> > 
> >                                 kpageflags_read
> >                                 stable_page_flags
> >                                 page_is_idle
> >                                   lookup_page_ext
> >                                   section = __pfn_to_section(pfn)
> > offline_pages
> > memory_notify(MEM_OFFLINE)
> >   offline_page_ext
> >   ms->page_ext = NULL
> >                                   section->page_ext + pfn
> 
> I think that it is a fundamental problem of memory hotplug.
> There is similar race with struct page for offlined memory.
> 
> 
>                                  
>                                  kpageflags_read
>                                  pfn_valid
> remove_memory
>                                  stable_page_flags
>                                  crash!
> 
> I already reported similar race problem to memory hotplug guys but
> didn't get any answer.
> 
> lkml.kernel.org/r/20151221031501.GA32524@js1304-P5Q-DELUXE

Who's in charge of memory-hotplug? Kame, Could you nudge him?

> 
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
