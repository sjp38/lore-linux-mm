Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86DC96B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:32:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e3so26205528pfc.4
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:32:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k85si1912048pfb.470.2017.06.27.06.32.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 06:32:01 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170626130346.26314-1-mhocko@kernel.org>
	<201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
	<20170627112650.GK28072@dhcp22.suse.cz>
	<201706272039.HGG51520.QOMHFVOFtOSJFL@I-love.SAKURA.ne.jp>
	<20170627120317.GL28072@dhcp22.suse.cz>
In-Reply-To: <20170627120317.GL28072@dhcp22.suse.cz>
Message-Id: <201706272231.ABH00025.FMOFOJSVLOQHFt@I-love.SAKURA.ne.jp>
Date: Tue, 27 Jun 2017 22:31:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 27-06-17 20:39:28, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > I wonder why you prefer timeout based approach. Your patch will after all
> > > > set MMF_OOM_SKIP if operations between down_write() and up_write() took
> > > > more than one second.
> > > 
> > > if we reach down_write then we have unmapped the address space in
> > > exit_mmap and oom reaper cannot do much more.
> > 
> > So, by the time down_write() is called, majority of memory is already released, isn't it?
> 
> In most cases yes. To be put it in other words. By the time exit_mmap
> takes down_write there is nothing more oom reaper could reclaim.
> 
Then, aren't there two exceptions which your patch cannot guarantee;
down_write(&mm->mmap_sem) in __ksm_exit() and __khugepaged_exit() ?

Since for some reason exit_mmap() cannot be brought to before
ksm_exit(mm)/khugepaged_exit(mm) calls,

	ksm_exit(mm);
	khugepaged_exit(mm); /* must run before exit_mmap */
	exit_mmap(mm);

shouldn't we try __oom_reap_task_mm() before calling these down_write()
if mm is OOM victim's?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
