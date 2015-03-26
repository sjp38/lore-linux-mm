Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 056136B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:04:29 -0400 (EDT)
Received: by wgra20 with SMTP id a20so67308215wgr.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 08:04:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u5si10295779wjy.196.2015.03.26.08.04.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 08:04:26 -0700 (PDT)
Date: Thu, 26 Mar 2015 11:04:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 04/12] mm: oom_kill: remove unnecessary locking in
 exit_oom_victim()
Message-ID: <20150326150418.GA23973@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-5-git-send-email-hannes@cmpxchg.org>
 <20150326125348.GF15257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326125348.GF15257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Thu, Mar 26, 2015 at 01:53:48PM +0100, Michal Hocko wrote:
> On Wed 25-03-15 02:17:08, Johannes Weiner wrote:
> > Right now the only waiter is suspend code, which achieves quiescence
> > by disabling the OOM killer.  But later on we want to add waits that
> > hold the lock instead to stop new victims from showing up.
> 
> It is not entirely clear what you mean by this from the current context.
> exit_oom_victim is not called from any context which would be locked by
> any OOM internals so it should be safe to use the locking.

A later patch will add another wait_event() to wait for oom victims to
drop to zero.  But that new consumer won't be disabling the OOM killer
to prevent new victims from showing up, it will just hold the lock to
exclude OOM kills.  So the exiting victims shouldn't get stuck on that
lock which the guy that is waiting for them is holding.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
