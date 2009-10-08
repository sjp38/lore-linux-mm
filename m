Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BBC286B004F
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 05:16:17 -0400 (EDT)
Date: Thu, 8 Oct 2009 11:16:12 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v3][RFC] add MAP_UNLOCKED mmap flag
Message-ID: <20091008091611.GD16702@redhat.com>
References: <20091006190316.GB19692@redhat.com>
 <874oqap7xw.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874oqap7xw.fsf@gmail.com>
Sender: owner-linux-mm@kvack.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 08, 2009 at 05:10:35PM +0800, WANG Cong wrote:
> Gleb Natapov <gleb@redhat.com> writes:
> 
> > If application does mlockall(MCL_FUTURE) it is no longer possible to
> > mmap file bigger than main memory or allocate big area of anonymous
> > memory. Sometimes it is desirable to lock everything related to program
> > execution into memory, but still be able to mmap big file or allocate
> > huge amount of memory and allow OS to swap them on demand. MAP_UNLOCKED
> > allows to do that.
> >
> > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> 
> <snip>
> 
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 73f5e4b..ecc4471 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -985,6 +985,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
> >  		if (!can_do_mlock())
> >  			return -EPERM;
> >  
> > +        if (flags & MAP_UNLOCKED)
> > +                vm_flags &= ~VM_LOCKED;
> > +
> >  	/* mlock MCL_FUTURE? */
> >  	if (vm_flags & VM_LOCKED) {
> >  		unsigned long locked, lock_limit;
> 
> So, if I read it correctly, it is perfectly legal to set
> both MAP_LOCKED and MAP_UNLOCKED at the same time? While
> the behavior is still same as only setting MAP_UNLOCKED.
> 
> Is this what we expect?
> 
This is what code does currently. Should we return EINVAL in this case?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
