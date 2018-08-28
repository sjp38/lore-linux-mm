Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 853FC6B4694
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 09:51:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 57-v6so855883edt.15
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 06:51:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s23-v6si396253edm.234.2018.08.28.06.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 06:51:56 -0700 (PDT)
Date: Tue, 28 Aug 2018 15:51:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: OOM victims do not need to select next OOM
 victim unless __GFP_NOFAIL.
Message-ID: <20180828135105.GB10349@dhcp22.suse.cz>
References: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180828124030.GB12564@cmpxchg.org>
 <58e0bd2d-71bd-cf46-0929-ef5eb0c6c2bc@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58e0bd2d-71bd-cf46-0929-ef5eb0c6c2bc@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

On Tue 28-08-18 22:29:56, Tetsuo Handa wrote:
[...]
> The OOM reaper may set MMF_OOM_SKIP without reclaiming any memory (due
> to e.g. mlock()ed memory, shared memory, unable to grab mmap_sem for read).
> We haven't reached to the point where the OOM reaper reclaims all memory
> nor allocating threads wait some more after setting MMF_OOM_SKIP.
> Therefore, this
> 
>   if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
>       return true;
> 
> is the simplest mitigation we can do now.

But this is adding a mess because you pretend to make a forward progress
even the OOM path didn't do anything at all and rely on another kludge
elsewhere to work. This just makes the code fragile for not strong
reason. Yes, this whole area is racy and there are rare corner cases as
you mentioned. I have already mentioned how to deal with some of them
several times. It would be so much more helpful to go after those and
address them rather than post some random hacks and build castles on a
sand.
-- 
Michal Hocko
SUSE Labs
