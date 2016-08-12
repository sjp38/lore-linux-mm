Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F18826B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 09:21:54 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 93so45050835qtg.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 06:21:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x128si3255773qkd.192.2016.08.12.06.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 06:21:53 -0700 (PDT)
Date: Fri, 12 Aug 2016 15:21:41 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't
	reap memory read by vhost
Message-ID: <20160812132140.GA776@redhat.com>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org> <1469734954-31247-10-git-send-email-mhocko@kernel.org> <20160728233359-mutt-send-email-mst@kernel.org> <20160729060422.GA5504@dhcp22.suse.cz> <20160729161039-mutt-send-email-mst@kernel.org> <20160729133529.GE8031@dhcp22.suse.cz> <20160729205620-mutt-send-email-mst@kernel.org> <20160731094438.GA24353@dhcp22.suse.cz> <20160812094236.GF3639@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812094236.GF3639@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 08/12, Michal Hocko wrote:
>
> > Let's CC Paul. Just to describe the situation. We have the following
> > situation:
> >
> > #define __get_user_mm(mm, x, ptr)				\
> > ({								\
> > 	int ___gu_err = __get_user(x, ptr);			\
> > 	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
> > 		___gu_err = -EFAULT;				\
> > 	___gu_err;						\
> > })
> >
> > and the oom reaper doing:
> >
> > 	set_bit(MMF_UNSTABLE, &mm->flags);
> >
> > 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > 		unmap_page_range
> >
> > I assume that write memory barrier between set_bit and unmap_page_range
> > is not really needed because unmapping should already imply the memory
> > barrier.

Well, I leave this to Paul, but...

I think it is not needed because we can rely on pte locking. We do
not care if anything is re-ordered UNLESS __get_user() above actually
triggers a fault and re-populates the page which was already unmapped
by __oom_reap_task(), and in the latter case __get_user_mm() can't
miss MMF_UNSTABLE simply because __get_user() and unmap_page_range()
need to lock/unlock the same ptlock_ptr().

So we only need the compiler barrier to ensure that __get_user_mm()
won't read MMF_UNSTABLE before __get_user(). But since __get_user()
is function, it is not needed too.

There is a more interesting case when another 3rd thread can trigger
a fault and populate this page before __get_user_mm() calls _get_user().
But even in this case I think we are fine.


Whats really interesting is that I still fail to understand do we really
need this hack, iiuc you are not sure too, and Michael didn't bother to
explain why a bogus zero from anon memory is worse than other problems
caused by SIGKKILL from oom-kill.c.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
