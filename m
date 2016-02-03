Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A80D182963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 18:30:49 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id n128so22301337pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:30:49 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id z10si12195626pfi.50.2016.02.03.15.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 15:30:49 -0800 (PST)
Received: by mail-pf0-x22c.google.com with SMTP id 65so22491399pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:30:49 -0800 (PST)
Date: Wed, 3 Feb 2016 15:30:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] mm, page_alloc: Warn on !__GFP_NOWARN allocation
 from IRQ context.
In-Reply-To: <201602022233.FFF65148.QVOLOtOMFJHSFF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1602031528280.10331@chino.kir.corp.google.com>
References: <201602022233.FFF65148.QVOLOtOMFJHSFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, jstancek@redhat.com, linux-mm@kvack.org

On Tue, 2 Feb 2016, Tetsuo Handa wrote:

> >From 20b3c1c9ef35547395c3774c6208a867cf0046d4 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 2 Feb 2016 16:50:45 +0900
> Subject: [RFC][PATCH] mm, page_alloc: Warn on !__GFP_NOWARN allocation from IRQ context.
> 
> Jan Stancek hit a hard lockup problem due to flood of memory allocation
> failure messages which lasted for 10 seconds with IRQ disabled. Printing
> traces using warn_alloc_failed() is very slow (which can take up to about
> 1 second for each warn_alloc_failed() call). The caller used GFP_NOWARN
> inside a loop. If the caller used __GFP_NOWARN, it would not have lasted
> for 10 seconds.
> 

Sounds like a ratelimiting issue in warn_alloc_failed() with nopage_rs.  
Would it be possible under certain configs to tweak this to not be so 
slow?

Unfortunately, I don't think we can get away with adding a conditional to 
the page allocator hotpath for this, especially if it is only going to 
suggest a kernel patch :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
