Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13E346B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 03:53:19 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 70so61666577its.15
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 00:53:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u3si17940797pfd.324.2017.04.24.00.53.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 00:53:18 -0700 (PDT)
Date: Mon, 24 Apr 2017 09:53:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: your mail
Message-ID: <20170424075312.GA1739@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
 <20170421043826.GC13966@js1304-desktop>
 <20170421071616.GC14154@dhcp22.suse.cz>
 <20170424014441.GA29305@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424014441.GA29305@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Mon 24-04-17 10:44:43, Joonsoo Kim wrote:
> On Fri, Apr 21, 2017 at 09:16:16AM +0200, Michal Hocko wrote:
> > On Fri 21-04-17 13:38:28, Joonsoo Kim wrote:
> > > On Thu, Apr 20, 2017 at 09:28:20AM +0200, Michal Hocko wrote:
> > > > On Thu 20-04-17 10:27:55, Joonsoo Kim wrote:
> > > > > On Mon, Apr 17, 2017 at 10:15:15AM +0200, Michal Hocko wrote:
> > > > [...]
> > > > > > Which pfn walkers you have in mind?
> > > > > 
> > > > > For example, kpagecount_read() in fs/proc/page.c. I searched it by
> > > > > using pfn_valid().
> > > > 
> > > > Yeah, I've checked that one and in fact this is a good example of the
> > > > case where you do not really care about holes. It just checks the page
> > > > count which is a valid information under any circumstances.
> > > 
> > > I don't think so. First, it checks the page *map* count. Is it still valid
> > > even if PageReserved() is set?
> > 
> > I do not know about any user which would manipulate page map count for
> > referenced pages. The core MM code doesn't.
> 
> That's weird that we can get *map* count without PageReserved() check,
> but we cannot get zone information.
> Zone information is more static information than map count.

As I've already pointed out the rework of the hotplug code is mainly
about postponing the zone initialization from the physical hot add to
the logical onlining. The zone is really not clear until that moment.
 
> It should be defined/documented in this time that what information in
> the struct page is valid even if PageReserved() is set. And then, we
> need to fix all the things based on this design decision.

Where would you suggest documenting this? We do have
Documentation/memory-hotplug.txt but it is not really specific about
struct page.

[...]

> > You are trying to change a semantic of something that has a well defined
> > meaning. I disagree that we should change it. It might sound like a
> > simpler thing to do because pfn walkers will have to be checked but what
> > you are proposing is conflating two different things together.
> 
> I don't think that *I* try to change the semantic of pfn_valid().
> It would be original semantic of pfn_valid().
> 
> "If pfn_valid() returns true, we can get proper struct page and the
> zone information,"

I do not see any guarantee about the zone information anywhere. In fact
this is not true with the original implementation as I've tried to
explain already. We do have new pages associated with a zone but that
association might change during the online phase. So you cannot really
rely on that information until the page is online. There is no real
change in that regards after my rework.

[...]
> > So please do not conflate those two different concepts together. I
> > believe that the most prominent pfn walkers should be covered now and
> > others can be evaluated later.
> 
> Even if original pfn_valid()'s semantic is not the one that I mentioned,
> I think that suggested semantic from me is better.
> Only hotplug code need to be changed and others doesn't need to be changed.
> There is no overhead for others. What's the problem about this approach?

That this would require to check _every_ single pfn_valid user in the
kernel. That is beyond my time capacity and not really necessary because
the current code already suffers from the same/similar class of
problems.
 
> And, I'm not sure that you covered the most prominent pfn walkers.
> Please see pagetypeinfo_showblockcount_print() in mm/vmstat.c.

I probably haven't (and will send a patch to fix this one - thanks for
pointing to it) but the point is they those are broken already and they
can be fixed in follow up patches. If you change pfn_valid you might
break an existing code in an unexpected ways.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
