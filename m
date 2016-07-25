Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26D6D6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 07:47:19 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u142so376971707oia.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 04:47:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k25si11319264otd.283.2016.07.25.04.47.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 04:47:18 -0700 (PDT)
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160722120519.GJ794@dhcp22.suse.cz>
	<201607231159.IFD26547.HVMOQtSJFOFFOL@I-love.SAKURA.ne.jp>
	<20160725084803.GE9401@dhcp22.suse.cz>
	<201607252007.BGI56224.SHVFLFOOFMJtOQ@I-love.SAKURA.ne.jp>
	<20160725112140.GF9401@dhcp22.suse.cz>
In-Reply-To: <20160725112140.GF9401@dhcp22.suse.cz>
Message-Id: <201607252047.CHG57343.JFSOHMFVOQFtLO@I-love.SAKURA.ne.jp>
Date: Mon, 25 Jul 2016 20:47:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> On Mon 25-07-16 20:07:11, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > Are you planning to change the scope where the OOM victims can access memory
> > > > reserves?
> > > 
> > > Yes. Because we know that there are some post exit_mm allocations and I
> > > do not want to get back to PF_EXITING and other tricks...
> > > 
> > > > (1) If you plan to allow the OOM victims to access memory reserves until
> > > >     TASK_DEAD, tsk_is_oom_victim() will be as trivial as
> > > > 
> > > > bool tsk_is_oom_victim(struct task_struct *task)
> > > > {
> > > > 	return task->signal->oom_mm;
> > > > }
> > > 
> > > yes, exactly. That's what I've tried to say above. with the oom_mm this
> > > is trivial to implement while mm lists will not help us much due to
> > > their life time. This also means that we know about the oom victim until
> > > it is unhashed and become invisible to the oom killer.
> > 
> > Then, what are advantages with allowing only OOM victims access to memory
> > reserves after they left exit_mm()?
> 
> Because they might need it in order to move on... Say you want to close
> all the files which might release considerable amount of memory or any
> other post exit_mm() resources.

OOM victims might need memory reserves in order to move on, but non OOM victims
might also need memory reserves in order to move on. And non OOM victims might
be blocking OOM victims via locks.

> > Since we assume that mm_struct is the primary source of memory consumption,
> > we don't select threads which already left exit_mm(). Since we assume that
> > mm_struct is the primary source of memory consumption, why should we
> > distinguish OOM victims and non OOM victims after they left exit_mm()?
> 
> Because we might prevent from pointless OOM killer selection that way.

That "might" sounds obscure to me.

If currently allocating task is not an OOM victim then not giving it
access to memory reserves will cause OOM victim selection.
We might prevent from pointless OOM victim selection by giving
killed/exiting tasks access to memory reserves.

> If we know that the currently allocating task is an OOM victim then
> giving it access to memory reserves is preferable to selecting another
> oom victim.

If we know that the currently allocating task is killed/exiting then
giving it access to memory reserves is preferable to selecting another
OOM victim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
