Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 03F166B0038
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 21:44:56 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h41so16804040ioi.1
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 18:44:56 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id 201si9766116itw.49.2017.04.23.18.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Apr 2017 18:44:54 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id z67so12733169itb.0
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 18:44:54 -0700 (PDT)
Date: Mon, 24 Apr 2017 10:44:43 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: your mail
Message-ID: <20170424014441.GA29305@js1304-desktop>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
 <20170421043826.GC13966@js1304-desktop>
 <20170421071616.GC14154@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170421071616.GC14154@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 21, 2017 at 09:16:16AM +0200, Michal Hocko wrote:
> On Fri 21-04-17 13:38:28, Joonsoo Kim wrote:
> > On Thu, Apr 20, 2017 at 09:28:20AM +0200, Michal Hocko wrote:
> > > On Thu 20-04-17 10:27:55, Joonsoo Kim wrote:
> > > > On Mon, Apr 17, 2017 at 10:15:15AM +0200, Michal Hocko wrote:
> > > [...]
> > > > > Which pfn walkers you have in mind?
> > > > 
> > > > For example, kpagecount_read() in fs/proc/page.c. I searched it by
> > > > using pfn_valid().
> > > 
> > > Yeah, I've checked that one and in fact this is a good example of the
> > > case where you do not really care about holes. It just checks the page
> > > count which is a valid information under any circumstances.
> > 
> > I don't think so. First, it checks the page *map* count. Is it still valid
> > even if PageReserved() is set?
> 
> I do not know about any user which would manipulate page map count for
> referenced pages. The core MM code doesn't.

That's weird that we can get *map* count without PageReserved() check,
but we cannot get zone information.
Zone information is more static information than map count.

It should be defined/documented in this time that what information in
the struct page is valid even if PageReserved() is set. And then, we
need to fix all the things based on this design decision.

> 
> > What I'd like to ask in this example is
> > that what information is valid if PageReserved() is set. Is there any
> > design document on this? I think that we need to define/document it first.
> 
> NO, it is not AFAIK.
> 
> [...]
> > > OK, fair enough. I did't consider memblock allocations. I will rethink
> > > this patch but there are essentially 3 options
> > > 	- use a different criterion for the offline holes dection. I
> > > 	  have just realized we might do it by storing the online
> > > 	  information into the mem sections
> > > 	- drop this patch
> > > 	- move the PageReferenced check down the chain into
> > > 	  isolate_freepages_block resp. isolate_migratepages_block
> > > 
> > > I would prefer 3 over 2 over 1. I definitely want to make this more
> > > robust so 1 is preferable long term but I do not want this to be a
> > > roadblock to the rest of the rework. Does that sound acceptable to you?
> > 
> > I like #1 among of above options and I already see your patch for #1.
> > It's much better than your first attempt but I'm still not happy due
> > to the semantic of pfn_valid().
> 
> You are trying to change a semantic of something that has a well defined
> meaning. I disagree that we should change it. It might sound like a
> simpler thing to do because pfn walkers will have to be checked but what
> you are proposing is conflating two different things together.

I don't think that *I* try to change the semantic of pfn_valid().
It would be original semantic of pfn_valid().

"If pfn_valid() returns true, we can get proper struct page and the
zone information,"

That situation is now being changed by your patch *hotplug rework*.

"Even if pfn_valid() returns true, we cannot get the zone information
without PageReserved() check, since *zone is determined during
onlining* and pfn_valid() return true after adding the memory."

> 
> > > [..]
> > > > Let me clarify my desire(?) for this issue.
> > > > 
> > > > 1. If pfn_valid() returns true, struct page has valid information, at
> > > > least, in flags (zone id, node id, flags, etc...). So, we can use them
> > > > without checking PageResereved().
> > > 
> > > This is no longer true after my rework. Pages are associated with the
> > > zone during _onlining_ rather than when they are physically hotpluged.
> > 
> > If your rework make information valid during _onlining_, my
> > suggestion is making pfn_valid() return false until onlining.
> > 
> > Caller of pfn_valid() expects that they can get valid information from
> > the struct page. There is no reason to access the struct page if they
> > can't get valid information from it. So, passing pfn_valid() should
> > guarantee that, at least, some kind of information is valid.
> > 
> > If pfn_valid() doesn't guarantee it, most of the pfn walker should
> > check PageResereved() to make sure that validity of information from
> > the struct page.
> 
> This is true only for those walkers which really depend on the full
> initialization. This is not the case for all of them. I do not see any
> reason to introduce another _pfn_valid to just check whether there is a
> struct page...

It's really confusing concept that only some information is valid for
*not* fully initialized struct page. Even, there is no document that
what information is valid for this half-initialized struct page.

Better design would be that we regard that every information is
invalid for half-initialized struct page. In this case, it's natural
to make pfn_valid() returns false for this half-initialized struct page.

>  
> So please do not conflate those two different concepts together. I
> believe that the most prominent pfn walkers should be covered now and
> others can be evaluated later.

Even if original pfn_valid()'s semantic is not the one that I mentioned,
I think that suggested semantic from me is better.
Only hotplug code need to be changed and others doesn't need to be changed.
There is no overhead for others. What's the problem about this approach?

And, I'm not sure that you covered the most prominent pfn walkers.
Please see pagetypeinfo_showblockcount_print() in mm/vmstat.c.
As you admitted, additional check approach is really error-prone and
this example shows that.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
