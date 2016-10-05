Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2C926B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 08:04:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so216009694pfj.1
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 05:04:20 -0700 (PDT)
Received: from mail-pf0-f195.google.com (mail-pf0-f195.google.com. [209.85.192.195])
        by mx.google.com with ESMTPS id tp6si7870065pab.158.2016.10.05.05.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Oct 2016 05:04:19 -0700 (PDT)
Received: by mail-pf0-f195.google.com with SMTP id i85so5021400pfa.0
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 05:04:19 -0700 (PDT)
Date: Wed, 5 Oct 2016 14:04:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/4] mm, oom: get rid of TIF_MEMDIE
Message-ID: <20161005120415.GD7138@dhcp22.suse.cz>
References: <20161004090009.7974-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004090009.7974-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>

On Tue 04-10-16 11:00:05, Michal Hocko wrote:
[...]
> Recent changes in the oom proper allows for that finally, I believe. Now
> that all the oom victims are reapable we are no longer depending on
> ALLOC_NO_WATERMARKS because the memory held by the victim is reclaimed
> asynchronously. A partial access to memory reserves should be sufficient
> just to guarantee that the oom victim is not starved due to other
> memory consumers. This also means that we do not have to pretend to be
> conservative and give access to memory reserves only to one thread from
> the process at the time. This is patch 1.
> 
> Patch 2 is a simple cleanup which turns TIF_MEMDIE users to tsk_is_oom_victim
> which is process rather than thread centric. None of those callers really
> requires to be thread aware AFAICS.
> 
> The tricky part then is exit_oom_victim vs. oom_killer_disable because
> TIF_MEMDIE acted as a token there so we had a way to count threads from
> the process. It didn't work 100% reliably and had its own issues but we
> have to replace it with something which doesn't rely on counting threads
> but rather find a moment when all threads have reached steady state in
> do_exit. This is what patch 3 does and I would really appreciate if Oleg
> could double check my thinking there. I am also CCing Al on that one
> because I am moving exit_io_context up in do_exit right before exit_notify.

It became apparent that the last part was wrong after Oleg's review. I
definitely want to come up with something that works eventually. I am
just wondering whether patches 1-2 are worth accepting without the rest.
I fully realize those patches are less attractive when TIF_MEMDIE stays
but I would argue that reducing the TIF_MEMDIE users will make the code
slightly better and easier to understand.

What do you think?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
