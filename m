Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8923E6B0253
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 16:17:47 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id k189so2993004vkg.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 13:17:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q68si19522401qkb.227.2016.06.14.13.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 13:17:46 -0700 (PDT)
Date: Tue, 14 Jun 2016 22:17:40 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/10 -v4] Handle oom bypass more gracefully
Message-ID: <20160614201740.GA617@redhat.com>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <20160613112348.GC6518@dhcp22.suse.cz>
 <20160613141324.GK6518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613141324.GK6518@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 06/13, Michal Hocko wrote:
>
> On Mon 13-06-16 13:23:48, Michal Hocko wrote:
> > On Thu 09-06-16 13:52:07, Michal Hocko wrote:
> > > I would like to explore ways how to remove kthreads (use_mm) special
> > > case. It shouldn't be that hard, we just have to teach the page fault
> > > handler to recognize oom victim mm and enforce EFAULT for kthreads
> > > which have borrowed that mm.
> >
> > So I was trying to come up with solution for this which would require to
> > hook into the pagefault an enforce EFAULT when the mm is being reaped
> > by the oom_repaer. Not hard but then I have checked the current users
> > and none of them is really needing to read from the userspace (aka
> > copy_from_user/get_user). So we actually do not need to do anything
> > special.
>
> As pointed out by Tetsuo [1] vhost does realy on copy_from_user.

Tetsuo, Michal, but do we really care?

I have no idea what vhost does, but obviously this should not lead to kernel
crash or something like this, otherwise it should be fixed. If we are going
to kill the owner of dev->mm anyway, why should we worry about vhost_worker()
which can fail to access this ->mm after that?

So to me this additional patch looks fine, but probably I missed something?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
