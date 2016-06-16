Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 796ED6B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:33:52 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ao6so70086902pac.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:33:52 -0700 (PDT)
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com. [209.85.192.173])
        by mx.google.com with ESMTPS id w74si4180112pfa.169.2016.06.15.23.33.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 23:33:51 -0700 (PDT)
Received: by mail-pf0-f173.google.com with SMTP id i123so13072930pfg.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:33:51 -0700 (PDT)
Date: Thu, 16 Jun 2016 08:33:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v4] Handle oom bypass more gracefully
Message-ID: <20160616063347.GD30768@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <20160613112348.GC6518@dhcp22.suse.cz>
 <20160613141324.GK6518@dhcp22.suse.cz>
 <20160614201740.GA617@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160614201740.GA617@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 14-06-16 22:17:40, Oleg Nesterov wrote:
> On 06/13, Michal Hocko wrote:
> >
> > On Mon 13-06-16 13:23:48, Michal Hocko wrote:
> > > On Thu 09-06-16 13:52:07, Michal Hocko wrote:
> > > > I would like to explore ways how to remove kthreads (use_mm) special
> > > > case. It shouldn't be that hard, we just have to teach the page fault
> > > > handler to recognize oom victim mm and enforce EFAULT for kthreads
> > > > which have borrowed that mm.
> > >
> > > So I was trying to come up with solution for this which would require to
> > > hook into the pagefault an enforce EFAULT when the mm is being reaped
> > > by the oom_repaer. Not hard but then I have checked the current users
> > > and none of them is really needing to read from the userspace (aka
> > > copy_from_user/get_user). So we actually do not need to do anything
> > > special.
> >
> > As pointed out by Tetsuo [1] vhost does realy on copy_from_user.
> 
> Tetsuo, Michal, but do we really care?
> 
> I have no idea what vhost does, but obviously this should not lead to kernel
> crash or something like this, otherwise it should be fixed. If we are going
> to kill the owner of dev->mm anyway, why should we worry about vhost_worker()
> which can fail to access this ->mm after that?

This needs a deeper investigation. It relies on some state flags copied
from the userspace. I suspect it might misbehave but let's leave this
alone for a while. It is more complicated than I expected.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
