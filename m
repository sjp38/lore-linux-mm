Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 526426B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 03:19:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c55so17805008wrc.22
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 00:19:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h78si14786263wmi.31.2017.04.18.00.19.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 00:19:26 -0700 (PDT)
Date: Tue, 18 Apr 2017 09:19:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/9] mm, memory_hotplug: get rid of is_zone_device_section
Message-ID: <20170418071923.GE22360@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-5-mhocko@kernel.org>
 <20170417201235.GA6511@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170417201235.GA6511@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>

On Mon 17-04-17 16:12:35, Jerome Glisse wrote:
[...]
> > @@ -741,11 +730,16 @@ static int remove_memory_section(unsigned long node_id,
> >  {
> >  	struct memory_block *mem;
> >  
> > -	if (is_zone_device_section(section))
> > -		return 0;
> > -
> >  	mutex_lock(&mem_sysfs_mutex);
> > +
> > +	/*
> > +	 * Some users of the memory hotplug do not want/need memblock to
> > +	 * track all sections. Skip over those.
> > +	 */
> >  	mem = find_memory_block(section);
> > +	if (!mem)
> > +		return 0;
> > +
> 
> Another bug above spoted by Evgeny Baskakov from NVidia, mutex unlock
> is missing ie something like:
> 
> if (!mem) {
> 	mutex_unlock(&mem_sysfs_mutex);
> 	return 0;
> }

Thanks for spotting this. I went with the following fixup
---
