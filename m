Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCDF56B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:17:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z80so32269613pff.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:17:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w61si9250776plb.745.2017.10.10.07.17.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 07:17:35 -0700 (PDT)
Date: Tue, 10 Oct 2017 16:17:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmalloc: back off only when the current task is OOM
 killed
Message-ID: <20171010141733.juvbfjdglutehvie@dhcp22.suse.cz>
References: <1507633133-5720-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171010115436.nzgo4ewodx5pyrw7@dhcp22.suse.cz>
 <201710102147.IGJ90612.OQSFMFLVtOOJFH@I-love.SAKURA.ne.jp>
 <20171010134916.x5iskqymwjj6akpo@dhcp22.suse.cz>
 <201710102313.DBB60400.QOOVHLFJFOtMFS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710102313.DBB60400.QOOVHLFJFOtMFS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, alan@llwyncelyn.cymru, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 10-10-17 23:13:21, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 10-10-17 21:47:02, Tetsuo Handa wrote:
> > > I think that massive vmalloc() consumers should be (as well as massive
> > > alloc_page() consumers) careful such that they will be chosen as first OOM
> > > victim, for vmalloc() does not abort as soon as an OOM occurs.
> > 
> > No. This would require to spread those checks all over the place. That
> > is why we have that logic inside the allocator which fails the
> > allocation at certain point in time. Large/unbound/user controlled sized
> > allocations from the kernel are always a bug and really hard one to
> > protect from. It is simply impossible to know the intention.
> > 
> > > Thus, I used
> > > set_current_oom_origin()/clear_current_oom_origin() when I demonstrated
> > > "complete" depletion.
> > 
> > which was a completely artificial example as already mentioned.
> > 
> > > > I have tried to explain this is not really needed before but you keep
> > > > insisting which is highly annoying. The patch as is is not harmful but
> > > > it is simply _pointless_ IMHO.
> > > 
> > > Then, how can massive vmalloc() consumers become careful?
> > > Explicitly use __vmalloc() and pass __GFP_NOMEMALLOC ?
> > > Then, what about adding some comment like "Never try to allocate large
> > > memory using plain vmalloc(). Use __vmalloc() with __GFP_NOMEMALLOC." ?
> > 
> > Come on! Seriously we do expect some competence from the code running in
> > the kernel space. We do not really need to add a comment that you
> > shouldn't shoot your head because it might hurt. Please try to focus on
> > real issues. There are many of them to chase after...
> > 
> My understanding is that vmalloc() is provided for allocating large memory
> where kmalloc() is difficult to satisfy. If we say "do not allocate large
> memory with vmalloc() because large allocations from the kernel are always
> a bug", it sounds like denial of raison d'etre of vmalloc(). Strange...

try to find some middle ground between literal following the wording and
a common sense. In kernel anything larger than order-3 is a large
allocation. The large we are arguing here is MBs of memory.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
