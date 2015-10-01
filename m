Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id EEA4182F7A
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 10:48:22 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so33589519wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 07:48:22 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id f2si4105904wix.119.2015.10.01.07.48.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 07:48:21 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so37047590wic.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 07:48:21 -0700 (PDT)
Date: Thu, 1 Oct 2015 16:48:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20151001144820.GI24077@dhcp22.suse.cz>
References: <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
 <20150921134414.GA15974@redhat.com>
 <20150921142423.GC19811@dhcp22.suse.cz>
 <20150921153252.GA21988@redhat.com>
 <20150921161203.GD19811@dhcp22.suse.cz>
 <20150922160608.GA2716@redhat.com>
 <20150923205923.GB19054@dhcp22.suse.cz>
 <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
 <20150925093556.GF16497@dhcp22.suse.cz>
 <alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Mon 28-09-15 15:24:06, David Rientjes wrote:
> On Fri, 25 Sep 2015, Michal Hocko wrote:
> 
> > > > I am still not sure how you want to implement that kernel thread but I
> > > > am quite skeptical it would be very much useful because all the current
> > > > allocations which end up in the OOM killer path cannot simply back off
> > > > and drop the locks with the current allocator semantic.  So they will
> > > > be sitting on top of unknown pile of locks whether you do an additional
> > > > reclaim (unmap the anon memory) in the direct OOM context or looping
> > > > in the allocator and waiting for kthread/workqueue to do its work. The
> > > > only argument that I can see is the stack usage but I haven't seen stack
> > > > overflows in the OOM path AFAIR.
> > > > 
> > > 
> > > Which locks are you specifically interested in?
> > 
> > Any locks they were holding before they entered the page allocator (e.g.
> > i_mutex is the easiest one to trigger from the userspace but mmap_sem
> > might be involved as well because we are doing kmalloc(GFP_KERNEL) with
> > mmap_sem held for write). Those would be locked until the page allocator
> > returns, which with the current semantic might be _never_.
> > 
> 
> I agree that i_mutex seems to be one of the most common offenders.  
> However, I'm not sure I understand why holding it while trying to allocate 
> infinitely for an order-0 allocation is problematic wrt the proposed 
> kthread. 

I didn't say it would be problematic. We are talking past each other
here. All I wanted to say was that a separate kernel oom thread wouldn't
_help_ with the lock dependencies.

> The kthread itself need only take mmap_sem for read.  If all 
> threads sharing the mm with a victim have been SIGKILL'd, they should get 
> TIF_MEMDIE set when reclaim fails and be able to allocate so that they can 
> drop mmap_sem. 

which is the case if the direct oom context used trylock...
So just to make it clear. I am not objecting a specialized oom kernel
thread. It would work as well. I am just not convinced that it is really
needed because the direct oom context can use trylock and do the same
work directly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
