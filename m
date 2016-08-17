Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 349776B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 12:58:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so15147498wml.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 09:58:15 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id q63si26325304wmd.131.2016.08.17.09.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 09:58:13 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q128so26088428wma.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 09:58:13 -0700 (PDT)
Date: Wed, 17 Aug 2016 18:58:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160817165811.GG20703@dhcp22.suse.cz>
References: <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160813001500.yvmv67cram3bp7ug@redhat.com>
 <20160814084151.GA9248@dhcp22.suse.cz>
 <20160814165720.wcvejj7h6k7zz72a@redhat.com>
 <20160815020525-mutt-send-email-mst@kernel.org>
 <20160815094912.GB3360@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160815094912.GB3360@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Mon 15-08-16 11:49:12, Michal Hocko wrote:
> On Mon 15-08-16 02:06:31, Michael S. Tsirkin wrote:
> [...]
> > So fundamentally, won't the following make copy to/from user
> > return EFAULT?  If yes, vhost is already prepared to handle that.
> > 
> > 
> > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > index dc80230..e5dbee5 100644
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -1309,6 +1309,11 @@ retry:
> >  		might_sleep();
> >  	}
> >  
> > +	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags))) {
> > +		bad_area(regs, error_code, address);
> > +		return;
> > +	}
> > +
> >  	vma = find_vma(mm, address);
> >  	if (unlikely(!vma)) {
> >  		bad_area(regs, error_code, address);
> 
> This would be racy but even if we did the check _after_ the #PF is
> handled then I am not very happy to touch the #PF path which is quite
> hot for something as rare as OOM and which only has one user which needs
> a special handling. That is the primary reason why I prefer the specific
> API.

I would really appreciate if we could reach some conclusion here. I
would like to target the upcoming merge window. I do not insist on the
approach I have taken but I feel it is the least disruptive wrt. the
usecase. If there is a strong opposition and a general agreement that
hooking into the page fault handler is a better way to go I can
implement that. But please consider the amount of work and the fact that
it is only vhost which really matters here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
