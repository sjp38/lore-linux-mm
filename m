Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B65922806D8
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:50:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b124so1241204wmf.6
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 05:50:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l67si20630458wmd.167.2017.04.19.05.50.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 05:50:14 -0700 (PDT)
Date: Wed, 19 Apr 2017 14:50:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: consider zone which is not fully populated to
 have holes
Message-ID: <20170419125010.GH29789@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170415121734.6692-2-mhocko@kernel.org>
 <97a658cd-e656-6efa-7725-150063d276f1@suse.cz>
 <20170418092757.GM22360@dhcp22.suse.cz>
 <12814e7e-5ed7-de1f-3e7c-9501eec1682a@suse.cz>
 <20170419121637.GG29789@dhcp22.suse.cz>
 <b9859e0e-79ee-6e79-0d25-a6e31895ee7f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b9859e0e-79ee-6e79-0d25-a6e31895ee7f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 19-04-17 14:34:54, Vlastimil Babka wrote:
> On 04/19/2017 02:16 PM, Michal Hocko wrote:
> > On Wed 19-04-17 13:59:40, Vlastimil Babka wrote:
> >> On 04/18/2017 11:27 AM, Michal Hocko wrote:
> > [...]
> >>> I am not aware of any such user. PageReserved has always been about "the
> >>> core mm should touch these pages and modify their state" AFAIR.
> >>> But I believe that touching those holes just asks for problems so I
> >>> would rather have them covered.
> >>
> >> OK. I guess it's OK to use PageReserved of first pageblock page to
> >> determine if we can trust page_zone(), because the memory offline
> >> scenario should have sufficient granularity and not make holes inside
> >> pageblock?
> > 
> > Yes memblocks should be section size aligned and that is 128M resp. 2GB
> > on large machines. So we are talking about much larger than page block
> > granularity here.
> > 
> > Anyway, Joonsoo didn't like the the explicit PageReserved checks so I
> > have come with pfn_to_online_page which hides this implementation
> > detail. How do you like the following instead?
> 
> Yeah that's OK. The other two patches will be updated as well?

yes

> Ideally we would later convert this helper to use some special values
> for zone/node id (such as -1) instead of PageReserved to indicate an
> offline node, as we discussed.

I have considered zone_id to be -1 but there is just too much code which
uses the id to translate it to the struct zone * directly and that would
lead to subtle bugs. On the other hand zone_id == 0 is not optimal but
much safer from that POV. I will think about the safest way forward long
term but my intention was to have something reasonably good for starter.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
