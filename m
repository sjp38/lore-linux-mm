Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2D86B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 17:04:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so15162271pfg.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 14:04:06 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id o18si28607550pag.285.2016.07.18.14.04.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 14:04:04 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id fi15so60837346pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 14:04:04 -0700 (PDT)
Date: Mon, 18 Jul 2016 14:03:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: System freezes after OOM
In-Reply-To: <20160718073914.GD22671@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1607181401240.132608@chino.kir.corp.google.com>
References: <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com> <20160713145638.GM28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com> <20160714152913.GC12289@dhcp22.suse.cz> <alpine.DEB.2.10.1607141326500.68666@chino.kir.corp.google.com>
 <20160715072242.GB11811@dhcp22.suse.cz> <alpine.DEB.2.10.1607151426420.121215@chino.kir.corp.google.com> <20160718073914.GD22671@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 18 Jul 2016, Michal Hocko wrote:

> > There's 
> > two fundamental ways to go about it: (1) ensure mempool_alloc() can make 
> > forward progress (whether that's by way of gfp flags or access to memory 
> > reserves, which may depend on the process context such as PF_MEMALLOC) or 
> > (2) rely on an implementation detail of mempools to never access memory 
> > reserves, although it is shown to not livelock systems on 4.7 and earlier 
> > kernels, and instead rely on users of the same mempool to return elements 
> > to the freelist in all contexts, including oom contexts.  The mempool 
> > implementation itself shouldn't need any oom awareness, that should be a 
> > page allocator issue.
> 
> OK, I agree that we have a certain layer violation here. __GFP_NOMEMALLOC at
> the mempool level is kind of hack (like the whole existence of the
> flag TBH). So if you believe that the OOM part should be handled at the
> page allocator level then that has already been proposed
> http://lkml.kernel.org/r/2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp
> and not welcome because it might have other side effects as _all_
> __GFP_NOMEMALLOC users would be affected.
> 

__GFP_NOMEMALLOC is opt-in and is a workaround for PF_MEMALLOC in this 
context to prevent a depletion of reserves, so it seems trivial to allow 
mempool_alloc(__GFP_NOMEMALLOC) in contexts where it's needed and leave it 
to the user.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
