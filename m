Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5A46B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:54:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x124so5377570wmf.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:54:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w2si3653573wmb.90.2017.03.16.01.54.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 01:54:09 -0700 (PDT)
Date: Thu, 16 Mar 2017 09:54:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] rework memory hotplug onlining
Message-ID: <20170316085404.GE30501@dhcp22.suse.cz>
References: <20170315091347.GA32626@dhcp22.suse.cz>
 <1489622542.9118.8.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489622542.9118.8.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "vkuznets@redhat.com" <vkuznets@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel.kiper@oracle.com" <daniel.kiper@oracle.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "imammedo@redhat.com" <imammedo@redhat.com>, "rientjes@google.com" <rientjes@google.com>, "mgorman@suse.de" <mgorman@suse.de>, "ak@linux.intel.com" <ak@linux.intel.com>, "slaoub@gmail.com" <slaoub@gmail.com>

On Wed 15-03-17 23:08:14, Kani, Toshimitsu wrote:
> On Wed, 2017-03-15 at 10:13 +0100, Michal Hocko wrote:
>  :
> > @@ -388,39 +389,44 @@ static ssize_t show_valid_zones(struct device
> > *dev,
> >  				struct device_attribute *attr, char
> > *buf)
> >  {
> >  	struct memory_block *mem = to_memory_block(dev);
> > -	unsigned long start_pfn, end_pfn;
> > -	unsigned long valid_start, valid_end, valid_pages;
> > -	unsigned long nr_pages = PAGES_PER_SECTION *
> > sections_per_block;
> > +	unsigned long start_pfn, nr_pages;
> > +	bool append = false;
> >  	struct zone *zone;
> > -	int zone_shift = 0;
> > +	int nid;
> >  
> >  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
> > -	end_pfn = start_pfn + nr_pages;
> > +	zone = page_zone(pfn_to_page(start_pfn));
> > +	nr_pages = PAGES_PER_SECTION * sections_per_block;
> >  
> > -	/* The block contains more than one zone can not be
> > offlined. */
> > -	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start,
> > &valid_end))
> > +	/*
> > +	 * The block contains more than one zone can not be
> > offlined.
> > +	 * This can happen e.g. for ZONE_DMA and ZONE_DMA32
> > +	 */
> > +	if (!test_pages_in_a_zone(start_pfn, start_pfn + nr_pages,
> > NULL, NULL))
> >  		return sprintf(buf, "none\n");
> >  
> > -	zone = page_zone(pfn_to_page(valid_start));
> 
> Please do not remove the fix made in a96dfddbcc043. zone needs to be
> set from valid_start, not from start_pfn.

Thanks for pointing this out. I was scratching my head about this part
but was too tired from previous git archeology so I didn't check the
history of this particular part.

I will restore the original behavior but before I do that I am really
curious whether partial memblocks are even supported for onlining. Maybe
I am missing something but I do not see any explicit checks for NULL
struct page when we set zone boundaries or online a memblock. Is it
possible those memblocks are just never hotplugable?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
