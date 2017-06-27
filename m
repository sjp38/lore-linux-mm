Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3896B02B4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:26:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u5so28492580pgq.14
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:26:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h11si2247336plk.114.2017.06.27.07.26.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 07:26:26 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170627112650.GK28072@dhcp22.suse.cz>
	<201706272039.HGG51520.QOMHFVOFtOSJFL@I-love.SAKURA.ne.jp>
	<20170627120317.GL28072@dhcp22.suse.cz>
	<201706272231.ABH00025.FMOFOJSVLOQHFt@I-love.SAKURA.ne.jp>
	<20170627135555.GN28072@dhcp22.suse.cz>
In-Reply-To: <20170627135555.GN28072@dhcp22.suse.cz>
Message-Id: <201706272326.BAG00561.LMJVHSFQtOOFFO@I-love.SAKURA.ne.jp>
Date: Tue, 27 Jun 2017 23:26:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 27-06-17 22:31:58, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 27-06-17 20:39:28, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > > I wonder why you prefer timeout based approach. Your patch will after all
> > > > > > set MMF_OOM_SKIP if operations between down_write() and up_write() took
> > > > > > more than one second.
> > > > > 
> > > > > if we reach down_write then we have unmapped the address space in
> > > > > exit_mmap and oom reaper cannot do much more.
> > > > 
> > > > So, by the time down_write() is called, majority of memory is already released, isn't it?
> > > 
> > > In most cases yes. To be put it in other words. By the time exit_mmap
> > > takes down_write there is nothing more oom reaper could reclaim.
> > > 
> > Then, aren't there two exceptions which your patch cannot guarantee;
> > down_write(&mm->mmap_sem) in __ksm_exit() and __khugepaged_exit() ?
> 
> yes it cannot. Those would be quite rare situations. Somebody holding
> the mmap sem would have to block those to wait for too long (that too
> long might be for ever actually if we are livelocked). We cannot rule
> that out of course and I would argue that it would be more appropriate
> to simply go after another task in those rare cases. There is not much
> we can really do. At some point the oom reaper has to give up and move
> on otherwise we are back to square one when OOM could deadlock...
> 
> Maybe we can actually get rid of this down_write but I would go that way
> only when it proves to be a real issue.
> 
> > Since for some reason exit_mmap() cannot be brought to before
> > ksm_exit(mm)/khugepaged_exit(mm) calls,
> 
> 9ba692948008 ("ksm: fix oom deadlock") would tell you more about the
> ordering and the motivation.

I don't understand ksm nor khugepaged. But that commit was actually calling
ksm_exit() just before free_pgtables() in exit_mmap(). It is ba76149f47d8c939
("thp: khugepaged") which added /* must run before exit_mmap */ comment.

> 
> > 
> > 	ksm_exit(mm);
> > 	khugepaged_exit(mm); /* must run before exit_mmap */
> > 	exit_mmap(mm);
> > 
> > shouldn't we try __oom_reap_task_mm() before calling these down_write()
> > if mm is OOM victim's?
> 
> This is what we try. We simply try to get mmap_sem for read and do our
> work as soon as possible with the proposed patch. This is already an
> improvement, no?

We can ask the OOM reaper kernel thread try to reap before the OOM killer
releases oom_lock mutex. But that is not guaranteed. It is possible that
the OOM victim thread is executed until down_write() in __ksm_exit() or
__khugepaged_exit() and then the OOM reaper kernel thread starts calling
down_read_trylock().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
