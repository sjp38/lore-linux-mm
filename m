Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 187B76B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 05:37:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b201so101166311wmb.2
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 02:37:06 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id p138si30748094wmg.58.2016.10.05.02.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Oct 2016 02:37:04 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id p138so23627645wmb.0
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 02:37:04 -0700 (PDT)
Date: Wed, 5 Oct 2016 11:37:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm, oom: do not rely on TIF_MEMDIE for
 exit_oom_victim
Message-ID: <20161005093702.GB7138@dhcp22.suse.cz>
References: <20161004090009.7974-1-mhocko@kernel.org>
 <20161004090009.7974-4-mhocko@kernel.org>
 <20161004162114.GB32428@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004162114.GB32428@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>

On Tue 04-10-16 18:21:14, Oleg Nesterov wrote:
[...]
> so this can't detect the multi-threaded group exit, and ...
> 
> >  	list_for_each_entry_safe(p, n, &dead, ptrace_entry) {
> >  		list_del_init(&p->ptrace_entry);
> > -		release_task(p);
> > +		if (release_task(p) && p == tsk)
> > +			last = true;
> 
> this can only happen if this process auto-reaps itself. Not to mention
> that exit_notify() will never return true if traced.
> 
> No, this doesn't look right.

You are right. I should have noticed that. Especially when I was hunting
the strace hang bug. I started to have a bad feeling about this patch
but for some reason I just didn't put all the pieces together.

So the patch is completely b0rked. Back to drawing board and start
again. Oh well...

Anyway thanks and sorry to waste your time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
