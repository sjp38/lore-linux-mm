Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C734E6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:26:35 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 192so179874733itm.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 23:26:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o133si12983448oif.18.2016.09.12.23.26.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 23:26:34 -0700 (PDT)
Subject: Re: [RFC 3/4] mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201609041050.BFG65134.OHVFQJOOSLMtFF@I-love.SAKURA.ne.jp>
	<20160909140851.GP4844@dhcp22.suse.cz>
	<201609101529.GCI12481.VOtOLHJQFOSMFF@I-love.SAKURA.ne.jp>
	<201609102155.AHJ57859.SOFHQFOtOFLJVM@I-love.SAKURA.ne.jp>
	<20160912091141.GD14524@dhcp22.suse.cz>
In-Reply-To: <20160912091141.GD14524@dhcp22.suse.cz>
Message-Id: <201609131525.IGF78600.JFOOVQMOLSHFFt@I-love.SAKURA.ne.jp>
Date: Tue, 13 Sep 2016 15:25:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com, viro@zeniv.linux.org.uk

Michal Hocko wrote:
> On Sat 10-09-16 21:55:49, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > If you worry about tasks which are sitting on a memory which is not
> > > reclaimable by the oom reaper, why you don't worry about tasks which
> > > share mm and do not share signal (i.e. clone(CLONE_VM && !CLONE_SIGHAND)
> > > tasks) ? Thawing only tasks which share signal is a halfway job.
> > > 
> > 
> > Here is a different approach which does not thaw tasks as of mark_oom_victim()
> > but thaws tasks as of oom_killer_disable(). I think that we don't need to
> > distinguish OOM victims and killed/exiting tasks when we disable the OOM
> > killer, for trying to reclaim as much memory as possible is preferable for
> > reducing the possibility of memory allocation failure after the OOM killer
> > is disabled.
> 
> This makes the oom_killer_disable suspend specific which is imho not
> necessary. While we do not have any other user outside of the suspend
> path right now and I hope we will not need any in a foreseeable future
> there is no real reason to do a hack like this if we can make the
> implementation suspend independent.

My intention is to somehow get rid of oom_killer_disable(). While I wrote
this approach, I again came to wonder why we need to disable the OOM killer
during suspend.

If the reason is that the OOM killer thaws already frozen OOM victims,
we won't have reason to disable the OOM killer if the OOM killer does not
thaw OOM victims. We can rely on the OOM killer/reaper immediately before
start taking a memory snapshot for suspend.

If the reason is that the OOM killer changes SIGKILL pending state of
already frozen OOM victims during taking a memory snapshot, I think that
sending SIGKILL via not only SysRq-f but also SysRq-i will be problematic.

If the reason is that the OOM reaper changes content of mm_struct of
OOM victims during taking a memory snapshot, what guarantees that
the OOM reaper does not call __oom_reap_task_mm() because we are not
waiting for oom_reaper_list to become NULL at oom_killer_disable(), for
patch "oom, suspend: fix oom_killer_disable vs. pm suspend properly"
removed set_freezable() from oom_reaper() which made oom_reaper() no
longer enter __refrigerator() at wait_event_freezable() in oom_reaper() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
