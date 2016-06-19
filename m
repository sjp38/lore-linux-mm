Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE276B0253
	for <linux-mm@kvack.org>; Sun, 19 Jun 2016 17:35:47 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id t7so331584280vkf.2
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 14:35:47 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id q72si5687230wme.1.2016.06.19.14.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jun 2016 14:35:45 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id c82so6919956wme.3
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 14:35:45 -0700 (PDT)
Date: Sun, 19 Jun 2016 23:35:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160619213543.GA32752@dhcp22.suse.cz>
References: <1466154017-2222-1-git-send-email-mhocko@kernel.org>
 <20160618025904-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160618025904-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>

On Sat 18-06-16 03:09:02, Michael S. Tsirkin wrote:
> On Fri, Jun 17, 2016 at 11:00:17AM +0200, Michal Hocko wrote:
[...]
> > It seems that vhost usage would suffer from this problem because
> > it reads from the userspace to get (status) flags and makes some
> > decisions based on the read value.  I do not understand the code so I
> > couldn't evaluate whether that would lead to some real problems so I
> > conservatively assumed it wouldn't handle that gracefully.
> 
> Getting an error from __get_user and friends is handled gracefully.
> Getting zero instead of a real value will cause userspace
> memory corruption.

OK, thanks for the confirmation! I will add this to the changelog. I
assume that the memory corruption could "leak out" of the mm we just
read from, right? I am asking because the mm and all its users will die
by SIGKILL so they will not "see" the corruption. I am not familiar with the
vhost transfer model but I guess it wouldn't be uncommon if the target
memory could be a shared object (e.g. tmpfs or a regular file) so it
would outlive the mm.

[...]

> > @@ -1713,7 +1713,7 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> >  	/* They could have slipped one in as we were doing that: make
> >  	 * sure it's written, then check again. */
> >  	smp_mb();
> > -	r = __get_user(avail_idx, &vq->avail->idx);
> > +	r = __get_user_mm(dev->mm,avail_idx, &vq->avail->idx);
> 
> space after , pls

sure

> 
> >  	if (r) {
> >  		vq_err(vq, "Failed to check avail idx at %p: %d\n",
> >  		       &vq->avail->idx, r);
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 6d81a1eb974a..2b00ac7faa18 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -513,6 +513,7 @@ static inline int get_dumpable(struct mm_struct *mm)
> >  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
> >  #define MMF_OOM_REAPED		21	/* mm has been already reaped */
> >  #define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
> > +#define MMF_UNSTABLE		23	/* mm is unstable for copy_from_user */
> >  
> >  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
> >  
> > diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> > index 349557825428..b1f314fca3c8 100644
> > --- a/include/linux/uaccess.h
> > +++ b/include/linux/uaccess.h
> > @@ -76,6 +76,28 @@ static inline unsigned long __copy_from_user_nocache(void *to,
> >  #endif		/* ARCH_HAS_NOCACHE_UACCESS */
> >  
> >  /*
> > + * A safe variant of __get_user for for use_mm() users to have a
> > + * gurantee that the address space wasn't reaped in the background
> > + */
> > +#define __get_user_mm(mm, x, ptr)				\
> > +({								\
> > +	int ___gu_err = __get_user(x, ptr);			\
> > +	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
> 
> test_bit is somewhat expensive. See my old mail
> 	x86/bitops: implement __test_bit

Do you have a msg_id?

> I dropped it as virtio just switched to simple &/| for features,
> but we might need something like this now.

Is this such a hot path that something like this would make a visible
difference? 

> 
> 
> 
> > +		___gu_err = -EFAULT;				\
> > +	___gu_err;						\
> > +})
> > +
> > +/* similar to __get_user_mm */
> > +static inline __must_check long __copy_from_user_mm(struct mm_struct *mm,
> > +		void *to, const void __user * from, unsigned long n)
> > +{
> > +	long ret = __copy_from_user(to, from, n);
> > +	if (!ret && test_bit(MMF_UNSTABLE, &mm->flags))
> > +		return -EFAULT;
> > +	return ret;

And I've just noticed that this is not correct. We need 
	if ((ret >= 0) && test_bit(MMF_UNSTABLE, &mm->flags))

[...]

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 6303bc7caeda..3fa43e96a59b 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -506,6 +506,12 @@ static bool __oom_reap_task(struct task_struct *tsk)
> >  		goto mm_drop;
> >  	}
> >  
> > +	/*
> > +	 * Tell all users of get_user_mm/copy_from_user_mm that the content
> > +	 * is no longer stable.
> > +	 */
> > +	set_bit(MMF_UNSTABLE, &mm->flags);
> > +
> 
> do we need some kind of barrier after this?

Well I believe we don't because unmapping the memory will likely
imply memory barriers on the way.

> 
> and if yes - does flag read need a barrier before it too?

A good question. I was basically assuming the same as above. If we didn't fault
then the oom reaper wouldn't touch that memory and so we are safe even when
we see the outdated mm flags, if the memory was reaped then we have to page
fault and that should imply memory barrier AFAIU.

Does that make sense?

> 
> >  	tlb_gather_mmu(&tlb, mm, 0, -1);
> >  	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> >  		if (is_vm_hugetlb_page(vma))
> > -- 
> > 2.8.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
