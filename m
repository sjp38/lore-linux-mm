Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B16DD6B02FD
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 08:19:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g71so10577294wmg.13
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 05:19:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m81si5121526wmi.39.2017.07.26.05.19.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 05:19:55 -0700 (PDT)
Date: Wed, 26 Jul 2017 14:19:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: take memory hotplug lock within
 numa_zonelist_order_handler()
Message-ID: <20170726121952.GN2981@dhcp22.suse.cz>
References: <20170726111738.38768-1-heiko.carstens@de.ibm.com>
 <20170726113112.GJ2981@dhcp22.suse.cz>
 <20170726114812.GH3218@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726114812.GH3218@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Andre Wild <wild@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On Wed 26-07-17 13:48:12, Heiko Carstens wrote:
> On Wed, Jul 26, 2017 at 01:31:12PM +0200, Michal Hocko wrote:
> > On Wed 26-07-17 13:17:38, Heiko Carstens wrote:
> > [...]
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 6d30e914afb6..fc32aa81f359 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -4891,9 +4891,11 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
> > >  				NUMA_ZONELIST_ORDER_LEN);
> > >  			user_zonelist_order = oldval;
> > >  		} else if (oldval != user_zonelist_order) {
> > > +			mem_hotplug_begin();
> > >  			mutex_lock(&zonelists_mutex);
> > >  			build_all_zonelists(NULL, NULL);
> > >  			mutex_unlock(&zonelists_mutex);
> > > +			mem_hotplug_done();
> > >  		}
> > >  	}
> > >  out:
> > 
> > Please note that this code has been removed by
> > http://lkml.kernel.org/r/20170721143915.14161-2-mhocko@kernel.org. It
> > will get to linux-next as soon as Andrew releases a new version mmotm
> > tree.
> 
> We still would need something for 4.13, no?

If this presents a real problem then yes. Has this happened in a real
workload or during some artificial test? I mean the code has been like
that for ages and nobody noticed/reported any problems.

That being said, I do not have anything against your patch. It is
trivial to rebase mine on top of yours. I am just not sure it is worth
the code churn. E.g. do you think this patch is a stable backport
material?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
