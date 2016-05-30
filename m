Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 485976B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 07:56:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c84so217582487pfc.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 04:56:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 85si13402453pfo.162.2016.05.30.04.56.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 04:56:15 -0700 (PDT)
Subject: Re: [PATCH 0/5] Handle oom bypass more gracefully
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
	<20160527160026.GA29337@dhcp22.suse.cz>
	<201605282304.DJC04167.SHLtVQMOOFFOFJ@I-love.SAKURA.ne.jp>
	<20160530072116.GF22928@dhcp22.suse.cz>
In-Reply-To: <20160530072116.GF22928@dhcp22.suse.cz>
Message-Id: <201605302010.AGF00027.tQHSFOFJMOVFOL@I-love.SAKURA.ne.jp>
Date: Mon, 30 May 2016 20:10:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

Michal Hocko wrote:
> > You are trying to make the OOM killer as per mm_struct operation. But
> > I think we need to tolerate the OOM killer as per signal_struct operation.
> 
> Signal struct based approach is full of weird behavior which just leads
> to corner cases. I think going mm struct way is the only sensible
> approach.

I don't think so. What are corner cases the OOM reaper cannot handle with
signal_struct based approach?

The OOM-killer decides based on "struct mm_struct" but it is a weakness of
the OOM-killer that it cares only "struct mm_struct". It is possible that
waiting for termination of only one thread releases a lot of memory (e.g.
by closing pipe's file descriptor) and the OOM-killer needs to send SIGKILL
to nobody. From point of view of least killing, trying to wait for exiting
task_struct is better than needlessly killing the entire thread groups using
some mm_struct. The problem of per task_struct approach is that we have no
trigger to give up waiting for that thread if that thread seems to got stuck.

Commit 98748bd722005be9 ("oom: consider multi-threaded tasks in
task_will_free_mem") changed from per task_struct approach to per signal_struct
approach. And I think that current situation is reasonable because signal_struct
is a unit for reacting to SIGKILL. If somebody implements userspace OOM-killer
(maybe lowmemory killer?), current situation allows such OOM-killer not to worry
about OOM_SCORE_ADJ_MIN or use_mm(). It is still possible that waiting for
termination of only one thread group releases a lot of memory. The problem here
is that we have no trigger to give up waiting for that thread group if that
thread group seems to got stuck. But it is trivial to use the OOM-reaper as a
trigger to give up.

Given that said, if everybody can agree with making the OOM-killer per
"struct mm_struct" operation, I think reimplementing oom_disable_count which
was removed by commit c9f01245b6a7d77d ("oom: remove oom_disable_count") (i.e.
do not select an OOM victim unless all thread groups using that mm_struct is
killable) seems to be better than ignoring what userspace told to do (i.e.
select an OOM victim even if some thread groups using that mm_struct is not
killable). Userspace knows the risk of setting OOM_SCORE_ADJ_MIN; it is a
strong request like __GFP_NOFAIL allocation. We have global oom_lock which
avoids race condition. Since writing to /proc/pid/oom_score_adj is not frequent,
we can afford mutex_lock_killable(&oom_lock). We can interpret use_mm() request
as setting OOM_SCORE_ADJ_MIN.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
