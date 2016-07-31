Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48883828F6
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 05:11:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so63951529wme.1
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 02:11:40 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id qp15si26562339wjb.256.2016.07.31.02.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jul 2016 02:11:38 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id x83so21808702wma.3
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 02:11:38 -0700 (PDT)
Date: Sun, 31 Jul 2016 11:11:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160731091136.GA22397@dhcp22.suse.cz>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160729170728.GB7698@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160729170728.GB7698@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Fri 29-07-16 19:07:28, Oleg Nesterov wrote:
> Well. I promised to not argue, but I can't resist...
> 
> On 07/28, Michal Hocko wrote:
> >
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
> > +		___gu_err = -EFAULT;				\
> > +	___gu_err;						\
> > +})
> > +
> > +/* similar to __get_user_mm */
> > +static inline __must_check long __copy_from_user_mm(struct mm_struct *mm,
> > +		void *to, const void __user * from, unsigned long n)
> > +{
> > +	long ret = __copy_from_user(to, from, n);
> > +	if ((ret >= 0) && test_bit(MMF_UNSTABLE, &mm->flags))
> > +		return -EFAULT;
> > +	return ret;
> > +}
> 
> Still fail to understand why do we actually need this, but nevermind.

Well, I only rely on what Michael told me about the possible breakage
because I am not familiar with the internals of the vhost driver enough
to tell any better.

> Can't we instead change handle_pte_fault() or do_anonymous_page() to
> fail if MMF_UNSTABLE? We can realy pte_offset_map_lock(), MMF_UNSTABLE
> must be visible under this lock.

I have considered this option but felt like this would impose the
overhead (small but still non-zero) to everybody while actually only one
user really needs this. If we had more users the page fault path might
be worthwhile but it is only use_mm users which we have 3 and only one
really needs it.

> We do not even need to actually disallow to re-populate the unmapped
> pte afaics, so we can even change handle_mm_fault() to check
> MMF_UNSTABLE after at the ens and return VM_FAULT_SIGBUS if it is set.
> 
> Oleg.
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
