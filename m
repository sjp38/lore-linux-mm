Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB29028030E
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 03:13:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x189so2959268wmg.5
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 00:13:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k128si27743wmb.185.2017.09.05.00.13.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 00:13:10 -0700 (PDT)
Date: Tue, 5 Sep 2017 09:13:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20170905071307.7aggprk66r3cem4p@dhcp22.suse.cz>
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-2-mhocko@kernel.org>
 <b8e8ffdf-4f7b-2a02-5869-53b23da645d0@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b8e8ffdf-4f7b-2a02-5869-53b23da645d0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 05-09-17 11:59:36, Anshuman Khandual wrote:
[...]
> > @@ -1634,43 +1634,25 @@ static int __ref __offline_pages(unsigned long start_pfn,
> >  
> >  	pfn = start_pfn;
> >  	expire = jiffies + timeout;
> > -	drain = 0;
> > -	retry_max = 5;
> >  repeat:
> >  	/* start memory hot removal */
> > -	ret = -EAGAIN;
> > +	ret = -EBUSY;
> >  	if (time_after(jiffies, expire))
> >  		goto failed_removal;
> >  	ret = -EINTR;
> >  	if (signal_pending(current))
> >  		goto failed_removal;
> > -	ret = 0;
> > -	if (drain) {
> > -		lru_add_drain_all_cpuslocked();
> > -		cond_resched();
> > -		drain_all_pages(zone);
> > -	}
> 
> Why we had this condition before that only when we fail in migration
> later in do_migrate_range function, drain the lru lists in the next
> attempt. Why not from the first attempt itself ? Just being curious.
 
I can only guess but draining used to invoke IPIs and that is really
costly so an optimistic attempt could try without draining and do that
only if the migration fails. Now that we have it all done in WQ context
there shouldn't be any reason to optimize for draining.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
