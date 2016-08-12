Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41EA16B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:57:36 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id m60so1864161uam.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 08:57:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id rz2si7659283wjb.87.2016.08.12.08.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 08:57:35 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7CFsx66103102
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:57:33 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24ru31fcg8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:57:33 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 12 Aug 2016 09:57:32 -0600
Date: Fri, 12 Aug 2016 08:57:34 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't	reap
 memory read by vhost
Reply-To: paulmck@linux.vnet.ibm.com
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812132140.GA776@redhat.com>
Message-Id: <20160812155734.GT3482@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Fri, Aug 12, 2016 at 03:21:41PM +0200, Oleg Nesterov wrote:
> On 08/12, Michal Hocko wrote:
> >
> > > Let's CC Paul. Just to describe the situation. We have the following
> > > situation:
> > >
> > > #define __get_user_mm(mm, x, ptr)				\
> > > ({								\
> > > 	int ___gu_err = __get_user(x, ptr);			\
> > > 	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
> > > 		___gu_err = -EFAULT;				\
> > > 	___gu_err;						\
> > > })
> > >
> > > and the oom reaper doing:
> > >
> > > 	set_bit(MMF_UNSTABLE, &mm->flags);
> > >
> > > 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > > 		unmap_page_range
> > >
> > > I assume that write memory barrier between set_bit and unmap_page_range
> > > is not really needed because unmapping should already imply the memory
> > > barrier.
> 
> Well, I leave this to Paul, but...
> 
> I think it is not needed because we can rely on pte locking. We do
> not care if anything is re-ordered UNLESS __get_user() above actually
> triggers a fault and re-populates the page which was already unmapped
> by __oom_reap_task(), and in the latter case __get_user_mm() can't
> miss MMF_UNSTABLE simply because __get_user() and unmap_page_range()
> need to lock/unlock the same ptlock_ptr().
> 
> So we only need the compiler barrier to ensure that __get_user_mm()
> won't read MMF_UNSTABLE before __get_user(). But since __get_user()
> is function, it is not needed too.
> 
> There is a more interesting case when another 3rd thread can trigger
> a fault and populate this page before __get_user_mm() calls _get_user().
> But even in this case I think we are fine.

Hmmm...  What source tree are you guys looking at?  I am seeing some
of the above being macros rather than functions and others not being
present at all...

							Thanx, Paul

> Whats really interesting is that I still fail to understand do we really
> need this hack, iiuc you are not sure too, and Michael didn't bother to
> explain why a bogus zero from anon memory is worse than other problems
> caused by SIGKKILL from oom-kill.c.
> 
> Oleg.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
