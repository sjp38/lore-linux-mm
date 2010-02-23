Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BAFCC6B008A
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 03:44:12 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o1N8i77i031632
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 08:44:08 GMT
Received: from gwj16 (gwj16.prod.google.com [10.200.10.16])
	by wpaz17.hot.corp.google.com with ESMTP id o1N8i6lH015875
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 00:44:06 -0800
Received: by gwj16 with SMTP id 16so358801gwj.5
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 00:44:06 -0800 (PST)
Date: Tue, 23 Feb 2010 00:44:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <4B839103.2060901@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002230041240.12015@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <20100222121222.GV9738@laptop>
 <alpine.DEB.2.00.1002221400060.23881@chino.kir.corp.google.com> <4B839103.2060901@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010, Miao Xie wrote:

> Sorry, Could you explain what you advised?
> I think it is hard to fix this problem by adding a variant, because it is
> hard to avoid loading a word of the mask before
> 
> 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
> 
> and then loading another word of the mask after
> 
> 	tsk->mems_allowed = *newmems;
> 
> unless we use lock.
> 
> Maybe we need a rw-lock to protect task->mems_allowed.
> 

I meant that we need to define synchronization only for configurations 
that do not do atomic nodemask_t stores, it's otherwise unnecessary.  
We'll need to load and store tsk->mems_allowed via a helper function that 
is defined to take the rwlock for such configs and only read/write the 
nodemask for others.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
