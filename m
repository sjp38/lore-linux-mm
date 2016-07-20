Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6C26B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 02:29:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so25099759lfw.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 23:29:16 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id 196si25229689wme.130.2016.07.19.23.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 23:29:14 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id q128so42096184wma.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 23:29:14 -0700 (PDT)
Date: Wed, 20 Jul 2016 08:29:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or
 global init
Message-ID: <20160720062912.GA11249@dhcp22.suse.cz>
References: <1466426628-15074-1-git-send-email-mhocko@kernel.org>
 <1466426628-15074-11-git-send-email-mhocko@kernel.org>
 <20160719120538.GE9490@dhcp22.suse.cz>
 <20160719162759.e391c685db7a8de30b79320c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160719162759.e391c685db7a8de30b79320c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 19-07-16 16:27:59, Andrew Morton wrote:
> On Tue, 19 Jul 2016 14:05:39 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > After this patch we should guarantee a forward progress for the OOM
> > > killer even when the selected victim is sharing memory with a kernel
> > > thread or global init.
> > 
> > Could you replace the last two paragraphs with the following. Tetsuo
> > didn't like the guarantee mentioned there because that is a too strong
> > statement as find_lock_task_mm might not find any mm and so we still
> > could end up looping on the oom victim if it gets stuck somewhere in
> > __mmput. This particular patch didn't aim at closing that case. Plugging
> > that hole is planned later after the next upcoming merge window closes.
> > 
> > "
> > In order to help a forward progress for the OOM killer, make sure
> > that this really rare cases will not get into the way and hide
> > the mm from the oom killer by setting MMF_OOM_REAPED flag for it.
> > oom_scan_process_thread will ignore any TIF_MEMDIE task if it has
> > MMF_OOM_REAPED flag set to catch these oom victims.
> > 		        
> > After this patch we should guarantee a forward progress for the OOM
> > killer even when the selected victim is sharing memory with a kernel
> > thread or global init as long as the victims mm is still alive.
> > "
> 
> I tweaked it a bit:
> 
> : In order to help forward progress for the OOM killer, make sure that
> : this really rare case will not get in the way - we do this by hiding
> : the mm from the oom killer by setting MMF_OOM_REAPED flag for it. 
> : oom_scan_process_thread will ignore any TIF_MEMDIE task if it has
> : MMF_OOM_REAPED flag set to catch these oom victims.
> : 
> : After this patch we should guarantee forward progress for the OOM
> : killer even when the selected victim is sharing memory with a kernel
> : thread or global init as long as the victims mm is still alive.

Sounds good to me. Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
