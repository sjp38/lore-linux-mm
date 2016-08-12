Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7726B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 12:23:35 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id r9so591107ywg.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 09:23:35 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id c194si3057633wme.107.2016.08.12.09.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 09:23:34 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i138so3761877wmf.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 09:23:34 -0700 (PDT)
Date: Fri, 12 Aug 2016 18:23:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't	reap
 memory read by vhost
Message-ID: <20160812162331.GB24345@dhcp22.suse.cz>
References: <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160812155734.GT3482@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812155734.GT3482@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Fri 12-08-16 08:57:34, Paul E. McKenney wrote:
> On Fri, Aug 12, 2016 at 03:21:41PM +0200, Oleg Nesterov wrote:
> > On 08/12, Michal Hocko wrote:
> > >
> > > > Let's CC Paul. Just to describe the situation. We have the following
> > > > situation:
> > > >
> > > > #define __get_user_mm(mm, x, ptr)				\
> > > > ({								\
> > > > 	int ___gu_err = __get_user(x, ptr);			\
> > > > 	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
> > > > 		___gu_err = -EFAULT;				\
> > > > 	___gu_err;						\
> > > > })
> > > >
> > > > and the oom reaper doing:
> > > >
> > > > 	set_bit(MMF_UNSTABLE, &mm->flags);
> > > >
> > > > 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > > > 		unmap_page_range
> > > >
> > > > I assume that write memory barrier between set_bit and unmap_page_range
> > > > is not really needed because unmapping should already imply the memory
> > > > barrier.
> > 
> > Well, I leave this to Paul, but...
> > 
> > I think it is not needed because we can rely on pte locking. We do
> > not care if anything is re-ordered UNLESS __get_user() above actually
> > triggers a fault and re-populates the page which was already unmapped
> > by __oom_reap_task(), and in the latter case __get_user_mm() can't
> > miss MMF_UNSTABLE simply because __get_user() and unmap_page_range()
> > need to lock/unlock the same ptlock_ptr().
> > 
> > So we only need the compiler barrier to ensure that __get_user_mm()
> > won't read MMF_UNSTABLE before __get_user(). But since __get_user()
> > is function, it is not needed too.
> > 
> > There is a more interesting case when another 3rd thread can trigger
> > a fault and populate this page before __get_user_mm() calls _get_user().
> > But even in this case I think we are fine.
> 
> Hmmm...  What source tree are you guys looking at?  I am seeing some
> of the above being macros rather than functions and others not being
> present at all...

The code is not upstream yet. You can find the current version of the
patchset here:
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git#attempts/oom-robustify

namely we are talking about 3c24392768ab ("vhost, mm: make sure that
oom_reaper doesn't reap memory read by vhost")

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
