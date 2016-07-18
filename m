Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCC3C6B0261
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 03:39:16 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id c124so239497358ywd.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:39:16 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id g134si13495938wme.1.2016.07.18.00.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 00:39:15 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id f65so91290726wmi.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:39:15 -0700 (PDT)
Date: Mon, 18 Jul 2016 09:39:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160718073914.GD22671@dhcp22.suse.cz>
References: <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
 <20160713133955.GK28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
 <20160714152913.GC12289@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607141326500.68666@chino.kir.corp.google.com>
 <20160715072242.GB11811@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607151426420.121215@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1607151426420.121215@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 15-07-16 14:47:30, David Rientjes wrote:
> On Fri, 15 Jul 2016, Michal Hocko wrote:
[...]
> > And let me repeat your proposed patch
> > has a undesirable side effects so we should think about a way to deal
> > with those cases. It might work for your setups but it shouldn't break
> > others at the same time. OOM situation is quite unlikely compared to
> > simple memory depletion by writing to a swap...
> >  
> 
> I haven't proposed any patch, not sure what the reference is to.

I was talking about f9054c70d28b ("mm, mempool: only set
__GFP_NOMEMALLOC if there are free elements"). Do you at least recognize
it has caused a regression which is more likely than the OOM lockup you
are referring to and that might be very specific to your particular
workload? I would really like to move on here and come up with a fix
which can handle dm-crypt swapout gracefully and also deal with the
typical case when the OOM victim is inside the mempool_alloc which
should help your usecase as well (at least the writeout path).

> There's 
> two fundamental ways to go about it: (1) ensure mempool_alloc() can make 
> forward progress (whether that's by way of gfp flags or access to memory 
> reserves, which may depend on the process context such as PF_MEMALLOC) or 
> (2) rely on an implementation detail of mempools to never access memory 
> reserves, although it is shown to not livelock systems on 4.7 and earlier 
> kernels, and instead rely on users of the same mempool to return elements 
> to the freelist in all contexts, including oom contexts.  The mempool 
> implementation itself shouldn't need any oom awareness, that should be a 
> page allocator issue.

OK, I agree that we have a certain layer violation here. __GFP_NOMEMALLOC at
the mempool level is kind of hack (like the whole existence of the
flag TBH). So if you believe that the OOM part should be handled at the
page allocator level then that has already been proposed
http://lkml.kernel.org/r/2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp
and not welcome because it might have other side effects as _all_
__GFP_NOMEMALLOC users would be affected.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
