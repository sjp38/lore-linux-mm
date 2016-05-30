Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE1D46B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 03:13:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n2so24911207wma.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 00:13:59 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id xb5si42915225wjb.223.2016.05.30.00.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 00:13:58 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id e3so19574687wme.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 00:13:58 -0700 (PDT)
Date: Mon, 30 May 2016 09:13:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm, oom: skip over vforked tasks
Message-ID: <20160530071357.GE22928@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-5-git-send-email-mhocko@kernel.org>
 <20160527164830.GF26059@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527164830.GF26059@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 27-05-16 19:48:30, Vladimir Davydov wrote:
> On Thu, May 26, 2016 at 02:40:13PM +0200, Michal Hocko wrote:
[...]
> > @@ -839,6 +841,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	for_each_process(p) {
> >  		if (!process_shares_mm(p, mm))
> >  			continue;
> > +		/*
> > +		 * vforked tasks are ignored because they will drop the mm soon
> > +		 * hopefully and even if not they will not mind being oom
> > +		 * reaped because they cannot touch any memory.
> 
> They shouldn't modify memory, but they still can touch it AFAIK.

You are right. This means that the vforked child might see zero pages.
Let me think whether this is acceptable or not.

Thanks!

> 
> > +		 */
> > +		if (p->vfork_done)
> > +			continue;
> >  		if (same_thread_group(p, victim))
> >  			continue;
> >  		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
