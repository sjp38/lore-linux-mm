Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 167706B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 03:38:52 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id gf5so2130274lab.36
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 00:38:52 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ka3si12400691lbc.0.2014.06.20.00.38.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jun 2014 00:38:51 -0700 (PDT)
Date: Fri, 20 Jun 2014 11:38:38 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 2/3] fork: reset mm->pinned_vm
Message-ID: <20140620073838.GA5387@esperanza>
References: <fa98629155872c1b97ba4dcd00d509a1e467c1c3.1403168346.git.vdavydov@parallels.com>
 <63d594c88850aa64729fceec769681f9d1d6fa68.1403168346.git.vdavydov@parallels.com>
 <20140619135820.57c4934dd613c5e723f9ca82@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140619135820.57c4934dd613c5e723f9ca82@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: oleg@redhat.com, rientjes@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 19, 2014 at 01:58:20PM -0700, Andrew Morton wrote:
> On Thu, 19 Jun 2014 13:07:47 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > mm->pinned_vm counts pages of mm's address space that were permanently
> > pinned in memory by increasing their reference counter. The counter was
> > introduced by commit bc3e53f682d9 ("mm: distinguish between mlocked and
> > pinned pages"), while before it locked_vm had been used for such pages.
> > 
> > Obviously, we should reset the counter on fork if !CLONE_VM, just like
> > we do with locked_vm, but currently we don't. Let's fix it.
> > 
> > ...
> >
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -534,6 +534,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
> >  	atomic_long_set(&mm->nr_ptes, 0);
> >  	mm->map_count = 0;
> >  	mm->locked_vm = 0;
> > +	mm->pinned_vm = 0;
> >  	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
> >  	spin_lock_init(&mm->page_table_lock);
> >  	mm_init_cpumask(mm);
> 
> What are the runtime effects of this?  I think it is only
> "/proc/pid/status:VmPin is screwed up", because we don't use vm_pinned
> in rlimit checks.  Yes?

Hmm, ib_umem_get[infiniband] and perf_mmap still check pinned_vm against
RLIMIT_MEMLOCK. It's left from the times when pinned pages were
accounted under locked_vm, but today it looks wrong. It isn't clear to
me how we should deal with it.

And BTW, we still have some drivers accounting pinned pages under
mm->locked_vm - this is what commit bc3e53f682d9 was fighting against.
It's infiniband/usnic and vfio.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
