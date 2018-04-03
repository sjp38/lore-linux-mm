Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C88BA6B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:59:01 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 1-v6so9547176plv.6
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:59:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d70si2093127pfl.219.2018.04.03.04.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 04:59:00 -0700 (PDT)
Date: Tue, 3 Apr 2018 04:58:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-ID: <20180403115857.GC5832@bombadil.infradead.org>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>

On Thu, Mar 29, 2018 at 02:30:03PM -0700, Andrew Morton wrote:
> > @@ -440,6 +440,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
> >  			continue;
> >  		}
> >  		charge = 0;
> > +		if (fatal_signal_pending(current)) {
> > +			retval = -EINTR;
> > +			goto out;
> > +		}
> >  		if (mpnt->vm_flags & VM_ACCOUNT) {
> >  			unsigned long len = vma_pages(mpnt);
> 
> I think a comment explaining why we're doing this would help.
> 
> Better would be to add a new function "current_is_oom_killed()" or
> such, which becomes self-documenting.  Because there are other reasons
> why a task may have a fatal signal pending.

I disagree that we need a comment here, or to create an alias.  Someone
who knows nothing of the oom-killer (like, er, me) reading that code sees
"Oh, we're checking for fatal signals here.  I guess it doesn't make sense
to continue forking a process if it's already received a fatal signal."

One might speculate about the causes of the fatal signal having been
received and settle on reasons which make sense even without thinking
of the OOM case.  Because it's why it was introduced, I always think
about a task blocked on a dead NFS mount.  If it's multithreaded and
one of the threads called fork() while another thread was blocked on a
page fault and the dup_mmap() had to wait for the page fault to finish
... that would make some kind of sense.
