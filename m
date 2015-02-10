Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id ACB8C6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 09:52:50 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id u20so13024769oif.11
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 06:52:50 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g10si7648324obh.67.2015.02.10.06.52.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 06:52:49 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
	<20141229181937.GE32618@dhcp22.suse.cz>
	<201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
	<20141230112158.GA15546@dhcp22.suse.cz>
	<201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
In-Reply-To: <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
Message-Id: <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
Date: Tue, 10 Feb 2015 22:58:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

(Michal is offline, asking Johannes instead.)

Tetsuo Handa wrote:
> (A) The order-0 __GFP_WAIT allocation fails immediately upon OOM condition
>     despite we didn't remove the
> 
>         /*
>          * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
>          * means __GFP_NOFAIL, but that may not be true in other
>          * implementations.
>          */
>         if (order <= PAGE_ALLOC_COSTLY_ORDER)
>                 return 1;
> 
>     check in should_alloc_retry(). Is this what you expected?

This behavior is caused by commit 9879de7373fcfb46 "mm: page_alloc:
embed OOM killing naturally into allocation slowpath". Did you apply
that commit with agreement to let GFP_NOIO / GFP_NOFS allocations fail
upon memory pressure and permit filesystems to take fs error actions?

	/* The OOM killer does not compensate for light reclaim */
	if (!(gfp_mask & __GFP_FS))
		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
