Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0386B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 10:21:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y3so66656443qkc.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 07:21:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s43si2166538qts.20.2016.07.13.07.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 07:21:10 -0700 (PDT)
Date: Wed, 13 Jul 2016 10:21:07 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <20160713111426.GG28723@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1607131019300.31769@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <1e31eea2-beb4-5734-c831-0c1753f0115a@redhat.com> <20160713111426.GG28723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jerome Marchand <jmarchan@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Wed, 13 Jul 2016, Michal Hocko wrote:

> On Wed 13-07-16 10:35:01, Jerome Marchand wrote:
> > On 07/13/2016 01:44 AM, Mikulas Patocka wrote:
> > > The problem of swapping to dm-crypt is this.
> > > 
> > > The free memory goes low, kswapd decides that some page should be swapped 
> > > out. However, when you swap to an ecrypted device, writeback of each page 
> > > requires another page to hold the encrypted data. dm-crypt uses mempools 
> > > for all its structures and pages, so that it can make forward progress 
> > > even if there is no memory free. However, the mempool code first allocates 
> > > from general memory allocator and resorts to the mempool only if the 
> > > memory is below limit.
> > > 
> > > So every attempt to swap out some page allocates another page.
> > > 
> > > As long as swapping is in progress, the free memory is below the limit 
> > > (because the swapping activity itself consumes any memory over the limit). 
> > > And that triggered the OOM killer prematurely.
> > 
> > There is a quite recent sysctl vm knob that I believe can help in this
> > case: watermark_scale_factor. If you increase this value, kswapd will
> > start paging out earlier, when there might still be enough free memory.
> > 
> > Ondrej, have you tried to increase /proc/sys/vm/watermark_scale_factor?
> 
> I suspect this would just change the timing or the real problem gets
> hidden.

I agree - tweaking some limits would just change the probability of the 
bug without addressing the root cause.

We shouldn't tweak anything and just stick to Ondrej's scenario where he 
reproduced the bug.

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
