Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F56E6B0262
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:45:22 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u14so48011828lfd.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:45:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f189si619662wmf.4.2016.09.15.07.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 07:45:20 -0700 (PDT)
Date: Thu, 15 Sep 2016 10:41:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/4] mm, oom: get rid of TIF_MEMDIE
Message-ID: <20160915144118.GB25519@cmpxchg.org>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>

Hi Michal,

On Thu, Sep 01, 2016 at 11:51:00AM +0200, Michal Hocko wrote:
> Hi,
> this is an early RFC to see whether the approach I've taken is acceptable.
> The series is on top of the current mmotm tree (2016-08-31-16-06). I didn't
> get to test it so it might be completely broken.
> 
> The primary point of this series is to get rid of TIF_MEMDIE finally.
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
> the process. It didn't work 100% reliably and had it own issues but we
> have to replace it with something which doesn't rely on counting threads
> but rather find a moment when all threads have reached steady state in
> do_exit. This is what patch 3 does and I would really appreciate if Oleg
> could double check my thinking there. I am also CCing Al on that one
> because I am moving exit_io_context up in do_exit right before exit_notify.

You're explaining the mechanical thing you are doing, but I'm having
trouble understanding why you want to get rid of TIF_MEMDIE. For one,
it's more code. And apparently, it's also more complicated than what
we have right now.

Can you please explain in the cover letter what's broken/undesirable?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
