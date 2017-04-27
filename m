Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2EE66B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:10:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 142so1477833wma.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:10:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si2874081wre.324.2017.04.27.08.10.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 08:10:48 -0700 (PDT)
Date: Thu, 27 Apr 2017 17:10:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: your mail
Message-ID: <20170427151046.GN4706@dhcp22.suse.cz>
References: <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
 <20170421043826.GC13966@js1304-desktop>
 <20170421071616.GC14154@dhcp22.suse.cz>
 <20170424014441.GA29305@js1304-desktop>
 <20170424075312.GA1739@dhcp22.suse.cz>
 <20170425025043.GA32583@js1304-desktop>
 <20170426091906.GB12504@dhcp22.suse.cz>
 <20170427020835.GA29169@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170427020835.GA29169@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 27-04-17 11:08:38, Joonsoo Kim wrote:
> On Wed, Apr 26, 2017 at 11:19:06AM +0200, Michal Hocko wrote:
> > > > [...]
> > > > 
> > > > > > You are trying to change a semantic of something that has a well defined
> > > > > > meaning. I disagree that we should change it. It might sound like a
> > > > > > simpler thing to do because pfn walkers will have to be checked but what
> > > > > > you are proposing is conflating two different things together.
> > > > > 
> > > > > I don't think that *I* try to change the semantic of pfn_valid().
> > > > > It would be original semantic of pfn_valid().
> > > > > 
> > > > > "If pfn_valid() returns true, we can get proper struct page and the
> > > > > zone information,"
> > > > 
> > > > I do not see any guarantee about the zone information anywhere. In fact
> > > > this is not true with the original implementation as I've tried to
> > > > explain already. We do have new pages associated with a zone but that
> > > > association might change during the online phase. So you cannot really
> > > > rely on that information until the page is online. There is no real
> > > > change in that regards after my rework.
> > > 
> > > I know that what you did doesn't change thing much. What I try to say
> > > is that previous implementation related to pfn_valid() in hotplug is
> > > wrong. Please do not assume that hotplug implementation is correct and
> > > other pfn_valid() users are incorrect. There is no design document so
> > > I'm not sure which one is correct but assumption that pfn_valid() user
> > > can access whole the struct page information makes much sense to me.
> > 
> > Not really. E.g. ZONE_DEVICE pages are never online AFAIK. I believe we
> > still need pfn_valid to work for those pfns. Really, pfn_valid has a
> 
> It's really contrary example to your insist. They requires not only
> struct page but also other information, especially, the zone index.
> They checks zone idx to know whether this page is for ZONE_DEVICE or not.

Yes and they guarantee this association is true. Without memory onlining
though. This memory is never online for anybody who is asking.

[...]

> I think that I did my best to explain my reasoning. It seems that we
> cannot agree with each other so it's better for some others to express
> their opinion to this problem. I will stop this discussion from now
> on.

I _do_ appreciate your feedback and if the general consensus is to
modify pfn_valid I can go that direction but my gut feeling tells me
that conflating "existing struct page" test and "fully online and
initialized" one is a wrong thing to do.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
