Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8E2C6B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 07:35:09 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id w16so79175686lfd.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 04:35:09 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id i127si30317786wmi.53.2016.05.30.04.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 04:35:07 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a136so21846341wme.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 04:35:07 -0700 (PDT)
Date: Mon, 30 May 2016 13:35:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/5] Handle oom bypass more gracefully
Message-ID: <20160530113504.GT22928@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <20160527160026.GA29337@dhcp22.suse.cz>
 <201605282304.DJC04167.SHLtVQMOOFFOFJ@I-love.SAKURA.ne.jp>
 <20160530072116.GF22928@dhcp22.suse.cz>
 <201605302010.AGF00027.tQHSFOFJMOVFOL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605302010.AGF00027.tQHSFOFJMOVFOL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Mon 30-05-16 20:10:46, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > You are trying to make the OOM killer as per mm_struct operation. But
> > > I think we need to tolerate the OOM killer as per signal_struct operation.
> > 
> > Signal struct based approach is full of weird behavior which just leads
> > to corner cases. I think going mm struct way is the only sensible
> > approach.
> 
> I don't think so. What are corner cases the OOM reaper cannot handle with
> signal_struct based approach?

E.g. all the mm shared outside of the thread group with weird
inconsistencies crap.

> The OOM-killer decides based on "struct mm_struct" but it is a weakness of
> the OOM-killer that it cares only "struct mm_struct". It is possible that
> waiting for termination of only one thread releases a lot of memory (e.g.
> by closing pipe's file descriptor) and the OOM-killer needs to send SIGKILL
> to nobody.

How can a thread release pipe's memory when other threads are sharing
the same fd?

[...]
> Given that said, if everybody can agree with making the OOM-killer per
> "struct mm_struct" operation, I think reimplementing oom_disable_count which
> was removed by commit c9f01245b6a7d77d ("oom: remove oom_disable_count") (i.e.
> do not select an OOM victim unless all thread groups using that mm_struct is
> killable) seems to be better than ignoring what userspace told to do (i.e.
> select an OOM victim even if some thread groups using that mm_struct is not
> killable). Userspace knows the risk of setting OOM_SCORE_ADJ_MIN; it is a
> strong request like __GFP_NOFAIL allocation. We have global oom_lock which
> avoids race condition. Since writing to /proc/pid/oom_score_adj is not frequent,
> we can afford mutex_lock_killable(&oom_lock). We can interpret use_mm() request
> as setting OOM_SCORE_ADJ_MIN.

I am not really sure oom_lock is even needed. It is highly unlikely we
would race with an ongoing OOM killer. And even then the lock doesn't
bring much better semantic.

Regarding oom_disable_count, I think the current approach of
http://lkml.kernel.org/r/1464266415-15558-4-git-send-email-mhocko@kernel.org
has one large advantage. The userspace can simply check the current
situation while any internal flag/counter/whatever hides that
implementation fact and so the userspace has no means to deal with it.

Sure, it can be argued that changing oom_score_adj behind process back
is nasty but we already do that for threads and nobody seems to
complain. Shared mm between processes is just a different model of
threading from the MM point of view. Or is this thinking wrong in
principle?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
