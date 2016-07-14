Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A16446B026E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 17:40:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so178856677pfa.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 14:40:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k20si1784362pfg.177.2016.07.14.14.40.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 14:40:10 -0700 (PDT)
Subject: Re: System freezes after OOM
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160713145638.GM28723@dhcp22.suse.cz>
	<alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
	<201607142001.BJD07258.SMOHFOJVtLFOQF@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1607141324290.68666@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1607141324290.68666@chino.kir.corp.google.com>
Message-Id: <201607150640.GEB78167.VOFSFHOLMtJOFQ@I-love.SAKURA.ne.jp>
Date: Fri, 15 Jul 2016 06:40:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mpatocka@redhat.com, mhocko@kernel.org, okozina@redhat.com, jmarchan@redhat.com, skozina@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Thu, 14 Jul 2016, Tetsuo Handa wrote:
> 
> > David Rientjes wrote:
> > > On Wed, 13 Jul 2016, Mikulas Patocka wrote:
> > > 
> > > > What are the real problems that f9054c70d28bc214b2857cf8db8269f4f45a5e23 
> > > > tries to fix?
> > > > 
> > > 
> > > It prevents the whole system from livelocking due to an oom killed process 
> > > stalling forever waiting for mempool_alloc() to return.  No other threads 
> > > may be oom killed while waiting for it to exit.
> > 
> > Is that concern still valid? We have the OOM reaper for CONFIG_MMU=y case.
> > 
> 
> Umm, show me an explicit guarantee where the oom reaper will free memory 
> such that other threads may return memory to this process's mempool so it 
> can make forward progress in mempool_alloc() without the need of utilizing 
> memory reserves.  First, it might be helpful to show that the oom reaper 
> is ever guaranteed to free any memory for a selected oom victim.
> 

Whether the OOM reaper will free some memory no longer matters. Instead,
whether the OOM reaper will let the OOM killer select next OOM victim matters.

Are you aware that the OOM reaper will let the OOM killer select next OOM
victim (currently by clearing TIF_MEMDIE)? Clearing TIF_MEMDIE in 4.6 occurred
only when OOM reaping succeeded. But we are going to change the OOM reaper
always clear TIF_MEMDIE in 4.8 (or presumably change the OOM killer not to
depend on TIF_MEMDIE) so that the OOM reaper guarantees that the OOM killer
always selects next OOM victim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
