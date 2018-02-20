Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF486B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:40:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u1so4877674pfi.20
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 05:40:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c6-v6si1306881plm.312.2018.02.20.05.40.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Feb 2018 05:40:56 -0800 (PST)
Date: Tue, 20 Feb 2018 05:40:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm,page_alloc: wait for oom_lock than back off
Message-ID: <20180220134052.GD21243@bombadil.infradead.org>
References: <20180123083806.GF1526@dhcp22.suse.cz>
 <201801232107.HJB48975.OHJFFOOLFQMVSt@I-love.SAKURA.ne.jp>
 <20180123124245.GK1526@dhcp22.suse.cz>
 <201801242228.FAD52671.SFFLQMOVOFHOtJ@I-love.SAKURA.ne.jp>
 <201802132058.HAG51540.QFtSLOJFOOFVMH@I-love.SAKURA.ne.jp>
 <201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

On Tue, Feb 20, 2018 at 10:32:56PM +0900, Tetsuo Handa wrote:
>  
> -	/*
> -	 * Acquire the oom lock.  If that fails, somebody else is
> -	 * making progress for us.
> -	 */
> -	if (!mutex_trylock(&oom_lock)) {
> +	if (mutex_lock_killable(&oom_lock)) {
>  		*did_some_progress = 1;
>  		schedule_timeout_uninterruptible(1);
>  		return NULL;

It looks odd to mutex_lock_killable() and then
schedule_timeout_uninterruptible().  Why not schedule_timeout_killable()?
If someone's sent a fatal signal, why delay for one jiffy?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
