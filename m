Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12C5F6B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 08:08:34 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n7so9464724wrb.0
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 05:08:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si1962437wmc.133.2018.04.03.05.08.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 05:08:32 -0700 (PDT)
Date: Tue, 3 Apr 2018 14:08:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-ID: <20180403120831.GT5501@dhcp22.suse.cz>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
 <20180403115857.GC5832@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403115857.GC5832@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>

On Tue 03-04-18 04:58:57, Matthew Wilcox wrote:
> On Thu, Mar 29, 2018 at 02:30:03PM -0700, Andrew Morton wrote:
> > > @@ -440,6 +440,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
> > >  			continue;
> > >  		}
> > >  		charge = 0;
> > > +		if (fatal_signal_pending(current)) {
> > > +			retval = -EINTR;
> > > +			goto out;
> > > +		}
> > >  		if (mpnt->vm_flags & VM_ACCOUNT) {
> > >  			unsigned long len = vma_pages(mpnt);
> > 
> > I think a comment explaining why we're doing this would help.
> > 
> > Better would be to add a new function "current_is_oom_killed()" or
> > such, which becomes self-documenting.  Because there are other reasons
> > why a task may have a fatal signal pending.
> 
> I disagree that we need a comment here, or to create an alias.  Someone
> who knows nothing of the oom-killer (like, er, me) reading that code sees
> "Oh, we're checking for fatal signals here.  I guess it doesn't make sense
> to continue forking a process if it's already received a fatal signal."
> 
> One might speculate about the causes of the fatal signal having been
> received and settle on reasons which make sense even without thinking
> of the OOM case.  Because it's why it was introduced, I always think
> about a task blocked on a dead NFS mount.  If it's multithreaded and
> one of the threads called fork() while another thread was blocked on a
> page fault and the dup_mmap() had to wait for the page fault to finish
> ... that would make some kind of sense.

I completely agree. If the check is really correct then it should be
pretty much self explanatory like many other checks. There is absolutely
zero oom specific in there. If a check _is_ oom specific then there is
something fishy going on.
-- 
Michal Hocko
SUSE Labs
