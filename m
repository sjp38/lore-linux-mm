Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04A106B025F
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 04:35:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so9660411wma.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 01:35:12 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id r73si4040378wme.20.2016.07.15.01.35.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 01:35:11 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id o80so18812342wme.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 01:35:11 -0700 (PDT)
Date: Fri, 15 Jul 2016 10:35:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160715083510.GD11811@dhcp22.suse.cz>
References: <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607140952550.1102@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714145937.GB12289@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607141315130.17819@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607141315130.17819@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On Thu 14-07-16 13:35:35, Mikulas Patocka wrote:
> On Thu, 14 Jul 2016, Michal Hocko wrote:
> > On Thu 14-07-16 10:00:16, Mikulas Patocka wrote:
> > > But it needs other changes to honor the PF_LESS_THROTTLE flag:
> > > 
> > > static int current_may_throttle(void)
> > > {
> > >         return !(current->flags & PF_LESS_THROTTLE) ||
> > >                 current->backing_dev_info == NULL ||
> > >                 bdi_write_congested(current->backing_dev_info);
> > > }
> > > --- if you set PF_LESS_THROTTLE, current_may_throttle may still return 
> > > true if one of the other conditions is met.
> > 
> > That is true but doesn't that mean that the device is congested and
> > waiting a bit is the right thing to do?
> 
> You shouldn't really throttle mempool allocations at all. It's better to 
> fail the allocation quickly and allocate from a mempool reserve than to 
> wait 0.1 seconds in the reclaim path.

Well, but we do that already, no? The first allocation request is NOWAIT
and then we try to consume an object from the pool. We are re-adding
__GFP_DIRECT_RECLAIM in case both fail. The point of throttling is to
prevent from scanning through LRUs too quickly while we know that the
bdi is congested.

> dm-crypt can do approximatelly 100MB/s. That means that it processes 25k 
> swap pages per second. If you wait in mempool_alloc, the allocation would 
> be satisfied in 0.00004s. If you wait in the allocator's throttle 
> function, you waste 0.1s.
> 
> 
> It is also questionable if those 0.1 second sleeps are reasonable at all. 
> SSDs with 100k IOPS are common - they can drain the request queue in much 
> less time than 0.1 second. I think those hardcoded 0.1 second sleeps 
> should be replaced with sleeps until the device stops being congested.

Well if we do not do throttle_vm_writeout then the only remaining
writeout throttling for PF_LESS_THROTTLE is wait_iff_congested for
the direct reclaim and that should wake up if the device stops being
congested AFAIU.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
