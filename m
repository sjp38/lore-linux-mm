Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22E2B6B0262
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 13:02:21 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p126so57043917qke.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 10:02:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d75si5885596qka.11.2016.07.15.10.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 10:02:20 -0700 (PDT)
Date: Fri, 15 Jul 2016 13:02:17 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <20160715122210.GG11811@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1607151256260.7011@file01.intranet.prod.int.rdu2.redhat.com>
References: <20160712064905.GA14586@dhcp22.suse.cz> <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <20160713111006.GF28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz> <alpine.LRH.2.02.1607140952550.1102@file01.intranet.prod.int.rdu2.redhat.com> <20160714145937.GB12289@dhcp22.suse.cz> <alpine.LRH.2.02.1607141315130.17819@file01.intranet.prod.int.rdu2.redhat.com>
 <20160715083510.GD11811@dhcp22.suse.cz> <alpine.LRH.2.02.1607150802380.5034@file01.intranet.prod.int.rdu2.redhat.com> <20160715122210.GG11811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com



On Fri, 15 Jul 2016, Michal Hocko wrote:

> On Fri 15-07-16 08:11:22, Mikulas Patocka wrote:
> > 
> > The stacktraces showed that the kcryptd process was throttled when it 
> > tried to do mempool allocation. Mempool adds the __GFP_NORETRY flag to the 
> > allocation, but unfortunatelly, this flag doesn't prevent the allocator 
> > from throttling.
> 
> Yes and in fact it shouldn't prevent any throttling. The flag merely
> says that the allocation should give up rather than retry
> reclaim/compaction again and again.
> 
> > I say that the process doing mempool allocation shouldn't ever be 
> > throttled. Maybe add __GFP_NOTHROTTLE?
> 
> A specific gfp flag would be an option but we are slowly running out of
> bit space there and I am not yet convinced PF_LESS_THROTTLE is
> unsuitable.

PF_LESS_THROTTLE will make it throttle less, but it doesn't eliminate 
throttling entirely. So, maybe add PF_NO_THROTTLE? But PF_* flags are also 
almost exhausted.

> I might be missing something but exactly this is what happens in
> wait_iff_congested no? If the bdi doesn't see the congestion it wakes up
> the reclaim context even before the timeout. Or are we talking past each
> other?

OK, I see that there is wait queue in congestion_wait. I didn't notice it 
before.

Mikulas

> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
