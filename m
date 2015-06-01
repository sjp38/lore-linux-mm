Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5775D6B006C
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 07:43:53 -0400 (EDT)
Received: by wifw1 with SMTP id w1so101349610wif.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 04:43:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ge5si24303764wjb.125.2015.06.01.04.43.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 04:43:51 -0700 (PDT)
Date: Mon, 1 Jun 2015 13:43:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150601114349.GE7147@dhcp22.suse.cz>
References: <20150528180524.GB2321@dhcp22.suse.cz>
 <201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
 <20150529144922.GE22728@dhcp22.suse.cz>
 <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
 <20150601090341.GA7147@dhcp22.suse.cz>
 <201506011951.DCC81216.tMVQHLFOFFOJSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506011951.DCC81216.tMVQHLFOFFOJSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Mon 01-06-15 19:51:05, Tetsuo Handa wrote:
[...]
> How can all fatal_signal_pending() "struct task_struct" get access to memory
> reserves when only one of fatal_signal_pending() "struct task_struct" has
> TIF_MEMDIE ?

Because of 
	/*
	 * If current has a pending SIGKILL or is exiting, then automatically
	 * select it.  The goal is to allow it to allocate so that it may
	 * quickly exit and free its memory.
	 *
	 * But don't select if current has already released its mm and cleared
	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
	 */
	if (current->mm &&
	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
		mark_oom_victim(current);
		goto out;
	}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
