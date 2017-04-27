Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D73E86B02E1
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 22:08:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a188so13980505pfa.3
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 19:08:50 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id z17si1140736pff.291.2017.04.26.19.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 19:08:49 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id c198so11286629pfc.1
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 19:08:49 -0700 (PDT)
Date: Thu, 27 Apr 2017 11:08:38 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: your mail
Message-ID: <20170427020835.GA29169@js1304-desktop>
References: <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
 <20170421043826.GC13966@js1304-desktop>
 <20170421071616.GC14154@dhcp22.suse.cz>
 <20170424014441.GA29305@js1304-desktop>
 <20170424075312.GA1739@dhcp22.suse.cz>
 <20170425025043.GA32583@js1304-desktop>
 <20170426091906.GB12504@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170426091906.GB12504@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 26, 2017 at 11:19:06AM +0200, Michal Hocko wrote:
> > > [...]
> > > 
> > > > > You are trying to change a semantic of something that has a well defined
> > > > > meaning. I disagree that we should change it. It might sound like a
> > > > > simpler thing to do because pfn walkers will have to be checked but what
> > > > > you are proposing is conflating two different things together.
> > > > 
> > > > I don't think that *I* try to change the semantic of pfn_valid().
> > > > It would be original semantic of pfn_valid().
> > > > 
> > > > "If pfn_valid() returns true, we can get proper struct page and the
> > > > zone information,"
> > > 
> > > I do not see any guarantee about the zone information anywhere. In fact
> > > this is not true with the original implementation as I've tried to
> > > explain already. We do have new pages associated with a zone but that
> > > association might change during the online phase. So you cannot really
> > > rely on that information until the page is online. There is no real
> > > change in that regards after my rework.
> > 
> > I know that what you did doesn't change thing much. What I try to say
> > is that previous implementation related to pfn_valid() in hotplug is
> > wrong. Please do not assume that hotplug implementation is correct and
> > other pfn_valid() users are incorrect. There is no design document so
> > I'm not sure which one is correct but assumption that pfn_valid() user
> > can access whole the struct page information makes much sense to me.
> 
> Not really. E.g. ZONE_DEVICE pages are never online AFAIK. I believe we
> still need pfn_valid to work for those pfns. Really, pfn_valid has a

It's really contrary example to your insist. They requires not only
struct page but also other information, especially, the zone index.
They checks zone idx to know whether this page is for ZONE_DEVICE or not.

So, pfn_valid() for ZONE_DEVICE pages assume that struct page has all
the valid information. It's perfectly matched with my suggestion.
Online isn't important issue here. What the important point is the condition
that pfn_valid() return true. pfn_valid() for ZONE_DEVICE returns true after
arch_add_memory() since all the struct page information is fixed there.

If zone of hotplugged memory cannot be fixed at this moment, you can
defef it until all the information is fixed (onlining). That
seems to be better semantic of pfn_valid() to me.

> different meaning than you would like it to have. Who knows how many
> others like that are lurking there. I feel much more comfortable to go
> and hunt already broken code and fix it rathert than break something
> unexpectedly.

I think that I did my best to explain my reasoning. It seems that we
cannot agree with each other so it's better for some others to express
their opinion to this problem. I will stop this discussion from now
on.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
