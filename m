Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF2EA6B026C
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 19:53:52 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id x130so74124564vkc.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 16:53:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 79si7255317qkz.161.2016.07.15.16.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 16:53:51 -0700 (PDT)
Date: Fri, 15 Jul 2016 19:53:49 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <alpine.DEB.2.10.1607151447490.121215@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1607151943510.13011@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <20160712064905.GA14586@dhcp22.suse.cz> <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com> <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1607140818250.15554@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607141316240.68666@chino.kir.corp.google.com> <alpine.LRH.2.02.1607150711270.5034@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607151422140.121215@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1607151730430.21114@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607151447490.121215@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com



On Fri, 15 Jul 2016, David Rientjes wrote:

> Kworkers are processing writeback, ext4_writepages() relies on kmem that 

ext4_writepages is above device mapper, not below, so how it could block 
device mapper progress?

Do you use device mapper on the top of block loop device? Writing to loop 
is prone to deadlock anyway, you should avoid that in production code.

> is reclaiming memory itself through kmem_getpages() and they are waiting 
> on the oom victim to exit so they endlessly loop in the page allocator 
> themselves.  Same situation with __alloc_skb() so we can intermittently 
> lose access to hundreds of the machines over the network.  There are no 
> custom drivers required for this to happen, the stack trace has already 
> been posted of the livelock victim and this can happen for anything in 
> filemap_fault() that has TIF_MEMDIE set.

Again - filemap_failt() is above device mapper, not below (unless you use 
loop).

> > > frankly don't care about your patch reviewing of dm mempool usage when 
> > > dm_request() livelocked our kernel.
> > 
> > If it livelocked, it is a bug in some underlying block driver, not a bug 
> > in mempool_alloc.
> > 
> 
> Lol, the interface is quite clear and can be modified to allow mempool 
> users to set __GFP_NOMEMALLOC on their mempool_alloc() request if they can 
> guarantee elements will be returned to the freelist in all situations, 

You still didn't post configuration of your block stack, so I have no clue 
why entries are not returned to the mempool.

> including system oom situations.  We may revert that ourselves if our 
> machines time out once we use a post-4.7 kernel and report that as 
> necessary.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
