Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id D22826B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 07:03:32 -0400 (EDT)
Received: by oibi136 with SMTP id i136so7042079oib.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 04:03:32 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mn3si18777280oeb.66.2015.10.07.04.03.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 07 Oct 2015 04:03:31 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150921153252.GA21988@redhat.com>
	<20150921161203.GD19811@dhcp22.suse.cz>
	<20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<20151006184502.GA15787@redhat.com>
In-Reply-To: <20151006184502.GA15787@redhat.com>
Message-Id: <201510072003.DCC69259.tJOOFOFFMLQSVH@I-love.SAKURA.ne.jp>
Date: Wed, 7 Oct 2015 20:03:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com, mhocko@kernel.org
Cc: torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Oleg Nesterov wrote:
> > > Hmm. If we already have mmap_sem and started zap_page_range() then
> > > I do not think it makes sense to stop until we free everything we can.
> >
> > Zapping a huge address space can take quite some time
> 
> Yes, and this is another reason we should do this asynchronously.
> 
> > and we really do
> > not have to free it all on behalf of the killer when enough memory is
> > freed to allow for further progress and the rest can be done by the
> > victim. If one batch doesn't seem sufficient then another retry can
> > continue.
> >
> > I do not think that a limited scan would make the implementation more
> > complicated
> 
> But we can't even know much memory unmap_single_vma() actually frees.
> Even if we could, how can we know we freed enough?
> 
> Anyway. Perhaps it makes sense to abort the for_each_vma() loop if
> freed_enough_mem() == T. But it is absolutely not clear to me how we
> should define this freed_enough_mem(), so I think we should do this
> later.

Maybe

  bool freed_enough_mem(void) { !atomic_read(&oom_victims); }

if we change to call mark_oom_victim() on all threads which should be
killed as OOM victims.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
