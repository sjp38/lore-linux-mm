Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA98D6B025E
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:42:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so1779700wmu.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:42:42 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id h11si1601054wmd.58.2016.08.12.02.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 02:42:38 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so1873311wme.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:42:38 -0700 (PDT)
Date: Fri, 12 Aug 2016 11:42:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160812094236.GF3639@dhcp22.suse.cz>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160731094438.GA24353@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>

Sorry to bother you Paul but I would be really greatful if you could
comment on this, please!

On Sun 31-07-16 11:44:38, Michal Hocko wrote:
> On Fri 29-07-16 20:57:44, Michael S. Tsirkin wrote:
> > On Fri, Jul 29, 2016 at 03:35:29PM +0200, Michal Hocko wrote:
> > > On Fri 29-07-16 16:14:10, Michael S. Tsirkin wrote:
> > > > On Fri, Jul 29, 2016 at 08:04:22AM +0200, Michal Hocko wrote:
> > > > > On Thu 28-07-16 23:41:53, Michael S. Tsirkin wrote:
> > > > > > On Thu, Jul 28, 2016 at 09:42:33PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > > > and the reader would hit a page fault
> > > > > > > +	 * if it stumbled over a reaped memory.
> > > > > > 
> > > > > > This last point I don't get. flag read could bypass data read
> > > > > > if that happens data read could happen after unmap
> > > > > > yes it might get a PF but you handle that, correct?
> > > > > 
> > > > > The point I've tried to make is that if the reader really page faults
> > > > > then get_user will imply the full barrier already. If get_user didn't
> > > > > page fault then the state of the flag is not really important because
> > > > > the reaper shouldn't have touched it. Does it make more sense now or
> > > > > I've missed your question?
> > > > 
> > > > Can task flag read happen before the get_user pagefault?
> > > 
> > > Do you mean?
> > > 
> > > get_user_mm()
> > >   temp = false <- test_bit(MMF_UNSTABLE, &mm->flags)
> > >   ret = __get_user(x, ptr)
> > >   #PF
> > >   if (!ret && temp) # misses the flag
> > > 
> > > The code is basically doing
> > > 
> > >   if (!__get_user() && test_bit(MMF_UNSTABLE, &mm->flags))
> > > 
> > > so test_bit part of the conditional cannot be evaluated before
> > > __get_user() part is done. Compiler cannot reorder two depending
> > > subconditions AFAIK.
> > 
> > But maybe the CPU can.
> 
> Are you sure? How does that differ from
> 	if (ptr && ptr->something)
> construct?
> 
> Let's CC Paul. Just to describe the situation. We have the following
> situation:
> 
> #define __get_user_mm(mm, x, ptr)				\
> ({								\
> 	int ___gu_err = __get_user(x, ptr);			\
> 	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
> 		___gu_err = -EFAULT;				\
> 	___gu_err;						\
> })
> 
> and the oom reaper doing:
> 
> 	set_bit(MMF_UNSTABLE, &mm->flags);
> 
> 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> 		unmap_page_range
> 
> I assume that write memory barrier between set_bit and unmap_page_range
> is not really needed because unmapping should already imply the memory
> barrier. A read memory barrier between __get_user and test_bit shouldn't
> be really needed because we can tolerate a stale value if __get_user
> didn't #PF because we haven't unmapped that address obviously. If we
> unmapped it then __get_user would #PF and that should imply a full
> memory barrier as well. Now the question is whether a CPU can speculate
> and read the flag before we issue the #PF.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
