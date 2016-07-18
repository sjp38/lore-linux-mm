Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0292F6B0262
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 03:22:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so51561783wma.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:22:05 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id v207si7689541wmv.86.2016.07.18.00.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 00:22:04 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id o80so102119671wme.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:22:04 -0700 (PDT)
Date: Mon, 18 Jul 2016 09:22:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160718072201.GC22671@dhcp22.suse.cz>
References: <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607140952550.1102@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714145937.GB12289@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607141315130.17819@file01.intranet.prod.int.rdu2.redhat.com>
 <20160715083510.GD11811@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607150802380.5034@file01.intranet.prod.int.rdu2.redhat.com>
 <20160715122210.GG11811@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607151256260.7011@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607151256260.7011@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On Fri 15-07-16 13:02:17, Mikulas Patocka wrote:
> 
> 
> On Fri, 15 Jul 2016, Michal Hocko wrote:
> 
> > On Fri 15-07-16 08:11:22, Mikulas Patocka wrote:
> > > 
> > > The stacktraces showed that the kcryptd process was throttled when it 
> > > tried to do mempool allocation. Mempool adds the __GFP_NORETRY flag to the 
> > > allocation, but unfortunatelly, this flag doesn't prevent the allocator 
> > > from throttling.
> > 
> > Yes and in fact it shouldn't prevent any throttling. The flag merely
> > says that the allocation should give up rather than retry
> > reclaim/compaction again and again.
> > 
> > > I say that the process doing mempool allocation shouldn't ever be 
> > > throttled. Maybe add __GFP_NOTHROTTLE?
> > 
> > A specific gfp flag would be an option but we are slowly running out of
> > bit space there and I am not yet convinced PF_LESS_THROTTLE is
> > unsuitable.
> 
> PF_LESS_THROTTLE will make it throttle less, but it doesn't eliminate 
> throttling entirely. So, maybe add PF_NO_THROTTLE? But PF_* flags are also 
> almost exhausted.

I am not really sure we can make anybody so special to not throttle at all.
Seeing a congested backig device sounds like a reasonable compromise.
Besides that it seems that we do not really need to eliminate
wait_iff_congested for dm to work properly again AFAIU. I plan to repost
both patch today after some more internal review. If we need to do more
changes I would suggest making them in separet patches.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
