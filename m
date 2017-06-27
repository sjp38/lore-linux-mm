Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F27996B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:55:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 12so5128047wmn.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:55:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si14599565wrb.275.2017.06.27.06.55.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 06:55:58 -0700 (PDT)
Date: Tue, 27 Jun 2017 15:55:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170627135555.GN28072@dhcp22.suse.cz>
References: <20170626130346.26314-1-mhocko@kernel.org>
 <201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
 <20170627112650.GK28072@dhcp22.suse.cz>
 <201706272039.HGG51520.QOMHFVOFtOSJFL@I-love.SAKURA.ne.jp>
 <20170627120317.GL28072@dhcp22.suse.cz>
 <201706272231.ABH00025.FMOFOJSVLOQHFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706272231.ABH00025.FMOFOJSVLOQHFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 27-06-17 22:31:58, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 27-06-17 20:39:28, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > I wonder why you prefer timeout based approach. Your patch will after all
> > > > > set MMF_OOM_SKIP if operations between down_write() and up_write() took
> > > > > more than one second.
> > > > 
> > > > if we reach down_write then we have unmapped the address space in
> > > > exit_mmap and oom reaper cannot do much more.
> > > 
> > > So, by the time down_write() is called, majority of memory is already released, isn't it?
> > 
> > In most cases yes. To be put it in other words. By the time exit_mmap
> > takes down_write there is nothing more oom reaper could reclaim.
> > 
> Then, aren't there two exceptions which your patch cannot guarantee;
> down_write(&mm->mmap_sem) in __ksm_exit() and __khugepaged_exit() ?

yes it cannot. Those would be quite rare situations. Somebody holding
the mmap sem would have to block those to wait for too long (that too
long might be for ever actually if we are livelocked). We cannot rule
that out of course and I would argue that it would be more appropriate
to simply go after another task in those rare cases. There is not much
we can really do. At some point the oom reaper has to give up and move
on otherwise we are back to square one when OOM could deadlock...

Maybe we can actually get rid of this down_write but I would go that way
only when it proves to be a real issue.

> Since for some reason exit_mmap() cannot be brought to before
> ksm_exit(mm)/khugepaged_exit(mm) calls,

9ba692948008 ("ksm: fix oom deadlock") would tell you more about the
ordering and the motivation.

> 
> 	ksm_exit(mm);
> 	khugepaged_exit(mm); /* must run before exit_mmap */
> 	exit_mmap(mm);
> 
> shouldn't we try __oom_reap_task_mm() before calling these down_write()
> if mm is OOM victim's?

This is what we try. We simply try to get mmap_sem for read and do our
work as soon as possible with the proposed patch. This is already an
improvement, no?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
