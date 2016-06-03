Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B4C9B6B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:12:13 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 132so36845286lfz.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:12:13 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id d83si56386778wmd.75.2016.06.03.05.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 05:12:12 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e3so23079139wme.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:12:12 -0700 (PDT)
Date: Fri, 3 Jun 2016 14:12:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
Message-ID: <20160603121209.GF20676@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <1464945404-30157-8-git-send-email-mhocko@kernel.org>
 <201606032042.ADC04699.SFFOJLHFOOQMVt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606032042.ADC04699.SFFOJLHFOOQMVt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Fri 03-06-16 20:42:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > +static inline bool __task_will_free_mem(struct task_struct *task)
> > +{
> > +	struct signal_struct *sig = task->signal;
> > +
> > +	/*
> > +	 * A coredumping process may sleep for an extended period in exit_mm(),
> > +	 * so the oom killer cannot assume that the process will promptly exit
> > +	 * and release memory.
> > +	 */
> > +	if (sig->flags & SIGNAL_GROUP_COREDUMP)
> > +		return false;
> > +
> > +	if (sig->flags & SIGNAL_GROUP_EXIT)
> > +		return true;
> > +
> > +	if (thread_group_empty(task) && PF_EXITING)
> > +		return true;
> 
> "thread_group_empty(task) && PF_EXITING" is wrong.

Sigh. I've screwed during the rebase again. Sorry about that!
---
