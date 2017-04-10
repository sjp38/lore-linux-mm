Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E66E96B039F
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 12:31:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z62so4650301wrc.0
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 09:31:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t202si4996321wmd.109.2017.04.10.09.31.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 09:31:38 -0700 (PDT)
Date: Mon, 10 Apr 2017 18:31:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/9] mm, memory_hotplug: get rid of is_zone_device_section
Message-ID: <20170410163133.GN4618@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-5-mhocko@kernel.org>
 <20170410162002.GA31356@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170410162002.GA31356@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>

On Mon 10-04-17 12:20:02, Jerome Glisse wrote:
> On Mon, Apr 10, 2017 at 01:03:46PM +0200, Michal Hocko wrote:
[...]
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 342332f29364..1570b3eea493 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -493,7 +493,7 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
> >  }
> >  
> >  static int __meminit __add_section(int nid, struct zone *zone,
> > -					unsigned long phys_start_pfn)
> > +					unsigned long phys_start_pfn, bool want_memblock)
> >  {
> >  	int ret;
> >  
> > @@ -510,7 +510,10 @@ static int __meminit __add_section(int nid, struct zone *zone,
> >  	if (ret < 0)
> >  		return ret;
> >  
> > -	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
> > +	if (want_memblock)
> > +		ret = register_new_memory(nid, __pfn_to_section(phys_start_pfn));
> > +
> > +	return ret;
> >  }
> 
> The above is wrong for ZONE_DEVICE sparse_add_one_section() will return a
> positive value (on success) thus ret > 0 and other function in the hotplug
> path will interpret positive value as an error.
> 
> I suggest something like:
> 	if (!want_memblock)
> 		return 0;
> 
> 	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
> }

You are right! I will fold the following. Thanks!
---
