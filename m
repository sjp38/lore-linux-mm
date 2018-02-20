Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83F9A6B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 09:13:08 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id d127so12693097iog.11
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 06:13:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f2si31527ioa.213.2018.02.20.06.13.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Feb 2018 06:13:07 -0800 (PST)
Subject: Re: [PATCH] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180123124245.GK1526@dhcp22.suse.cz>
	<201801242228.FAD52671.SFFLQMOVOFHOtJ@I-love.SAKURA.ne.jp>
	<201802132058.HAG51540.QFtSLOJFOOFVMH@I-love.SAKURA.ne.jp>
	<201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp>
	<20180220134052.GD21243@bombadil.infradead.org>
In-Reply-To: <20180220134052.GD21243@bombadil.infradead.org>
Message-Id: <201802202312.BJJ09805.LHFMOVJOStFFOQ@I-love.SAKURA.ne.jp>
Date: Tue, 20 Feb 2018 23:12:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Matthew Wilcox wrote:
> On Tue, Feb 20, 2018 at 10:32:56PM +0900, Tetsuo Handa wrote:
> >  
> > -	/*
> > -	 * Acquire the oom lock.  If that fails, somebody else is
> > -	 * making progress for us.
> > -	 */
> > -	if (!mutex_trylock(&oom_lock)) {
> > +	if (mutex_lock_killable(&oom_lock)) {
> >  		*did_some_progress = 1;
> >  		schedule_timeout_uninterruptible(1);
> >  		return NULL;
> 
> It looks odd to mutex_lock_killable() and then
> schedule_timeout_uninterruptible().  Why not schedule_timeout_killable()?
> If someone's sent a fatal signal, why delay for one jiffy?
> 

That sleep will be moved to somewhere else by future patches. For now, let's
make sure that "killed but not yet marked as an OOM victim" threads won't
waste CPU resources by looping without permission to use memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
