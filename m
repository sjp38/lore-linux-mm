Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1856B0390
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 03:16:25 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f66so114605059ioe.12
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 00:16:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si9357393pfk.355.2017.04.21.00.16.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 00:16:23 -0700 (PDT)
Date: Fri, 21 Apr 2017 09:16:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: your mail
Message-ID: <20170421071616.GC14154@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
 <20170421043826.GC13966@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170421043826.GC13966@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 21-04-17 13:38:28, Joonsoo Kim wrote:
> On Thu, Apr 20, 2017 at 09:28:20AM +0200, Michal Hocko wrote:
> > On Thu 20-04-17 10:27:55, Joonsoo Kim wrote:
> > > On Mon, Apr 17, 2017 at 10:15:15AM +0200, Michal Hocko wrote:
> > [...]
> > > > Which pfn walkers you have in mind?
> > > 
> > > For example, kpagecount_read() in fs/proc/page.c. I searched it by
> > > using pfn_valid().
> > 
> > Yeah, I've checked that one and in fact this is a good example of the
> > case where you do not really care about holes. It just checks the page
> > count which is a valid information under any circumstances.
> 
> I don't think so. First, it checks the page *map* count. Is it still valid
> even if PageReserved() is set?

I do not know about any user which would manipulate page map count for
referenced pages. The core MM code doesn't.

> What I'd like to ask in this example is
> that what information is valid if PageReserved() is set. Is there any
> design document on this? I think that we need to define/document it first.

NO, it is not AFAIK.

[...]
> > OK, fair enough. I did't consider memblock allocations. I will rethink
> > this patch but there are essentially 3 options
> > 	- use a different criterion for the offline holes dection. I
> > 	  have just realized we might do it by storing the online
> > 	  information into the mem sections
> > 	- drop this patch
> > 	- move the PageReferenced check down the chain into
> > 	  isolate_freepages_block resp. isolate_migratepages_block
> > 
> > I would prefer 3 over 2 over 1. I definitely want to make this more
> > robust so 1 is preferable long term but I do not want this to be a
> > roadblock to the rest of the rework. Does that sound acceptable to you?
> 
> I like #1 among of above options and I already see your patch for #1.
> It's much better than your first attempt but I'm still not happy due
> to the semantic of pfn_valid().

You are trying to change a semantic of something that has a well defined
meaning. I disagree that we should change it. It might sound like a
simpler thing to do because pfn walkers will have to be checked but what
you are proposing is conflating two different things together.

> > [..]
> > > Let me clarify my desire(?) for this issue.
> > > 
> > > 1. If pfn_valid() returns true, struct page has valid information, at
> > > least, in flags (zone id, node id, flags, etc...). So, we can use them
> > > without checking PageResereved().
> > 
> > This is no longer true after my rework. Pages are associated with the
> > zone during _onlining_ rather than when they are physically hotpluged.
> 
> If your rework make information valid during _onlining_, my
> suggestion is making pfn_valid() return false until onlining.
> 
> Caller of pfn_valid() expects that they can get valid information from
> the struct page. There is no reason to access the struct page if they
> can't get valid information from it. So, passing pfn_valid() should
> guarantee that, at least, some kind of information is valid.
> 
> If pfn_valid() doesn't guarantee it, most of the pfn walker should
> check PageResereved() to make sure that validity of information from
> the struct page.

This is true only for those walkers which really depend on the full
initialization. This is not the case for all of them. I do not see any
reason to introduce another _pfn_valid to just check whether there is a
struct page...
 
So please do not conflate those two different concepts together. I
believe that the most prominent pfn walkers should be covered now and
others can be evaluated later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
